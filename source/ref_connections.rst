######################
Connections
######################

Odahu needs to know how to connect to a bucket, git repository, and so on.
This kind of information is handled by Connection API.

********************************************
General connection structure
********************************************

All types of connections have the same general structure.
But different connections require a different set of fields.
You can find the examples of specific type of connection in the id of the :ref:`ref_connections:Connection types` section.
Below you can find the description of all fields:

.. code-block:: yaml
    :caption: Connection API
    :name: Connection API file

    kind: Connection
    # Unique value among all connections
    # Id must:
    #  * contain at most 63 characters
    #  * contain only lowercase alphanumeric characters or ‘-’
    #  * start with an alphanumeric character
    #  * end with an alphanumeric character
    id: "id-12345"
    spec:
        # Optionally description of a connection
        description: "Some description"
        # Optionally link to the web resource. For example, git repo or a gcp bucket
        webUILink: https://test.org/123
        # URI. It is a required value.
        uri: s3://some-bucket/path/file
        # Type of a connection. Available values: s3, gcs, azureblob, git, docker, ecr.
        type: s3
        # Username
        username: admin
        # Password, must be base64-encoded
        password: admin
        # Service account role
        role: some-role
        # AWS region or GCP project
        region: some region
        # VCS reference
        reference: develop
        # Key ID, must be base64-encoded
        keyID: "1234567890"
        # SSH or service account secret, must be base64-encoded
        keySecret: b2RhaHUK
        # SSH public key, must be base64-encoded
        publicKey: b2RhaHUK

*********************
Connection management
*********************

Connections can be managed using the following ways.

Swagger UI
----------

Swagger UI is available at http://api-service/swagger/index.html URL.

Odahu-flow CLI
--------------

:ref:`ref_odahuflowctl:Odahuflowctl` supports the connection API.
You must be :ref:`login <ref_odahuflowctl:Login>` if you want to get access to the API.

* Getting all connections in json format:

.. code-block:: bash

    odahuflowctl conn get --format json

* Getting the reference of the connection:

.. code-block:: bash

    odahuflowctl conn get --id odahu-flow-examples -o 'jsonpath=[*].spec.reference'

* Creating of a connection from `conn.yaml` file:

.. code-block:: bash

    odahuflowctl conn create -f conn.yaml

* All connection commands and documentation:

.. code-block:: bash

    odahuflowctl conn --help

JupyterLab
----------

Odahu-flow provides the JupyterLab extension for interacting with Connection API.

****************
Connection types
****************

For now, Odahu-flow supports the following connections types:

    * :ref:`ref_connections:S3`
    * :ref:`ref_connections:Google Cloud Storage`
    * :ref:`ref_connections:Azure Blob storage`
    * :ref:`ref_connections:GIT`
    * :ref:`ref_connections:Docker`
    * :ref:`ref_connections:Amazon Elastic Container Registry`

S3
--

An S3 connection allows interactions with `s3 API <https://docs.aws.amazon.com/en_us/AmazonS3/latest/dev/Welcome.html>`_.
This type of connection is used as storage of:
    * model trained artifacts.
    * input data for ML models.

.. note::

    You can use any S3 compatible API, for example minio or Ceph.

Before usage, make sure that:

    * You have created an AWS S3 bucket. `Examples of Creating a Bucket <https://docs.aws.amazon.com/en_us/AmazonS3/latest/dev/create-bucket-get-location-example.html>`_.
    * You have created an IAM user that has access to the AWS S3 bucket. `Creating an IAM User in Your AWS Account <https://docs.aws.amazon.com/en_us/IAM/latest/UserGuide/id_users_create.html>`_.
    * You have created the IAM keys for the user. `Managing Access Keys for IAM Users <https://docs.aws.amazon.com/en_us/IAM/latest/UserGuide/id_credentials_access-keys.html>`_.

.. note::

    At that moment, Odahu-flow only supports authorization though `IAM User <https://docs.aws.amazon.com/en_us/IAM/latest/UserGuide/id_users_create.html>`_.
    We will support AWS service role and authorization using temporary credentials in the near future.

