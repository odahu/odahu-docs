Installation
============

To install ODAHU services, you need to provide a number of preliminary requirements for it.

In particular:

-  Python 3.6 or higher; to install :ref:`JupyterLab extension <int_jupyterlab_extension:Jupyterlab extension>` or :ref:`ref_odahuflowctl:odahuflowctl` which are interfaces for interacting with Odahu-flow cluster.
-  Kubernetes cluster to perform base and accessory ODAHU services in it, as well as models training, packaging and deployment processes.
   To be able to use ODAHU services, minimum version of your Kubernetes cluster must be at least `1.13 <https://v1-13.docs.kubernetes.io/docs/setup/release/notes/>`__.
-  object storage to store models training artifacts and get input data for models (:ref:`ref_connections:S3`, :ref:`ref_connections:Google Cloud Storage`, :ref:`ref_connections:Azure Blob storage` are supported)
-  :ref:`Docker registry <ref_connections:Docker>` (to store resulting Docker images from :ref:`packagers <ref_packagers:Model Packagers>`)

.. _installation-k8s:

Kubernetes setup
----------------

Deploy Kubernetes cluster in Google Compute Platform (`GKE <https://cloud.google.com/kubernetes-engine/>`__)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Prerequisites**:

-  `GCP service
   account <https://cloud.google.com/compute/docs/access/service-accounts>`__
   to deploy Kubernetes cluster with and use it credentials for access to object storage and Google Cloud Registry
-  Google Cloud Storage bucket (``odahu-flow-test-store`` in examples below) to store models output data

Run deploy of a new Kubernetes cluster:

.. code:: bash

    $ gcloud container clusters create <cluster-name> \
        --cluster-version 1.13 \
        --machine-type=n1-standard-2 \
        --disk-size=100GB \
        --disk-type=pd-ssd \
        --num-nodes 4 \
        --zone <cluster-region> \
        --project <project-id>

.. note::
   Make sure that the disk size on the cluster nodes is sufficient to store images for all services and packaged models.
   We recommend using a disk size of at least 100 GiB.

You can enable the GPU on your Kubernetes cluster, follow the `instructions <https://cloud.google.com/kubernetes-engine/docs/how-to/gpus>`_
on how to use GPU hardware accelerators in your GKE clusters' nodes.

Fetch your Kubernetes credentials for kubectl after cluster is successfully deployed:

.. code:: bash

    $ gcloud container clusters get-credentials <cluster-name> \
        --zone <cluster-region> \
        --project <project-id>

Deploy Kubernetes cluster in Amazon Web Services (`EKS <https://aws.amazon.com/eks/>`__)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Prerequisites**

-  Resources that are `described in AWS documentation <https://docs.aws.amazon.com/eks/latest/userguide/create-cluster.html#w243aac13c17c11b5>`__
-  AWS S3 bucket (``odahu-flow-test-store`` in examples below) to store models output data

After you've created VPC and a dedicated security group for it along with Amazon EKS service role to apply to your cluster, you can
create a Kubernetes cluster with following command:

.. code:: bash

    $ aws eks --region <cluster-region> create-cluster \
        --name <cluster-name> --kubernetes-version 1.13 \
        --role-arn arn:aws:iam::111122223333:role/eks-service-role-AWSServiceRoleForAmazonEKS-EXAMPLEBKZRQR \
        --resources-vpc-config subnetIds=subnet-a9189fe2,subnet-50432629,securityGroupIds=sg-f5c54184

Use the AWS CLI ``update-kubeconfig`` command to create or update ``kubeconfig`` for your cluster:

.. code:: bash

    $ aws eks --region <cluster-region> update-kubeconfig --name <cluster-name>


Deploy Kubernetes cluster in Microsoft Azure (`AKS <https://docs.microsoft.com/en-us/azure/aks/>`__)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Prerequisites**

