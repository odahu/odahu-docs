Changelog
=========

Odahu 1.1.0, 16 March 2020
--------------------------

New Features:
""""""""""""

- Jupyterhub:
    Supported the JupyterHub in our deployment scripts.
    JupyterHub allows spawning multiple instances of the JupyterLab server.
    By default, we provide the prebuilt ODAHU JupyterLab plugin in the following Docker images: `base-notebook <https://hub.docker.com/r/odahu/base-notebook>`_, `datascience-notebook <https://hub.docker.com/r/odahu/datascience-notebook>`_, and `tensorflow-notebook <https://hub.docker.com/r/odahu/tensorflow-notebook>`_.
    To build a custom image, you can use `our Docker image template <https://github.com/odahu/odahu-flow-jupyterlab-plugin/blob/develop/containers/jupyter-stacks/Dockerfile>`_ or follow the :ref:`instructions <int_jupyterlab_extension:installation>`.

- GPU:
    Added the ability to deploy a model training on GPU nodes.
    You can find an example of training `here <https://github.com/odahu/odahu-examples/tree/develop/mlflow/tensorflow/flower_classifier>`_.
    This is one of the official MLFlow examples that classifies flower species from photos.

- Secuirty:
    We integrated our WEB API services with `Open Policy Agent <https://www.openpolicyagent.org/>`_ that flexibly allows managing ODAHU RBAC.
    Using `Istio <https://istio.io/>`_, we forbid non-authorize access to our services.
    You can find the ODAHU security documentation :ref:`here <gen_security:Security>`.

- Vault:
    ODAHU-Flow has the Connection API that allows managing credentials from Git repositories, cloud storage, docker registries, and so on.
    The default backend for Connection API is Kubernetes.
    We integrated the `Vault <https://www.vaultproject.io/>`_ as a storage backend for the backend for Connection API to manage your credentials securely.

- Helm 3:
    We migrated our Helm charts to the Helm 3 version.
    The main goals were to simplify a deployment process to an Openshift and to get rid of the tiller.

- ODAHU UI:
    ODAHU UI provides a user interface for the ODAHU components in a browser.
    It allows you to manage and view ODAHU Connections, Trainings, Deployments, and so on.

- Local training and packaging:
    You can train and package an ML model with the `odahuflowctl` utility using the same ODAHU manifests, as you use for the cluster training and packaging.
    The whole process is described :ref:`here <tutorials_local_wine:Local Quickstart>`.

- Cache for training and packaging:
    ODAHU Flow downloads your dependencies on every model training and packaging launch.
    To avoid this, you can provide a prebuilt Docker image with dependencies.
    Read more for model :ref:`training <training-model-dependencies-cache>` and :ref:`packagings <packaging-model-dependencies-cache>`.

- Performance improvement training and packaging:
    We fixed multiple performance issues to speed up the training and packaging processes.
    For our model examples, the duration of training and packaging was reduced by 30%.

- Documentation improvement:
    We conducted a hard work to improve the documentation.
    For example, the following new sections were added: :ref:`Security <gen_security:Security>`, :ref:`Installation <tutorials_installation:Installation>`, :ref:`Training <ref_trainings:Model Trainings>`, :ref:`Packager <ref_packagers:Model Packagers>`, and :ref:`Model Deployment <ref_deployments:Model Deployments>`.

- Odahu-infra:
    We created the new `odahu-infra <https://github.com/odahu/odahu-infra>`_ Git repository, where we placed the following infra custom helm charts: Fluentd, Knative, monitoring, Open Policy Agent, Tekton.

- Preemptible nodes:
    Preemptible nodes are priced lower than standard virtual machines of the same types.
    But they provide no availability guarantees.
    We added new deployment options to allow training and packaging pods to be deployed on preemptible nodes.

- Third-parties updates:
    * Istio
    * Grafana
    * Prometheus
    * MLFlow
    * Terraform
    * Buildah
    * Kubernetes

Misc/Internal
"""""""""""""

- Google Cloud Registry:
    We have experienced multiple problems while using Nexus as a main dev Docker registry.
    This migration also brings us additional advantages, such as in-depth vulnerability scanning.

- Terragrunt:
    We switched to using Terragrunt for our deployment scripts.
    That allows reducing the complexity of our terraform modules and deployment scripts.
