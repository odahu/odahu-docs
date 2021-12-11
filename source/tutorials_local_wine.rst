
====================
Local Quickstart
====================

In this tutorial, we will walk through the training, packaging and serving of
a machine learning model locally by leveraging ODAHUFlow's main components.

~~~~~~~~~~~~~~~~~~~
Prerequisites
~~~~~~~~~~~~~~~~~~~

- Docker engine (at least version 17.0) with access from current user (`docker ps` should executes without errors)
- :term:`Odahu-flow CLI`
- git
- wget

~~~~~~~~~~~~~~~~~~~
Tutorial
~~~~~~~~~~~~~~~~~~~

We will consider the wine model from :ref:`Cluster Quickstart <tutorials_wine:Cluster Quickstart>`.
But now, we will train, package and deploy the model locally.

.. note::

   Code for the tutorial is available on `GitHub <https://github.com/odahu/odahu-examples/tree/master/mlflow/sklearn/wine>`_.

`odahuflowctl` has commands for local training and packaging.

.. code-block:: console

   $ odahuflowctl local --help

To train a model locally, you have to provide an ODAHU model training manifest and
training toolchain. `odahuflowctl` tries to find them on your local filesystem.
If it can not do it, then the CLI requests to ODAHU API.

.. code-block:: text
   :caption: Local training arguments:

     --train-id, --id TEXT        Model training ID  [required]
     -f, --manifest-file PATH     Path to a ODAHU-flow manifest file
     -d, --manifest-dir PATH      Path to a directory with ODAHU-flow manifests

The `mlflow/sklearn/wine/odahuflow` directory already contains training manifest file
for wine model. If we don't have a running ODAHUFlow API server, we should create
toolchain manifest manually.

Paste the toolchain manifest into the `mlflow/sklearn/wine/odahuflow/toolchain.yaml` file:

.. code-block:: yaml
   :name: Toolchain Integration

   kind: ToolchainIntegration
   id: mlflow
   spec:
     defaultImage: "odahu/odahu-flow-mlflow-toolchain:1.1.0-rc11"
     entrypoint: /opt/conda/bin/odahu-flow-mlflow-runner

We are ready to launch the local training. Copy, past and execute the following command.

.. code-block:: console

   $ odahuflowctl local train run -d mlflow/sklearn/wine/odahuflow --id wine

.. warning::

    MLFlow metrics does not propagate to the tracking server during training.
    This will be implemented in the near future.

`odahuflowctl` trains the model, verify that it satisfy the GPPI spec and save GPPI binary
in the host filesystem. Execute the following command to take a look at all trained models
in the default output directory.

.. code-block:: console

   $ odahuflowctl local train list

Our next step is to package the trained model to a REST service.
Like for local training, local packaging requires a model packaging and
packaging integration manifests.

.. code-block:: text
   :caption: Local packaging arguments:

     --pack-id, --id TEXT            Model packaging ID  [required]
     -f, --manifest-file PATH        Path to a ODAHU-flow manifest file
     -d, --manifest-dir PATH         Path to a directory with ODAHU-flow manifest files
     --artifact-path PATH            Path to a training artifact
     -a, --artifact-name TEXT        Override artifact name from file

Paste the packaging integration manifest into the `mlflow/sklearn/wine/odahuflow/packager.yaml` file:

.. code-block:: yaml
   :name: Packaging Integration

   kind: PackagingIntegration
   id: docker-rest
   spec:
     entrypoint: "/usr/local/bin/odahu-flow-pack-to-rest"
     defaultImage: "odahu/odahu-flow-packagers:1.1.0-rc11"
     privileged: true
     schema:
       targets:
         - name: docker-push
           connectionTypes: ["docker", "ecr"]
           required: true
         - name: docker-pull
           connectionTypes: ["docker", "ecr"]
           required: false
       arguments:
         properties:
           - name: dockerfileAddCondaInstallation
             parameters:
               - name: description
                 value: Add conda installation code to training.Dockerfile
               - name: type
                 value: boolean
               - name: default
                 value: true
           - name: dockerfileBaseImage
             parameters:
               - name: description
                 value: Base image for training.Dockerfile.
               - name: type
                 value: string
               - name: default
                 value: 'odahu/odahu-flow-docker-packager-base:1.1.0-rc11'
           - name: dockerfileCondaEnvsLocation
             parameters:
               - name: description
                 value: Conda env location in training.Dockerfile.
               - name: type
                 value: string
               - name: default
                 value: /opt/conda/envs/
           - name: host
             parameters:
               - name: description
                 value: Host to bind.
               - name: type
                 value: string
               - name: default
                 value: 0.0.0.0
           - name: port
             parameters:
               - name: description
                 value: Port to bind.
               - name: type
                 value: integer
               - name: default
                 value: 5000
           - name: timeout
             parameters:
               - name: description
                 value: Serving timeout in seconds.
               - name: type
                 value: integer
               - name: default
                 value: 60
           - name: workers
             parameters:
               - name: description
                 value: Count of serving workers.
               - name: type
                 value: integer
               - name: default
                 value: 1
           - name: threads
             parameters:
               - name: description
                 value: Count of serving threads.
               - name: type
                 value: integer
               - name: default
                 value: 4
           - name: imageName
             parameters:
               - name: description
                 value: |
                   This option provides a way to specify the Docker image name. You can hardcode the full name or specify a template. Available template values:
                     - Name (Model Name)
                     - Version (Model Version)
                     - RandomUUID
                   The default value is '{{ Name }}/{{ Version }}:{{ RandomUUID }}'.
                   Image name examples:
                     - myservice:123
                     - {{ Name }}:{{ Version }}
               - name: type
                 value: string
               - name: default
                 value: "{{ Name }}-{{ Version }}:{{ RandomUUID }}"

Choose the name of trained artifact and execute the following command:

.. code-block:: console

   $ odahuflowctl --verbose local pack run -d mlflow/sklearn/wine/odahuflow --id wine -a wine-1.0-wine-1.0-01-Mar-2020-18-33-35

The last lines of output must contains a name of model REST service.

At the last step, we run our REST service and make a predict.

.. code-block:: console

   $ docker run -it --rm -p 5000:5000 wine-1.0:cbf184d0-4b08-45c4-8efb-17e28a3b537e

.. code-block:: console

   $ odahuflowctl model invoke --url http://0:5000 --json-file mlflow/sklearn/wine/odahuflow/request.json