-  `Azure AD Service Principal <https://docs.microsoft.com/en-us/azure/aks/kubernetes-service-principal>`__ to interact with Azure APIs and create dynamic resources for an AKS cluster
-  Azure Storage account with Blob container (``odahu-flow-test-store`` in examples below) to store models output data

First, create a resource group in which all created resources will be placed:

.. code:: bash

    $ az group create --location <cluster-region> \
        --name <resource-group-name>

Run deploy of a new Kubernetes cluster:

.. code:: bash

    $ az aks create --name <cluster-name> \
        --resource-group <resource-group-name>
        --node-vm-size Standard_DS2_v2 \
        --node-osdisk-size 100GB \
        --node-count 4 \
        --service-principal <service-principal-appid> \
        --client-secret <service-principal-password>

Fetch your Kubernetes credentials for kubectl after cluster is successfully deployed:

.. code:: bash

    $ az aks get-credentials --name <cluster-name> \
        --resource-group <resource-group-name>


.. _installation-base-svc:

Install base Kubernetes services
--------------------------------

Install Helm and Tiller (`version 2.14.3 <https://v2-14-0.helm.sh/docs/using_helm/#installing-helm>`__)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Make sure you have a Kubernetes service account with the ``cluster-admin`` role defined for Tiller.
If not already defined, create one using following commands:

.. code:: bash

    $ cat << EOF > tiller_sa.yaml
    ---
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: tiller
      namespace: kube-system
    ---
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: tiller
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: cluster-admin
    subjects:
    - kind: ServiceAccount
      name: tiller
      namespace: kube-system
    EOF

::

    $ kubectl apply -f ./tiller_sa.yaml

Install Tiller in your cluster with created service account:

.. code:: bash

    $ helm init --service-account=tiller

Ensure that Tiller is installed:

.. code:: bash

    $ kubectl -n kube-system get pods --selector=app=helm
    NAME                            READY   STATUS    RESTARTS   AGE
    tiller-deploy-57f498469-r5cmv   1/1     Running   0          16s

.. _installation-nginx-ingress:

Install `Nginx Ingress <https://kubernetes.github.io/ingress-nginx/>`__
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Install ``nginx-ingress`` Helm chart:

.. code:: bash

    $ helm install stable/nginx-ingress --name nginx-ingress --namespace kube-system

Get external LoadBalancer IP assigned to ``nginx-ingress`` service:

.. code:: bash

    $ kubectl get -n kube-system svc nginx-ingress-controller \
        -o=jsonpath='{.status.loadBalancer.ingress[*].ip}{"\n"}'

Install `Istio <https://istio.io/docs/setup/install/helm/#option-2-install-with-helm-and-tiller-via-helm-install>`__ (with Helm and Tiller)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. note::
   ODAHU services uses number of Istio custom resources actively, so Istio installation is mandatory.

Add Helm repository for Istio charts

.. code:: bash

    $ helm repo add istio https://storage.googleapis.com/istio-release/releases/1.4.2/charts/

Crate a namespace for the istio-system components

.. code:: bash

    $ kubectl create namespace istio-system

Install the ``istio-init`` chart to bootstrap all the Istio's
CustomResourceDefinitions

.. code:: bash

    $ helm install istio/istio-init --name istio-init --namespace istio-system

Ensure that all ``istio-init`` jobs have been completed:

.. code:: bash

    $ kubectl -n istio-system get job \
        -o=jsonpath='{range.items[?(@.status.succeeded==1)]}{.metadata.name}{"\n"}{end}'

Install Istio Helm chart with provided values.

Example:

.. code:: bash

    $ cat << EOF > istio_values.yaml
    global:
      proxy:
        accessLogFile: "/dev/stdout"
      disablePolicyChecks: false
    sidecarInjectorWebhook:
      enabled: true
    pilot:
      enabled: true
    mixer:
      policy:
        enabled: true
      telemetry:
        enabled: true
      adapters:
        stdio:
          enabled: true
    gateways:
      istio-ingressgateway:
        enabled: true
        type: ClusterIP
        meshExpansionPorts: []
        ports:
          - port: 80
            targetPort: 80
            name: http
          - port: 443
            name: https
          - port: 15000
            name: administration
      istio-egressgateway:
        enabled: true
    prometheus:
      enabled: false
    EOF

    $ helm install istio/istio --name istio --namespace istio-system --values ./istio_values.yaml

