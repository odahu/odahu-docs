######################
Model Trainings
######################

.. image:: img/training.png

The Odahu-flow Model Training API provides features to manage remote training jobs.
The primary goal of API is to create a :term:`Trained Model Binary` for a :term:`Packager`.
The API is pluggable and can be extended for different ML frameworks.

You can find the list of out-of-the-box trainers below:

    * :ref:`ref_trainings:MLFlow`

********************************************
General training structure
********************************************

.. code-block:: yaml
    :caption: Training API

    kind: ModelTraining
    # Some unique value among all trainings. if not, the training with the same name will be overwritten.
    # Id must:
    #  * contain at most 63 characters
    #  * contain only lowercase alphanumeric characters or ‘-’
    #  * start with an alphanumeric character
    #  * end with an alphanumeric character
    id: wine-12345
    spec:
      model:
        # Human-readable model name
        name: wine
        # Human-readable model version
        version: 3.0
        # Optionally, you can specify template for output artifact
        # The default value is {{ .Name }}-{{ .Version }}-{{ .RandomUUID }}.zip
        # where:
        #   Name - spec.model.name
        #   Version - spec.model.version
        #   RandomUUID - a random UUID v4, for example be17d12d-df43-4588-99e7-56a0db3cad77
        artifactNameTemplate: {{ .Name }}-{{ .Version }}-{{ .RandomUUID }}.zip
      # The toolchain parameter is a point of extension for different ML frameworks.
      # For now, we only support the Mlfow toolchain
      toolchain: mlflow
      # Mlflow MLProject file contains the list of entrypoints. You must choose one of those.
      entrypoint: main
      # Working directory inside a training (docker) container, which GIT repository copied in.
      workDir: work/dir
      # The training data for a ML script. You can find full description there: https://docs.odahu.org/ref_trainings.html#training-data
      data:
          # You can specify a connection name
        - connName: wine
          # Path to a file or a dir where data will copy from a bucket; relative to your Git repository root derictory.
          localPath: mlflow/wine-quality/
          # Path to the dir or file in a bucket
          # Optional. If it is missing then the path from connection will be used.
          remotePath: training-data/
      # You can specify the map of hyperparameters
      hyperParameters:
        key: value
        var2: test
      # Compute resources for the training job.
      resources:
        limits:
          cpu: 1
          memory: 1Gi
        requests:
          cpu: 1
          memory: 1Gi
      # Custom environment variables that should be set before entrypoint invocation.
      envs:
          # The name of variable
        - name: TEST_ENV_KEY
          # The value of variable
          value: TEST_ENV_VALUE
      # A Docker image where the training will be launched.
      # By default, the image from a toolchain is used.
      # image: python:3.8
      # A connection which describes credentials to a GIT repository
      vcsName: <git-connection>
      # Git reference (branch or tag)
      # This must be specified here OR in Git connection itself
      reference: master
    status:
      # One of the following states: scheduling, running, succeeded, failed, unknown
      state: running
      # List of training results
      artifacts:
          # Mlflow run ID
        - runId: 12345678
          # Trained artifact name
          artifactName: wine-10.zip
          # VCS commit ID
          commitID: d3d6e8ed776ed37fd2efd7a1b8d5fabdd7e3eea5

********************************************
Training data
********************************************

Odahu-flow allows downloading data from various sources to the local file system of a training job.
Data source supports the following types of Odahu-flow connections:

    * :ref:`ref_connections:S3`
    * :ref:`ref_connections:Google Cloud Storage`
    * :ref:`ref_connections:Azure Blob storage`

Let's consider the following example of downloading training data from Google Cloud Storage.

Prerequisites:
    * The training data set is located in the `wine-training-data` bucket by `wine/11-11-2011/` directory.
    * The ML script expects that the data will be located in the training (docker) container by `data/` directory relative to the root git directory.

First of all, we should create an :ref:`Odahu-flow GCS connection<ref_connections:Google Cloud Storage>`.