The following fields of connection API are required:

    * ``spec.type`` - It must be equal **s3**.
    * ``spec.keyID`` - **base64-encoded** access key ID (for example, ``AKIAIOSFODNN7EXAMPLE``).
    * ``spec.keySecret`` - **base64-encoded** secret access key (for example, ``wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY``).
    * ``spec.uri`` -  S3 compatible URI, for example s3://<bucket-name>/dir1/dir2/
    * ``spec.region`` - `AWS Region <https://docs.aws.amazon.com/general/latest/gr/rande.html#s3_region>`_, where a bucket was created.

.. code-block:: yaml
    :caption: Example of Connection S3:
    :name: Connection S3 file

    kind: Connection
    id: "training-data"
    spec:
        type: s3
        uri: s3://raw-data/model/input
        # keyID before base64-encoding: AKIAIOSFODNN7EXAMPLE
        keyID: "QUtJQUlPU0ZPRE5ON0VYQU1QTEU="
        # keySecret before base64 encoding: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
        keySecret: "d0phbHJYVXRuRkVNSS9LN01ERU5HL2JQeFJmaUNZRVhBTVBMRUtFWQ=="
        description: "Training data for a model"
        region: eu-central-1

Google Cloud Storage
--------------------

`Google Cloud Storage <https://cloud.google.com/storage/docs/>`_ allows storing and accessing data on Google Cloud Platform infrastructure.
This type of connection is used as storage of:
    * model trained artifacts.
    * input data for ML models.

Before usage, make sure that:

    * You have created an GCS bucket. `Creating storage buckets <https://cloud.google.com/storage/docs/creating-buckets>`_.
    * You have created an service account. `Creating and managing service accounts <https://cloud.google.com/iam/docs/creating-managing-service-accounts#iam-service-accounts-create-gcloud>`_.
    * You have assigned ``roles/storage.objectAdmin`` role on the service account for the GCS bucket. `Using Cloud IAM permissions <https://cloud.google.com/storage/docs/access-control/using-iam-permissions>`_.
    * You have created the IAM keys for the service account. `Creating and managing service account keys <https://cloud.google.com/iam/docs/creating-managing-service-account-keys>`_.

.. note::

    Workload Identity is the recommended way to access Google Cloud services from within GKE due to its improved security properties and manageability.
    We will support the Workload Identity in the near future.

The following fields of connection API are required:

    * ``spec.type`` - It must be equal **gcs**.
    * ``spec.keySecret`` - **base64-encoded** service account key in json format.
    * ``spec.uri`` -  GCS compatible URI, for example gcs://<bucket-name>/dir1/dir2/
    * ``spec.region`` - `GCP Region <https://cloud.google.com/compute/docs/regions-zones>`_, where a bucket was created.

.. code-block:: yaml
    :caption: Example of Connection GCS:
    :name: Connection GCS file

    kind: Connection
    id: "training-data"
    spec:
        type: gcs
        uri: gsc://raw-data/model/input
        keySecret: ewogICAgInR5cGUiOiAic2VydmljZV9hY2NvdW50IiwKICAgICJwcm9qZWN0X2lkIjogInByb2plY3RfaWQiLAogICAgInByaXZhdGVfa2V5X2lkIjogInByaXZhdGVfa2V5X2lkIiwKICAgICJwcml2YXRlX2tleSI6ICItLS0tLUJFR0lOIFBSSVZBVEUgS0VZLS0tLS1cbnByaXZhdGVfa2V5XG4tLS0tLUVORCBQUklWQVRFIEtFWS0tLS0tXG4iLAogICAgImNsaWVudF9lbWFpbCI6ICJ0ZXN0QHByb2plY3RfaWQuaWFtLmdzZXJ2aWNlYWNjb3VudC5jb20iLAogICAgImNsaWVudF9pZCI6ICIxMjM0NTU2NzgiLAogICAgImF1dGhfdXJpIjogImh0dHBzOi8vYWNjb3VudHMuZ29vZ2xlLmNvbS9vL29hdXRoMi9hdXRoIiwKICAgICJ0b2tlbl91cmkiOiAiaHR0cHM6Ly9vYXV0aDIuZ29vZ2xlYXBpcy5jb20vdG9rZW4iLAogICAgImF1dGhfcHJvdmlkZXJfeDUwOV9jZXJ0X3VybCI6ICJodHRwczovL3d3dy5nb29nbGVhcGlzLmNvbS9vYXV0aDIvdjEvY2VydHMiLAogICAgImNsaWVudF94NTA5X2NlcnRfdXJsIjogImh0dHBzOi8vd3d3Lmdvb2dsZWFwaXMuY29tL3JvYm90L3YxL21ldGFkYXRhL3g1MDkvdGVzdEBwcm9qZWN0X2lkLmlhbS5nc2VydmljZWFjY291bnQuY29tIgp9
        description: "Training data for a model"
        region: us-central2