Add ODAHU Helm charts repository
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code:: bash

    $ helm repo add odahu https://raw.githubusercontent.com/odahu/odahu-helm/master

Install `Knative <https://knative.dev/docs/install/>`__
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Create namespace for Knative and label it for Istio injection:

.. code:: bash

    $ kubectl create namespace knative-serving && \
        kubectl label namespace knative-serving istio-injection=enabled

Install Knative with `Helm
chart <https://github.com/odahu/odahu-helm/tree/master/odahu-flow-knative>`__
provided by ODAHU team:

.. code:: bash

    $ helm install odahu/odahu-flow-knative --name knative --namespace knative-serving

Install `Tekton Pipelines <https://github.com/tektoncd/pipeline>`__
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Create namespace for Tekton:

.. code:: bash

    $ kubectl create namespace tekton-pipelines

Install Tekton Pipelines with `Helm
chart <https://github.com/odahu/odahu-helm/tree/master/odahu-flow-tekton>`__
provided by ODAHU team:

.. code:: bash

    $ helm install odahu/odahu-flow-tekton --name tekton --namespace tekton-pipelines

Install `Fluentd <https://www.fluentd.org/>`__ with set of cloud object storage plugins
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In order to save models training logs to object storage of cloud provider you use, a container with ``fluentd`` is used, in which a set of
`plugins <https://www.fluentd.org/plugins/all#input-output>`__ for popular cloud providers' object storages (AWS S3, Google Storage, Azure
Blob) is added. Installation is done using a `fluentd Helm chart <https://github.com/odahu/odahu-infra/tree/develop/helms/odahu-flow-fluentd>`__
provided by ODAHU team.

First, create an object storage bucket:

.. code:: bash

    $ gsutil mb gs://odahu-flow-test-store/

Create namespace for Fluentd:

.. code:: bash

    $ kubectl create namespace fluentd

Install Fluentd with specified values. Full list of values you can see
in chart's `values.yaml <https://github.com/odahu/odahu-infra/blob/develop/helms/odahu-flow-fluentd/values.yaml>`__.

Example:

.. code:: bash

    $ cat << EOF > fluentd_values.yaml
    output:
      target: gcs
      gcs:
        authorization: keyfile
        bucket: odahu-flow-test-store
        project: my-gcp-project-id-zzzzz
        private_key_id: 0bacc0b0caa0a0aacabcacbab0a0b00ababacaab
        private_key: -----BEGIN PRIVATE KEY-----\nprivate-key-here\n-----END PRIVATE KEY-----\n
        client_email: service-account@my-gcp-project-id-zzzzz.iam.gserviceaccount.com
        client_id: 000000000000000000000
        auth_uri: https://accounts.google.com/o/oauth2/auth
        token_uri: https://oauth2.googleapis.com/token
        auth_provider_x509_cert_url: https://www.googleapis.com/oauth2/v1/certs
        client_x509_cert_url: https://www.googleapis.com/robot/v1/metadata/x509/service-account%40my-gcp-project-id-zzzzz.iam.gserviceaccount.com
    EOF

::

    $ helm install odahu/odahu-flow-fluentd --name fluentd --namespace fluentd --values ./fluentd_values.yaml


.. _opa_installation:
Install `Open Policy Agent <https://www.openpolicyagent.org/>`__ (optional)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To activate API authentication and authorization using :ref:`Security <gen_security:Security>`
install OpenPolicyAgent (OPA) helm chart with ODAHU built-in policies.

Create namespace for OPA

.. code:: bash

    $ kubectl create namespace odahu-flow-opa