.. code-block:: yaml
    :caption: Training Data GCS:

    id: "wine-training-data-conn"
    spec:
        type: gcs
        uri: gsc://wine-training-data/
        keySecret: '{"type": "service_account", "project_id": "project_id", "private_key_id": "private_key_id", "private_key": "-----BEGIN PRIVATE KEY-----\nprivate_key\n-----END PRIVATE KEY-----\n", "client_email": "test@project_id.iam.gserviceaccount.com", "client_id": "123455678", "auth_uri": "https://accounts.google.com/o/oauth2/auth", "token_uri": "https://oauth2.googleapis.com/token", "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs", "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/test@project_id.iam.gserviceaccount.com"}'
        description: "Training data for a model"
        region: us-central2

Finally, we provide a data section of Model Training.

.. code-block:: yaml
    :caption: Example of Connection GCS:
    :name: Connection GCS file

    spec:
      data:
        - connName: wine-training-data-conn
          localPath: data/
          remotePath: wine/11-11-2011/

********************************************
GPU
********************************************

Odahu-flow supports model training on GPU nodes.

You can find more about GPU deployment configuration in the :ref:`installation guide <tutorials_installation:Kubernetes setup>`.

In order to provision a training container in the GPU node pool,
you must specify the GPU resource in the model training manifest.

.. code-block:: yaml
    :caption: Training on GPU

    kind: ModelTraining
    id: gpu-model
    spec:
      resources:
        limits:
          cpu: 1
          memory: 1Gi
          gpu: 1
        requests:
          cpu: 1
          memory: 1Gi

NVIDIA libraries will be mount by ODAHU to the training container.
But if you want to use a CUDA library, you should install it manually.

For example, you can add the following dependencies to a conda file: cudatoolkit-dev and cudatoolkit.

.. _training-model-dependencies-cache:

********************************************
Model Dependencies Cache
********************************************

ODAHU Flow downloads your dependencies on every model training launch.
You can experience the following troubles with this approach:
    * downloading and installation of some dependencies can take a long time
    * network errors during downloading dependencies

To overcome these and other problems, ODAHU Flow provides a way to specify
a prebuilt training Docker image with your dependencies.

.. note::

    If you have different versions of a library in your model сonda file and
    cache container, then the model dependency has a priority.
    It will be downloaded during model training.

First of all, you have to describe the Dockerfile:

    * Inherit from a release version of odahu-flow-mlflow-toolchain
    * Optionally, add install dependencies
    * Add a model conda file
    * Update the ``odahu_model`` conda environment.

.. code-block:: dockerfile
    :caption: Example of Dockerfile:
    :name: Example of Dockerfile

    FROM odahu/odahu-flow-mlflow-toolchain:1.1.0-rc11

    # Optionally
    # apt-get install -y wget

    ADD conda.yaml ./
    RUN conda env update -n ${ODAHU_CONDA_ENV_NAME} -f conda.yaml

Build the docker image:

.. code-block:: bash

    docker build -t training-model-cache:1.0.0 .

Push the docker image to a registry:

.. code-block:: bash

    docker push training-model-cache:1.0.0

Specify the image in a model training:

.. code-block:: yaml
    :caption: Training example

    kind: ModelTraining
    id: model-12345
    spec:
      image: training-model-cache:1.0.0
      ...

*********************
Trainings management
*********************

Trainings can be managed using the following ways.

Swagger UI
----------

ModelTraining and ToolchainIntegration are available on the Swagger UI at http://api-service/swagger/index.html URL.

Odahu-flow CLI
--------------

:ref:`ref_odahuflowctl:Odahuflowctl` supports the Training API.
You must be :ref:`logged in <ref_odahuflowctl:Login>` if you want to get access to the API.

Getting all trainings in json format:

.. code-block:: bash

    odahuflowctl train get --format json

Getting the model name of the trainings:

.. code-block:: bash

    odahuflowctl train get --id tensorflow-cli -o 'jsonpath=[*].spec.model.name'

* Creating a training from `train.yaml` file:

.. code-block:: bash

    odahuflowctl train create -f train.yaml
	
* Reruning a training from `train.yaml` file:

.. code-block:: bash

    odahuflowctl train edit -f train.yaml

* All training commands and documentation:

.. code-block:: bash

    odahuflowctl train --help

We also have local training:

.. code-block:: bash

    odahuflowctl local train --help

and can run trainings locally:

.. code-block:: bash

    odahuflowctl local train run --id [Model training ID] -d [Path to Odahu manifest files]

more information you can find at :ref:`Local Quickstart <tutorials_local_wine:id1>`

JupyterLab
----------

Odahu-flow provides the :ref:`int_jupyterlab_extension:JupyterLab extension` for interacting with Training API.

********************************************
MLFlow
********************************************

`MLflow <https://mlflow.org/docs/latest/index.html>`_ is library-agnostic. You can use it with any machine learning library, and in any programming language, since all functions are accessible through a REST API and CLI.

Installation
------------

The most straightforward way to install the MLFlow trainer on an Odahu Cluster is to deploy the `odahu-flow-mlflow` helm chart.
The helm chart registers the trainer in the API Odahu and deploys an `MLflow Tracking Server <https://www.mlflow.org/docs/latest/tracking.html#mlflow-tracking-servers>`_.
By default, the deployed MLflow Tracking Server is available at `https://cluster-url/mlflow` address.

.. code-block:: bash

    # Add the odahu-flow helm repository
    helm repo add odahu-flow 'https://raw.githubusercontent.com/odahu/odahu-helm/master/'
    helm repo update
    # Fill in the values for the chart or leave the default values
    helm inspect values odahu-flow/odahu-flow-mlflow --version 1.0.0 > values.yaml
    vim values.yaml
    # Deploy the helm chart
    helm install odahu-flow/odahu-flow-mlflow --name odahu-flow-mlflow --namespace odahu-flow --debug -f values.yaml --atomic --wait --timeout 120

.. warning::

    Odahu-flow must be deployed before the mlflow trainer.

MLProject file
--------------

Let's look at how the MLProject file is related to Model Training API.

.. code-block:: text

    name: My Project

    entry_points:
      main:
        parameters:
          data_file: path
          regularization: {type: float, default: 0.1}
        command: "python train.py -r {regularization} {data_file}"
      test:
        parameters:
          data_file: path
        command: "python validate.py {data_file}"

Model Training API can contain only one entry point.
You have to add all hyperparameters, which do not have a default value, to a Model Training.
Next, you can find the Model Trainings for the MLProject file.

.. code-block:: yaml

    spec:
      entrypoint: main
      hyperParameters:
        data_file: test/123.txt
        regularization: 0.2

.. code-block:: yaml

    spec:
      entrypoint: main
      hyperParameters:
        data_file: test/456.txt

.. code-block:: yaml

    spec:
      entrypoint: test
      hyperParameters:
        data_file: test/123.txt

MLFlow protocol
---------------

Odahu-flow requires that a model is logged through `mlflow API <https://www.mlflow.org/docs/latest/python_api/mlflow.pyfunc.html#mlflow.pyfunc.log_model>`_.

.. code-block:: python
    :caption: Example of sklearn model logging:

    mlflow.sklearn.log_model(lr, "model")

Optionally, you can provide input and output samples for Odahu-flow.
It allows determining input and output types for Odahu-flow packagers.
These names must be `head_input.pkl` and `head_output.pkl`, respectively.

.. code-block:: python
    :caption: Example of input and output samples logging:

    train_x.head().to_pickle('head_input.pkl')
    mlflow.log_artifact('head_input.pkl', 'model')
    train_y.head().to_pickle('head_output.pkl')
    mlflow.log_artifact('head_output.pkl', 'model')
