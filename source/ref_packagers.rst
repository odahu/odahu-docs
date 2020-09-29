######################
Model Packagers
######################

Odahu-flow packagers turn a :term:`Trained Model Binary` artifact into a specific application.
You can find the list of out-of-the-box packagers below:

    * :ref:`ref_packagers:Docker REST`
    * :ref:`ref_packagers:Docker CLI`

********************************************
Installation
********************************************

A packager installation is the creation of a new PackagingIntegration entity in the :term:`API service`.
The most straightforward way is to deploy the `odahu-flow-packagers` helm chart.

.. code-block:: bash

    # Add the odahu-flow helm repository
    helm repo add odahu-flow 'https://raw.githubusercontent.com/odahu/odahu-helm/master/'
    helm repo update
    # Fill in the values for the chart or leave the default values
    helm inspect values odahu-flow/odahu-flow-packagers --version 1.0.0-rc35 > values.yaml
    vim values.yaml
    # Deploy the helm chart
    helm install odahu-flow/odahu-flow-packagers --name odahu-flow-packagers --namespace odahu-flow --debug -f values.yaml --atomic --wait --timeout 120

.. warning::

    Odahu-flow must be deployed before the packagers installation.

********************************************
General packager structure
********************************************

All packagers have the same structure.
But different packagers provide a different set of arguments and targets.
You can find the description of all fields below:

.. code-block:: yaml
    :caption: Packager API
    :name: Packager API file

    kind: ModelPackaging
    # Unique value among all packagers
    # Id must:
    #  * contain at most 63 characters
    #  * contain only lowercase alphanumeric characters or ‘-’
    #  * start with an alphanumeric character
    #  * end with an alphanumeric character
    id: "id-12345"
    spec:
      # Type of a packager. Available values: docker-rest, docker-cli.
      integrationName: docker-rest
      # Training output artifact name
      artifactName: wine-model-123456789.zip
      # Compute resources
      resources:
        limits:
          cpu: 1
          memory: 1Gi
        requests:
          cpu: 1
          memory: 1Gi
      # List of arguments. Depends on a Model Packaging integration.
      # You can find specific values in the sections below.
      # This parameter is used for customizing a packaging process.
      arguments: {}
      # List of targets. Depends on a Model Packaging integration.
      # You can find specific values in the sections below.
      # A packager can interact with a Docker registry, PyPi repository, and so on.
      # You should provide a list of connections for a packager to get access to them.
      targets: []
      # You can set connection which points to some bucket where the Trained Model Binary is stored
      # then packager will extract your binary from this connection
      outputConnection: custom-connection
      # Node selector that exactly matches a node pool from ODAHU config
      # This is optional; when omitted, ODAHU uses any of available packaging node pools
      # Read more about node selector: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/
      nodeSelector:
        label: value
    # Every packager saves its results into status field.
    # Example of fields: docker image or python packager name.
    status:
      results:
        - name: some_param
          value: some_value

.. note::

    You can find an artifactName in the `status.artifactName` field of a model training entity.

*********************
Packagers management
*********************

Packagers can be managed using the following ways.

Swagger UI
----------

ModelPackaging and PackagingIntegration are available on the Swagger UI at http://api-service/swagger/index.html URL.

Odahu-flow CLI
--------------

:ref:`ref_odahuflowctl:Odahuflowctl` supports the Packagers API.
You must be :ref:`logged in <ref_odahuflowctl:Login>` if you want to get access to the API.

Getting all packaging in json format:

.. code-block:: bash

    odahuflowctl pack get --format json

Getting the arguments of the packagers:

.. code-block:: bash

    odahuflowctl pack get --id tensorflow-cli -o 'jsonpath=[*].spec.arguments'

* Creating of a packager from `pack.yaml` file:

.. code-block:: bash

    odahuflowctl pack create -f pack.yaml

* All commands and documentation for packager at Odahu cluster:

.. code-block:: bash

    odahuflowctl pack --help

We also have local packager:

.. code-block:: bash

    odahuflowctl local pack --help