Install OpenPolicyAgent with `Helm
chart <https://github.com/odahu/odahu-helm/tree/master/odahu-flow-opa>`__
provided by ODAHU team:

.. code:: bash

    $ helm install odahu/odahu-flow-opa --name odahu-flow-opa --namespace odahu-flow-opa

You must configure your OpenID provider (to allow envoy JWT token verifying) using next Helm values

.. code-block:: yaml
    :caption: Parameters to configure OpenID provider

    # authn overrides configuration of envoy.filters.http.jwt_authn http filter
    authn:
      # enabled activate envoy authn filter that verify jwt token and pass parsed data
      # to next filters (particularly to authz)
      oidcIssuer: ""
      oidcJwks: ""
      oidcHost: ""
      localJwks: ""

For information about `authn` section parameters see
`docs for envoy authentication filter <https://www.envoyproxy.io/docs/envoy/latest/api-v2/config/filter/http/jwt_authn/v2alpha/config.proto>`_

.. _how-to-customize-opa-policies:

By default chart is delivered with :ref:`built-in policies <gen_security:Built-in policies overview>`
that implements Role base access system
and set of pre-defined roles. To customize some of built-in policies files or define new ones use next Helm values

.. code-block:: yaml
    :caption: Parameters to configure built-in policies
    :name: Customize-opa-policies

    opa:
      policies: {}
      #  policies:
        #  file1: ".rego policy content encoded as base64"
        #  file2: ".rego policy content encoded as base64"

.. warning::
    content of rego files defined in values.yaml should be base64 encoded


.. _tutorials_installation-odahu-svc:


Install ODAHU
-------------

Install core ODAHU services
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Create namespace for core ODAHU service:

.. code:: bash

    $ kubectl create namespace odahu-flow &&\
        kubectl label namespace odahu-flow project=odahu-flow

Create namespaces for ODAHU training, packaging and deployment.

.. code:: bash

    $ for i in training packaging deployment; do \
        kubectl create namespace odahu-flow-${i} &&\
        kubectl label namespace odahu-flow-${i} project=odahu-flow; done

To provision pods in the deployment namespace according to node selectors and toleration from the config you need to label the namespace so the model deployment webhook use it as a target

.. code:: bash

    $ kubectl label namespace odahu-flow-deployment modeldeployment-webhook=enabled

Deployment namespace should be also labeled for Istio injection.

.. code:: bash

    $ kubectl label namespace odahu-flow-deployment istio-injection=enabled

Prepare YAML config with values for
`odahu-flow-core <https://github.com/odahu/odahu-flow/tree/develop/helms/odahu-flow-core>`__
Helm chart.

Example:

.. code:: bash

    $  cat << EOF > odahuflow_values.yaml
    logLevel: debug
    ingress:
      enabled: true
      globalDomain: odahu.example.com
    edge:
      ingress:
        enabled: true
        domain: odahu.example.com
    feedback:
      enabled: true
    config:
      common:
        external_urls:
        - name: Documentation
          url: https://docs.odahu.org
      connection:
        enabled: true
        decrypt_token: somenotemptystring
        repository_type: kubernetes
      deployment:
        edge:
          host: http://odahu.example.com
    EOF

.. note::
   This example uses hostname ``odahu.example.com`` as entrypoint for cluster services.
   It should point to LoadBalancer IP got from :ref:`Nginx Ingress section<installation-nginx-ingress>`.

In order to setup ODAHU services along with ready-to-use :term:`connections<Connection>`, you may add according section to
values YAML in advance.

To support training on GPU, you should provide the GPU node selectors and tolerations:

Example:

.. code-block:: yaml
    :caption: Example of Connection GCS:

    config:
      training:
        gpu_toleration:
          Key: dedicated
          Operator: Equal
          Value: training-gpu
          Effect: NO_SCHEDULE
        gpu_node_selector:
          mode: odahu-flow-training-gpu

Examples:

a) :ref:`Docker registry connection<ref_connections:Docker>` is used to pull/push Odahu packager resulting Docker images to a Docker registry