.. code-block:: json
    :caption: Original service account JSON key, that is used in the example above, before base64-encoding:
    :name: GCS service account key

    {
        "type": "service_account",
        "project_id": "project_id",
        "private_key_id": "private_key_id",
        "private_key": "-----BEGIN PRIVATE KEY-----\nprivate_key\n-----END PRIVATE KEY-----\n",
        "client_email": "test@project_id.iam.gserviceaccount.com",
        "client_id": "123455678",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/test@project_id.iam.gserviceaccount.com"
    }


Azure Blob storage
------------------

Odahu-flow uses the `Blob storage <https://docs.microsoft.com/ru-ru/azure/storage/blobs/storage-blobs-introduction>`_ in Azure to store:

    * model trained artifacts.
    * input data for ML models.

Before usage, make sure that:

    * You have created a storage account . `Create a storage account <https://docs.microsoft.com/en-us/azure/storage/blobs/storage-quickstart-blobs-cli#create-a-storage-account>`_.
    * You have created a storage container in the storage account . `Create a container <https://docs.microsoft.com/en-us/azure/storage/blobs/storage-quickstart-blobs-cli#create-a-container>`_.
    * You have created a SAS token. `Create an account SAS <https://docs.microsoft.com/en-us/rest/api/storageservices/create-account-sas>`_.

The following fields of connection API are required:

    * ``spec.type`` - It must be equal **azureblob**.
    * ``spec.keySecret`` - Odahu-flow uses the `shared access signatures <https://docs.microsoft.com/en-us/azure/storage/common/storage-sas-overview>`_ to authorize in Azure.
      The key has the following format: "<primary_blob_endpoint>/<sas_token>" and must be **base64-encoded**.
    * ``spec.uri`` -  Azure storage compatible URI, for example <bucket-name>/dir1/dir2/

.. code-block:: yaml
    :caption: Example of Connection Blob Storage:
    :name: Connection Blob Storage file

    kind: Connection
    id: "training-data"
    spec:
        type: azureblob
        uri: raw-data/model/input
        # keySecret before base64-encoding: https://myaccount.blob.core.windows.net/?restype=service&comp=properties&sv=2019-02-02&ss=bf&srt=s&st=2019-08-01T22%3A18%3A26Z&se=2019-08-10T02%3A23%3A26Z&sr=b&sp=rw&sip=168.1.5.60-168.1.5.70&spr=https&sig=F%6GRVAZ5Cdj2Pw4tgU7IlSTkWgn7bUkkAg8P6HESXwmf%4B
        keySecret: aHR0cHM6Ly9teWFjY291bnQuYmxvYi5jb3JlLndpbmRvd3MubmV0Lz9yZXN0eXBlPXNlcnZpY2UmY29tcD1wcm9wZXJ0aWVzJnN2PTIwMTktMDItMDImc3M9YmYmc3J0PXMmc3Q9MjAxOS0wOC0wMVQyMiUzQTE4JTNBMjZaJnNlPTIwMTktMDgtMTBUMDIlM0EyMyUzQTI2WiZzcj1iJnNwPXJ3JnNpcD0xNjguMS41LjYwLTE2OC4xLjUuNzAmc3ByPWh0dHBzJnNpZz1GJTZHUlZBWjVDZGoyUHc0dGdVN0lsU1RrV2duN2JVa2tBZzhQNkhFU1h3bWYlNEI=
        description: "Training data for a model"