and can run packaging locally:

.. code-block:: bash

    odahuflowctl local pack run --id [Model packaging ID] -d [Path to an Odahu manifest file]

more information you can find at :ref:`Local Quickstart <tutorials_local_wine:tutorial:id2>`

JupyterLab
----------

Odahu-flow provides the :ref:`int_jupyterlab_extension:JupyterLab extension` for interacting with Packagers API.

.. _packaging-model-dependencies-cache:

********************************************
Model Docker Dependencies Cache
********************************************

ODAHU Flow downloads your dependencies on every docker model packaging launch.
You can experience the following troubles with this approach:
    * downloading and installation of some dependencies can take a long time
    * network errors during downloading dependencies

To overcome these and other problems, ODAHU Flow provides a way to specify
a prebuilt packaging Docker image with your dependencies.

.. note::

    If you have different versions of a library in your model сonda file and
    cache container, then the model dependency has a priority.
    It will be downloaded during model packaging.

First of all, you have to describe the Dockerfile:

    * Inherit from a release version of odahu-flow-docker-packager-base
    * Optionally, add install dependencies
    * Add a model conda file
    * Update the ``odahu_model`` conda environment.

.. code-block:: dockerfile
    :caption: Example of Dockerfile:
    :name: Example of Dockerfile

    FROM odahu/odahu-flow-docker-packager-base:1.1.0-rc11

    # Optionally
    # RUN pip install gunicorn[gevent]

    ADD conda.yaml ./
    RUN conda env update -n ${ODAHU_CONDA_ENV_NAME} -f conda.yaml

Build the docker image:

.. code-block:: bash

    docker build -t packaging-model-cache:1.0.0 .

Push the docker image to a registry:

.. code-block:: bash

    docker push packaging-model-cache:1.0.0

Specify the image in a model packaging:

.. code-block:: yaml
    :caption: Packaging example

    kind: ModelPackaging
    id: model-12345
    spec:
      arguments:
        dockerfileBaseImage: packaging-model-cache:1.0.0
      ...

********************************************
Docker REST
********************************************

The Docker REST packager wraps an ML model into the REST service inside a Docker image.
The resulting service can be used for point prediction through HTTP.

The packager provides the following list of targets:

.. csv-table::
   :header: "Target Name", "Connection Types", "Required", "Description"
   :widths: 20, 20, 10, 100

   "docker-push", ":ref:`docker<ref_connections:Docker>`, :ref:`ecr<ref_connections:Amazon Elastic Container Registry>`", "True", "The packager will use the connection for pushing a Docker image result"
   "docker-pull", ":ref:`docker<ref_connections:Docker>`, :ref:`ecr<ref_connections:Amazon Elastic Container Registry>`", "False", "The packager will use the connection for pulling a custom base Docker image"

The packager provides the following list of arguments:

.. csv-table::
   :header: "Argument Name", "Type", "Default", "Required", "Description"
   :widths: 20, 20, 20, 10, 100

   "imageName", "string", "{{ Name }}-{{ Version }}:{{ RandomUUID }}", "False", "This option provides a way to specify the Docker image name. You can hardcode the full name or specify a template. Available template values: Name (Model Name), Version (Model Version), RandomUUID. Examples: myservice:123, {{ Name }}:{{ Version }}"
   "port", "integer", "5000", "False", "Port to bind"
   "timeout", "integer", "60", "False", "Serving timeout in seconds."
   "workers", "integer", "1", "False", "Count of serving workers"
   "threads", "integer", "4", "False", "Count of serving threads"
   "host", "string", "0.0.0.0", "False", "Host to bind"
   "dockerfileBaseImage", "string", "python:3.6", "False", "Base image for Dockerfile"

The packager provides the following list of result fields:

.. csv-table::
   :header: "Name", "Type", "Description"
   :widths: 20, 20, 100

   "image", "string", "The full name of a built Docker image"