::

    connections:
    - id: docker-hub
      spec:
        description: Docker registry for model packaging
        username: "user"
        password: "supersecure"
        type: docker
        uri: docker.io/odahu-models-repo
        webUILink: https://hub.docker.com/r/odahu-models-repo

b) :ref:`Google Cloud Storage connection<ref_connections:Google Cloud Storage>` is used to store model trained artifacts and input data for ML models

::

    connections:
    - id: models-output
      spec:
        description: Object storage for trained artifacts
        keySecret: '{ "type": "service_account", "project_id": "my-gcp-project-id-zzzzz", "private_key_id": "0bacc0b0caa0a0aacabcacbab0a0b00ababacaab", "private_key": "-----BEGIN PRIVATE KEY-----\nprivate-key-here\n-----END PRIVATE KEY-----\n", "client_email": "service-account@my-gcp-project-id-zzzzz.iam.gserviceaccount.com", "client_id": "000000000000000000000", "auth_uri": "https://accounts.google.com/o/oauth2/auth", "token_uri": "https://oauth2.googleapis.com/token", "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs", "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/service-account%40my-gcp-project-id-zzzzz.iam.gserviceaccount.com" }'
        region: my-gcp-project-id-zzzzz
        type: gcs
        uri: gs://odahu-flow-test-store/output
        webUILink: https://console.cloud.google.com/storage/browser/odahu-flow-test-store/output?project=my-gcp-project-id-zzzzz


If you install :ref:`Open Policy Agent <_opa_installation>` for ODAHU then you will need to configure service accounts
which will be used by ODAHU core background services such as :term:`<Trainer>` or :term:`<Packager>`.

All service accounts below require `odahu-admin` ODAHU built-in role.
(see more about built-in roles in :ref:`security docs <gen_security:Pre-defined roles overview>`)

Next values with service account credentials are required :

.. code-block:: yaml
   :name: Set credentials for core service accounts
   :caption: values.yaml
   :linenos:

   config:
     operator:
       # OpenId Provider token url
       oauth_oidc_token_endpoint: https://oauth2.googleapis.com/token
       # Credentials from OAuth2 client with Client Credentials Grant
       client_id: client-id
       client_secret: client-secret

     trainer:
       # OpenId Provider token url
       oauth_oidc_token_endpoint: https://oauth2.googleapis.com/token
       # Credentials from OAuth2 client with Client Credentials Grant
       client_id: client-id
       client_secret: client-secret

     packager:
       # OpenId Provider token url
       oauth_oidc_token_endpoint: https://oauth2.googleapis.com/token
       # Credentials from OAuth2 client with Client Credentials Grant
       client_id: client-id
       client_secret: client-secret

   # Service account used to upload odahu resources via odahuflowctl
   resource_uploader_sa:
     client_id: some-client-id
     client_secret: client-secret

   # OpenID provider url
   oauth_oidc_issuer_url: ""

In this file, we:

- lines 2-7: configure service account for :term:`Operator`
- lines 9-14: configure service account for :term:`Trainer`
- lines 16-21: configure service account for :term:`Packager`
- lines 24-29: configure service account Kubernetes Job that install some ODAHU Manifests using ODAHU API


Install odahu-flow core services:

.. code:: bash

    $ helm install odahu/odahu-flow-core --name odahu-flow --namespace odahu-flow --values ./odahuflow_values.yaml

Training service (MLFlow)
~~~~~~~~~~~~~~~~~~~~~~~~~

Prepare YAML config with values for
`odahu-flow-mlflow <https://github.com/odahu/odahu-trainer/tree/develop/helms/odahu-flow-mlflow>`__
Helm chart.

.. code:: bash

    $ cat << EOF > mlflow_values.yaml
    logLevel: debug
    ingress:
      globalDomain: example.com
      enabled: true
    tracking_server:
      annotations:
        sidecar.istio.io/inject: "false"
    toolchain_integration:
      enabled: true
    EOF