GIT
---

Odahu-flow uses the GIT type connection to download a ML source code from a git repository.

The following fields of connection API are required:

    * ``spec.type`` - It must be equal **git**.
    * ``spec.keySecret`` - a base64 encoded SSH private key.
    * ``spec.uri`` -  GIT SSH URL, for example git@github.com:odahu/odahu-examples.git

``spec.reference`` must be provided either in a connection OR in a model training object (:ref:`ref_trainings:General training structure`).

Example of command to encode ssh key:

.. code-block:: bash

    cat ~/.ssh/id_rsa | base64 -w0

.. note::
    Odahu-flow only supports authorization through SSH.

.. warning::
    We recommend using the read-only deploy keys: `Github docs <https://github.blog/2015-06-16-read-only-deploy-keys/>`_ or `Gitlab docs <https://docs.gitlab.com/ee/ssh/#per-repository-deploy-keys>`_.

.. code-block:: yaml
    :caption: Example of GIT Connection:
    :name: GIT Connection

    kind: Connection
    id: "ml-repository"
    spec:
        type: git
        uri: git@github.com:odahu/odahu-examples.git
        keySecret: ClNVUEVSIFNFQ1JFVAoK
        reference: master
        description: "Git repository with the Odahu-Flow examples"
        webUILink: https://github.com/odahu/odahu-examples

Docker
------

This type of connection is used for pulling and pushing of the Odahu packager result Docker images to a Docker registry.
We have been testing the following Docker repositories:

    * `Docker Hub <https://docs.docker.com/docker-hub/>`_
    * `Nexus <https://help.sonatype.com/repomanager3/formats/docker-registry>`_
    * `Google Container Registry <https://cloud.google.com/container-registry/docs/>`_
    * `Azure Container Registry <https://docs.microsoft.com/en-in/azure/container-registry/container-registry-intro>`_

.. warning::
    Every docker registry has its authorization specificity.
    But you must be able to authorize by a username and password. Read the documentation.

Before usage, make sure that:

    * You have a username and password.

The following fields of connection API are required:

    * ``spec.type`` - It must be equal **docker**.
    * ``spec.username`` - docker registry username.
    * ``spec.password`` - **base64-encoded** docker registry password.
    * ``spec.uri`` - docker registry host.

.. warning::
    Connection URI must not contain a URI schema.

.. code-block:: yaml
    :caption: Example of GCR Docker connection
    :name: GCR docker connection file

    kind: Connection
    id: "docker-registry"
    spec:
        type: docker
        uri: gcr.io/project/odahuflow
        username: "_json"
        password: ewogICAgInR5cGUiOiAic2VydmljZV9hY2NvdW50IiwKICAgICJwcm9qZWN0X2lkIjogInByb2plY3RfaWQiLAogICAgInByaXZhdGVfa2V5X2lkIjogInByaXZhdGVfa2V5X2lkIiwKICAgICJwcml2YXRlX2tleSI6ICItLS0tLUJFR0lOIFBSSVZBVEUgS0VZLS0tLS1cbnByaXZhdGVfa2V5XG4tLS0tLUVORCBQUklWQVRFIEtFWS0tLS0tXG4iLAogICAgImNsaWVudF9lbWFpbCI6ICJ0ZXN0QHByb2plY3RfaWQuaWFtLmdzZXJ2aWNlYWNjb3VudC5jb20iLAogICAgImNsaWVudF9pZCI6ICIxMjM0NTU2NzgiLAogICAgImF1dGhfdXJpIjogImh0dHBzOi8vYWNjb3VudHMuZ29vZ2xlLmNvbS9vL29hdXRoMi9hdXRoIiwKICAgICJ0b2tlbl91cmkiOiAiaHR0cHM6Ly9vYXV0aDIuZ29vZ2xlYXBpcy5jb20vdG9rZW4iLAogICAgImF1dGhfcHJvdmlkZXJfeDUwOV9jZXJ0X3VybCI6ICJodHRwczovL3d3dy5nb29nbGVhcGlzLmNvbS9vYXV0aDIvdjEvY2VydHMiLAogICAgImNsaWVudF94NTA5X2NlcnRfdXJsIjogImh0dHBzOi8vd3d3Lmdvb2dsZWFwaXMuY29tL3JvYm90L3YxL21ldGFkYXRhL3g1MDkvdGVzdEBwcm9qZWN0X2lkLmlhbS5nc2VydmljZWFjY291bnQuY29tIgp9