Let's build a couple of examples of Docker REST packager.
The packager requires :ref:`docker<ref_connections:Docker>` or :ref:`ecr<ref_connections:Amazon Elastic Container Registry>` connection types.
The following example assumes that you have created a connection with `test-docker-registry` id and `gcr.io/project/odahuflow` URI.

.. code-block:: yaml
    :caption: Minimal Example of Docker REST packager
    :name: Minimal Example of Docker REST packager file

    id: "docker-rest-packager-example"
    spec:
        integrationName: docker-rest
        artifactName: wine-model-123456789.zip
        targets:
            - connectionName: test-docker-registry
              name: docker-push

Then a result of the packager will be something like this: "gcr.io/project/odahuflow/wine-0-1:ec1bf1cd-216d-4f0a-a62f-bf084c79c58c".

Now, let's try to change the docker image name and number of workers.

.. code-block:: yaml
    :caption: Docker REST packager with custom arguments
    :name: Docker REST packager with custom arguments file

    id: "docker-rest-packager-example"
    spec:
        integrationName: docker-rest
        artifactName: wine-model-123456789.zip
        targets:
            - connectionName: test-docker-registry
              name: docker-push
        arguments:
            imageName: "wine-test:prefix-{{ RandomUUID }}"
            workers: 4

.. code-block:: bash

    odahuflowctl pack get --id "docker-rest-packager-example" -o 'jsonpath=$[0].status.results[0].value'

Then a result of the packager will be something like this: "gcr.io/project/odahuflow/wine-test:prefix-ec1bf1cd-216d-4f0a-a62f-bf084c79c58c".

You can run the image locally using the following command:

.. code-block:: bash

    docker run -it --rm --net host gcr.io/project/odahuflow/wine-test:prefix-ec1bf1cd-216d-4f0a-a62f-bf084c79c58c

The model server provides two urls:

    * GET `/api/model/info` - provides a swagger documentation for a model
    * POST `/api/model/invoke` - executes a prediction

.. code-block:: bash

    curl http://localhost:5000/api/model/info
    curl -X POST -d '{"columns": ["features","features","features"], "data": [[1, 2, 3], [4, 5, 6]]}' -H "Content-Type: application/json" http://localhost:5000/api/model/invoke

.. code-block:: json
    :caption: Docker REST predict API
    :name: Docker REST predict API file

    {
      "columns": [
        "features",
        "features",
        "features"
      ],
      "data": [
        [
          1,
          2,
          3,
        ],
        [
          4,
          5,
          6,
        ]
      ]
    }

.. code-block:: json
    :caption: Docker REST prediction result
    :name: Docker REST prediction result file

    {
      "prediction": [
        [
          0.09405578672885895
        ],
        [
          0.01238546592343845
        ]
      ],
      "columns": [
        "predictions"
      ]
    }


********************************************
Docker CLI
********************************************

The Docker CLI packager wraps an ML model into the CLI inside a Docker image.
The resulting service can be used for batch prediction.

The packager provides the following list of targets:

.. csv-table::
   :header: "Target Name", "Connection Types", "Required", "Description"
   :widths: 20, 20, 10, 100

   "docker-push", ":ref:`docker<ref_connections:Docker>`, :ref:`ecr<ref_connections:Amazon Elastic Container Registry>`", "True", "The packager will use the connection for pushing a Docker image result"
   "docker-pull", ":ref:`docker<ref_connections:Docker>`, :ref:`ecr<ref_connections:Amazon Elastic Container Registry>`", "False", "The packager will use the connection for pulling a custom base Docker image"

The packager provides the following list of arguments:

.. csv-table::
   :header: "Argument Name", "Type", "Default", "Required", "Description"
   :widths: 20, 20, 20, 10, 100

   "imageName", "string", "{{ Name }}-{{ Version }}:{{ RandomUUID }}", "False", "This option provides a way to specify the Docker image name. You can hardcode the full name or specify a template. Available template values: Name (Model Name), Version (Model Version), RandomUUID. Examples: myservice:123, {{ Name }}:{{ Version }}"
   "dockerfileBaseImage", "string", "python:3.6", "False", "Base image for Dockerfile"