If you install :ref:`Open Policy Agent <_opa_installation>` for ODAHU then you will need to configure service account
for a Kubernetes Job that install some ODAHU Manifests using ODAHU API. This Service account should have role
`odahu-admin`.

Next values with service account credentials are required :

.. code-block:: yaml
   :name: Set credentials for core service account
   :caption: values.yaml
   :linenos:

   # Service account used to upload odahu resources via odahuflowctl
   resource_uploader_sa:
     client_id: some-client-id
     client_secret: client-secret

   # OpenID provider url
   oauth_oidc_issuer_url: ""

Install Helm chart:

.. code:: bash

    $ helm install odahu/odahu-flow-mlflow --name odahu-flow-mlflow --namespace odahu-flow \
        --values ./mlflow_values.yaml

Packaging service
~~~~~~~~~~~~~~~~~

If you install :ref:`Open Policy Agent <_opa_installation>` for ODAHU then you will need to configure service account
for a Kubernetes Job that install some ODAHU Manifests using ODAHU API. This Service account should have role
`odahu-admin`.

Next values with service account credentials are required :

.. code-block:: yaml
   :name: Set credentials for core service account
   :caption: values.yaml
   :linenos:

   # Service account used to upload odahu resources via odahuflowctl
   resource_uploader_sa:
     client_id: some-client-id
     client_secret: client-secret

   # OpenID provider url
   oauth_oidc_issuer_url: ""

Install `odahu-flow-packagers <https://github.com/odahu/odahu-packager/tree/develop/helms/odahu-flow-packagers>`__
Helm chart:

.. code:: bash

    $ helm install odahu/odahu-flow-packagers --name odahu-flow-packagers --namespace odahu-flow

Install additional services (optional)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In order to provide additional functionality, ODAHU team also developed several Helm charts to install them into Kubernetes cluster.
These are:

-  `odahu-flow-monitoring <https://github.com/odahu/odahu-infra/tree/develop/helms/odahu-flow-monitoring>`__ - Helm chart providing installation and setup of

   -  `Prometheus operator <https://github.com/coreos/prometheus-operator>`__ - to collect :ref:`various metrics<int_metrics:Metrics>` from models trainings
   -  `Grafana <https://github.com/grafana/grafana>`__ with set of custom dashboards - to visualize these metrics

- `odahu-flow-k8s-gke-saa <https://github.com/odahu/odahu-infra/tree/develop/helms/odahu-flow-k8s-gke-saa>`__ - Helm chart providing installation and setup of `k8s-gke-service-account-assigner <https://github.com/imduffy15/k8s-gke-service-account-assigner>`__ service.



Delete ODAHU services
---------------------

To delete and purge Helm chart run:

.. code:: bash

    $ helm delete --purge odahu-flow

To clean up remaining ``CustomResourceDefinitions`` execute following
command:

.. code:: bash

    $ kubectl get crd | awk '/odahuflow/ {print $1}' | xargs -n1 kubectl delete crd

To purge everything installed in previous steps with single command, run

.. code:: bash

    $ helm delete --purge odahu-flow-packagers odahu-flow-mlflow odahu-flow &&\
      kubectl delete namespace odahu-flow &&\
      for i in training packaging deployment; do \
        kubectl delete namespace odahu-flow-${i} || true; done &&\
      kubectl get crd | awk '/odahuflow/ {print $1}' | xargs -n1 kubectl delete crd &&\
      kubectl -n istio-system delete job.batch/odahu-flow-feedback-rq-catcher-patcher &&\
      kubectl -n istio-system delete sa/odahu-flow-feedback-rq-catcher-patcher &&\
      kubectl -n istio-system delete cm/odahu-flow-feedback-rq-catcher-patch

Conclusion
----------

After successful deployment of a cluster, you may proceed to :ref:`Quickstart section<tutorials_wine:Quickstart>` and learn how to perform base ML operations such as :term:`train<Train>`, :term:`package<Package>` and :term:`deploy<Deploy>` steps.