.. code-block:: json
    :caption: Original service account JSON key, that is used in the example above, before base64-encoding:
    :name: GCS service account key

    {
        "type": "service_account",
        "project_id": "project_id",
        "private_key_id": "private_key_id",
        "private_key": "-----BEGIN PRIVATE KEY-----\nprivate_key\n-----END PRIVATE KEY-----\n",
        "client_email": "test@project_id.iam.gserviceaccount.com",
        "client_id": "123455678",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/test@project_id.iam.gserviceaccount.com"
    }


.. code-block:: yaml
    :caption: Example of Docker Hub
    :name: Connection Docker Hub file

    kind: Connection
    id: "docker-registry"
    spec:
        type: docker
        uri: docker.io/odahu/
        username: username
        # password before encoding: mypassword
        password: bXlwYXNzd29yZA===

Amazon Elastic Container Registry
---------------------------------

`Amazon Elastic Container Registry <https://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html>`_  is a managed AWS Docker registry.
This type of connection is used for pulling and pushing of the Odahu packager result Docker images.

.. note::
    The Amazon Docker registry does not support a long-lived credential and requires explicitly to create a repository for every image.
    These are the reasons why we create a dedicated type of connection for the ECR.

Before usage, make sure that:

    * You have created an ECR repository. `Creating an ECR Repository <https://docs.aws.amazon.com/AmazonECR/latest/userguide/repository-create.html>`_.
    * You have created an IAM user that has access to the ECR repository. `Creating an IAM User in Your AWS Account <https://docs.aws.amazon.com/en_us/IAM/latest/UserGuide/id_users_create.html>`_.
    * You have created the IAM keys for the user. `Managing Access Keys for IAM Users <https://docs.aws.amazon.com/en_us/IAM/latest/UserGuide/id_credentials_access-keys.html>`_.

The following fields of connection API are required:

    * ``spec.type`` - It must be equal **ecr**.
    * ``spec.keyID`` - **base64-encoded** access key ID (for example, ``AKIAIOSFODNN7EXAMPLE``).
    * ``spec.keySecret`` - **base64-encoded** secret access key (for example, ``wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY``).
    * ``spec.uri`` -  The url must have the following format, `aws_account_id`.dkr.ecr.`region`.amazonaws.com/`some-prefix`.
    * ``spec.region`` - `AWS Region <https://docs.aws.amazon.com/general/latest/gr/rande.html#s3_region>`_, where a docker registry was created.

.. code-block:: yaml
    :caption: Example of Connection ECR:
    :name: Connection ECR file

    kind: Connection
    id: "docker-registry"
    spec:
        type: ecr
        uri: 5555555555.dkr.ecr.eu-central-1.amazonaws.com/odahuflow
        # keyID before base64-encoding: "AKIAIOSFODNN7EXAMPLE"
        keyID: QUtJQUlPU0ZPRE5ON0VYQU1QTEU=
        # keySecret before base64-encoding: "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
        keySecret: d0phbHJYVXRuRkVNSS9LN01ERU5HL2JQeFJmaUNZRVhBTVBMRUtFWQ==
        description: "Packager registry"
        region: eu-central-1