The packager provides the following list of result fields:

.. csv-table::
   :header: "Name", "Type", "Description"
   :widths: 20, 20, 100

   "image", "string", "The full name of a built Docker image"


Let's build a couple of examples of Docker CLI packager.
The packager requires :ref:`docker<ref_connections:Docker>` or :ref:`ecr<ref_connections:Amazon Elastic Container Registry>` connection types.
The following example assumes that you have created a connection with `test-docker-registry` id and `gcr.io/project/odahuflow` URI.

.. code-block:: yaml
    :caption: Minimal Example of Docker CLI packager
    :name: Minimal Example of Docker CLI packager file

    id: "docker-cli-packager-example"
    spec:
        integrationName: docker-cli
        artifactName: wine-model-123456789.zip
        targets:
            - connectionName: test-docker-registry
              name: docker-push

Then a result of the packager will be something like this: "gcr.io/project/odahuflow/wine-0-1:ec1bf1cd-216d-4f0a-a62f-bf084c79c58c".

Now, let's try to change the docker image name and the base image.

.. code-block:: yaml
    :caption: Docker CLI packager with custom arguments
    :name: Docker CLI packager with custom arguments file

    id: "docker-cli-packager-example"
    spec:
        integrationName: docker-cli
        artifactName: wine-model-123456789.zip
        targets:
            - connectionName: test-docker-registry
              name: docker-push
        arguments:
            imageName: "wine-test:prefix-{{ RandomUUID }}"
            dockerfileBaseImage: "python:3.7"

.. code-block:: bash

    odahuflowctl pack get --id "docker-cli-packager-example" -o 'jsonpath=$[0].status.results[0].value'

Then a result of the packager will be something like this: "gcr.io/project/odahuflow/wine-test:prefix-ec1bf1cd-216d-4f0a-a62f-bf084c79c58c".

You can run the image locally using the following command:

.. code-block:: bash

    docker run -it --rm --net host gcr.io/project/odahuflow/wine-test:prefix-ec1bf1cd-216d-4f0a-a62f-bf084c79c58c --help

The model CLI provides two commands:

    * `predict` - Make predictions using GPPI model
    * `info` - Show model input/output data schema

.. code-block:: bash
    :caption: Docker CLI info command

    docker run -it --rm --net host gcr.io/project/odahuflow/wine-test:prefix-ec1bf1cd-216d-4f0a-a62f-bf084c79c58c info

.. code-block:: text
    :caption: Docker CLI info command output

    Input schema:
    {
        "columns": {
            "example": [
                "features",
                "features",
                "features",
            ],
            "items": {
                "type": "string"
            },
            "type": "array"
        },
        "data": {
            "items": {
                "items": {
                    "type": "number"
                },
                "type": "array"
            },
            "type": "array",
            "example": [
                [
                    0,
                    0,
                    0,
                ]
            ]
        }
    }
    Output schema:
    {
        "prediction": {
            "example": [
                [
                    0
                ]
            ],
            "items": {
                "type": "number"
            },
            "type": "array"
        },
        "columns": {
            "example": [
                "predictions"
            ],
            "items": {
                "type": "string"
            },
            "type": "array"
        }
    }

Let's make a batch prediction.

.. code-block:: bash
    :caption: Create a predict file

    mkdir volume
    cat > volume/predicts.json <<EOL
    {
      "columns": [
        "features",
        "features",
        "features",
      ],
      "data": [
        [
          1,
          2,
          3
        ],
        [
          4,
          5,
          6
        ]
      ]
    }
    EOL
    docker run -it --rm --net -v volume:/volume host gcr.io/project/odahuflow/wine-test:prefix-ec1bf1cd-216d-4f0a-a62f-bf084c79c58c predict /volume/predicts.json /volume


.. code-block:: bash
    :caption: Result of prediction

    cat volumes/result.json
    {
      "prediction": [
        [
          0.09405578672885895
        ],
        [
          0.01238546592343845
        ]
      ],
      "columns": [
        "predictions"
      ]
    }
