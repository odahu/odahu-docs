
######################
Airflow
######################

Odahu-flow provides a set of custom operators that allow you to interact with a Odahu cluster using `Apache Airflow <https://airflow.apache.org/>`_


***********************
Connections
***********************

The Airflow plugin should be authorized by Odahu. Authorization is implemented using regular `Airflow Connections <https://airflow.apache.org/concepts.html#connections>`_

All custom Odahu-flow operators accept `api_connection_id` as a parameter that refers to `Odahu-flow Connection`

Odahu-flow Connection
================
The Odahu connection provides access to a Odahu cluster for Odahu custom operators.

Configuring the Connection
--------------------------
Host (required)
    The host to connect to. Usually available at: `odahu.<cluster-base-url>`

Type (required)
    `HTTP`

Schema (optional)
    `https`

Login (not required)
    Leave this field empty

Password (required)
    The client secret. The client MAY omit the parameter if the client secret is an empty string. `See more <https://tools.ietf.org/html/rfc6749#section-2.3.1>`_

Extra (Required)
    Specify the extra parameters (as json dictionary) that can be used in Odahu
    connection. Because Odahu uses OpenID authorization, additional OpenID/OAuth 2.0 parameters may be supplied here.

    The following parameters are supported and must be defined:

    * **auth_url**: url of `authorization server <https://tools.ietf.org/html/rfc6749#section-1.1>`_
    * **client_id**: The client identifier issued to the client during the registration process. `See more <https://tools.ietf.org/html/rfc6749#section-2.3.1>`_
    * **scope**: `Access Token Scope <https://tools.ietf.org/html/rfc6749#section-3.3>`_

    Example "extras" field:

    .. code-block:: json

       {
          "auth_url": "https://keycloak.<my-app-domain>",
          "client_id": "my-app",
          "scope": "openid profile email offline_access groups",
       }


***********************
Custom operators
***********************

This chapter describes the custom operators provided by Odahu.


Train, Pack, Deploy operators
================================

.. class:: TrainingOperator(training=None, api_connection_id=None, *args, **kwargs)

    The operator that runs :term:`Train` phase

    Use `args` and `kwargs` to override other operator parameters

    :param odahuflow.sdk.models.ModelTraining training: describes the :term:`Train` phase
    :param str api_connection_id: conn_id of :ref:`int_airflow:Odahu-flow Connection`


.. class:: TrainingSensor(training_id=None, api_connection_id=None, *args, **kwargs)

    The operator that waits for :term:`Train` phase is finished

    Use `args` and `kwargs` to override other operator parameters

    :param str training_id: `Train` id waits for
    :param str api_connection_id: conn_id of :ref:`int_airflow:Odahu-flow Connection`


.. class:: PackagingOperator(packaging=None, \
                             api_connection_id=None, \
                             trained_task_id: str = "", \
                             *args, **kwargs)

    The operator that runs :term:`Package` phase

    Use `args` and `kwargs` to override other operator parameters

    :param odahuflow.sdk.models.ModelPackaging packaging: describes the :term:`Package` phase
    :param str api_connection_id: conn_id of :ref:`int_airflow:Odahu-flow Connection`
    :param str trained_task_id: finished task id of TrainingSensor


.. class:: PackagingSensor(training_id=None, api_connection_id=None, *args, **kwargs)

    The operator that waits for :term:`Package` phase is finished

    Use `args` and `kwargs` to override other operator parameters

    :param str packaging_id: `Package` id waits for
    :param str api_connection_id: conn_id of :ref:`int_airflow:Odahu-flow Connection`


.. class:: DeploymentOperator(deployment=None, api_connection_id=None, *args, **kwargs)

    The operator that runs :term:`Deploy` phase

    Use `args` and `kwargs` to override other operator parameters

    :param odahuflow.sdk.models.ModelDeployment packaging: describes the :term:`Deploy` phase
    :param str api_connection_id: conn_id of :ref:`int_airflow:Odahu-flow Connection`
    :param str packaging_task_id: finished task id of PackagingSensor


.. class:: DeploymentSensor(training_id=None, api_connection_id=None, *args, **kwargs)

    The operator that waits for :term:`Deploy` phase is finished

    Use `args` and `kwargs` to override other operator parameters

    :param str deployment_id: `Deploy` id waits for
    :param str api_connection_id: conn_id of :ref:`int_airflow:Odahu-flow Connection`


Model usage operators
================================

These operators are used to interact with deployed models.

.. class:: ModelInfoRequestOperator(self, \
                                    model_deployment_name: str, \
                                    api_connection_id: str, \
                                    model_connection_id: str, \
                                    md_role_name: str = "", \
                                    *args, **kwargs)

    The operator what extract metadata of deployed model.

    Use `args` and `kwargs` to override other operator parameters

    :param str model_deployment_name: Model deployment name
    :param str api_connection_id: conn_id of :ref:`int_airflow:Odahu-flow Connection`
    :param str model_connection_id: id of Odahu :term:`Connection` for deployed model access
    :param str md_role_name: Role name


.. class:: ModelPredictRequestOperator(self, \
                                       model_deployment_name: str, \
                                       api_connection_id: str, \
                                       model_connection_id: str, \
                                       request_body: typing.Any, \
                                       md_role_name: str = "" , \
                                       *args, **kwargs)

    The operator request prediction using deployed model.

    Use `args` and `kwargs` to override other operator parameters

    :param str model_deployment_name: <paste>
    :param str api_connection_id: conn_id of :ref:`int_airflow:Odahu-flow Connection`
    :param str model_connection_id: id of Odahu :term:`Connection` for deployed model access
    :param dict request_body: JSON Body with model parameters
    :param str md_role_name: Role name


Helper operators
================================

These operators are helpers to simplify using Odahu-flow.

.. class:: GcpConnectionToOdahuConnectionOperator(self, \
                                                   api_connection_id: str, \
                                                   google_cloud_storage_conn_id: str, \
                                                   conn_template: typing.Any, \
                                                   *args, **kwargs)

    Create Odahu-flow Connection using GCP Airflow Connection

    Use `args` and `kwargs` to override other operator parameters

    :param str api_connection_id: conn_id of :ref:`int_airflow:Odahu-flow Connection`
    :param str google_cloud_storage_conn_id: conn_id to Gcp Connection
    :param odahuflow.sdk.models.connection.Connection conn_template: Odahu-flow Connection template


****************************
How to describe operators
****************************

When you initialize Odahu custom operators such as ``TrainingOperator``, ``PackagingOperator``, or
``DeploymentOperator`` you should pass odahu resource payload as a parameter.

Actually, this is a payload that describes a resource that will be created at Odahu-flow cluster. You should describe
such payloads using odahuflow.sdk models

.. code-block:: python
    :caption: Creating training payload

    training = ModelTraining(
        id=training_id,
        spec=ModelTrainingSpec(
            model=ModelIdentity(
                name="wine",
                version="1.0"
            ),
            toolchain="mlflow",
            entrypoint="main",
            work_dir="mlflow/sklearn/wine",
            hyper_parameters={
                "alpha": "1.0"
            },
            data=[
                DataBindingDir(
                    conn_name='wine',
                    local_path='mlflow/sklearn/wine/wine-quality.csv'
                ),
            ],
            resources=ResourceRequirements(
                requests=ResourceList(
                    cpu="2024m",
                    memory="2024Mi"
                ),
                limits=ResourceList(
                    cpu="2024m",
                    memory="2024Mi"
                )
            ),
            vcs_name="odahu-flow-examples"
        ),
    )


But if you did some RnD work with Odahu-flow previously, it's likely that you already have yaml/json files that
describe the same payloads. You can reuse them to create odahuflow.sdk models automatically

.. code-block:: python
    :caption: Using plain yaml/json text

    from odahuflow.airflow.resources import resource

    packaging_id, packaging = resource("""
    id: airlfow-wine
    kind: ModelPackaging
    spec:
      artifactName: "<fill-in>"
      targets:
        - connectionName: docker-ci
          name: docker-push
      integrationName: docker-rest
    """)

Or refer to yaml/json files that must be located at Airflow DAGs folder or Airflow Home folder (these folders are
configured at airflow.cfg file)

.. code-block:: python
    :caption: Creating training payload

    from odahuflow.airflow.resources import resource
    training_id, training = resource('training.odahuflow.yaml')

In this file, we refer to file `training.odahuflow.yaml` that is located at airflow dag's folder

For example, if you use `Google Cloud Composer <https://cloud.google.com/composer/>`_ then you can locate your yamls inside DAGs bucket and refer to them by
relative path:

.. code:: bash

    gsutil cp ~/.training.odahuflow.yaml gs://<your-composer-dags-bucket>/



DAG example
================================

The example of the DAG that uses custom Odahu-flow operators is shown below. Four DAGs are described.


.. code-block:: python
    :caption: dag.py
    :name: Usage example
    :linenos:
    :emphasize-lines: 190-193

    from datetime import datetime
    from airflow import DAG
    from airflow.contrib.operators.gcs_to_gcs import GoogleCloudStorageToGoogleCloudStorageOperator
    from airflow.models import Variable
    from airflow.operators.bash_operator import BashOperator
    from odahuflow.sdk.models import ModelTraining, ModelTrainingSpec, ModelIdentity, ResourceRequirements, ResourceList, \
        ModelPackaging, ModelPackagingSpec, Target, ModelDeployment, ModelDeploymentSpec, Connection, ConnectionSpec, \
        DataBindingDir

    from odahuflow.airflow.connection import GcpConnectionToOdahuConnectionOperator
    from odahuflow.airflow.deployment import DeploymentOperator, DeploymentSensor
    from odahuflow.airflow.model import ModelPredictRequestOperator, ModelInfoRequestOperator
    from odahuflow.airflow.packaging import PackagingOperator, PackagingSensor
    from odahuflow.airflow.training import TrainingOperator, TrainingSensor

    default_args = {
        'owner': 'airflow',
        'depends_on_past': False,
        'start_date': datetime(2019, 9, 3),
        'email_on_failure': False,
        'email_on_retry': False,
        'end_date': datetime(2099, 12, 31)
    }

    api_connection_id = "odahuflow_api"
    model_connection_id = "odahuflow_model"

    gcp_project = Variable.get("GCP_PROJECT")
    wine_bucket = Variable.get("WINE_BUCKET")

    wine_conn_id = "wine"
    wine = Connection(
        id=wine_conn_id,
        spec=ConnectionSpec(
            type="gcs",
            uri=f'gs://{wine_bucket}/data/wine-quality.csv',
            region=gcp_project,
        )
    )

    training_id = "airlfow-wine"
    training = ModelTraining(
        id=training_id,
        spec=ModelTrainingSpec(
            model=ModelIdentity(
                name="wine",
                version="1.0"
            ),
            toolchain="mlflow",
            entrypoint="main",
            work_dir="mlflow/sklearn/wine",
            hyper_parameters={
                "alpha": "1.0"
            },
            data=[
                DataBindingDir(
                    conn_name='wine',
                    local_path='mlflow/sklearn/wine/wine-quality.csv'
                ),
            ],
            resources=ResourceRequirements(
                requests=ResourceList(
                    cpu="2024m",
                    memory="2024Mi"
                ),
                limits=ResourceList(
                    cpu="2024m",
                    memory="2024Mi"
                )
            ),
            vcs_name="odahu-flow-examples"
        ),
    )

    packaging_id = "airlfow-wine"
    packaging = ModelPackaging(
        id=packaging_id,
        spec=ModelPackagingSpec(
            targets=[Target(name="docker-push", connection_name="docker-ci")],
            integration_name="docker-rest"
        ),
    )

    deployment_id = "airlfow-wine"
    deployment = ModelDeployment(
        id=deployment_id,
        spec=ModelDeploymentSpec(
            min_replicas=1,
        ),
    )

    model_example_request = {
        "columns": ["alcohol", "chlorides", "citric acid", "density", "fixed acidity", "free sulfur dioxide", "pH",
                    "residual sugar", "sulphates", "total sulfur dioxide", "volatile acidity"],
        "data": [[12.8, 0.029, 0.48, 0.98, 6.2, 29, 3.33, 1.2, 0.39, 75, 0.66],
                 [12.8, 0.029, 0.48, 0.98, 6.2, 29, 3.33, 1.2, 0.39, 75, 0.66]]
    }

    dag = DAG(
        'wine_model',
        default_args=default_args,
        schedule_interval=None
    )

    with dag:
        data_extraction = GoogleCloudStorageToGoogleCloudStorageOperator(
            task_id='data_extraction',
            google_cloud_storage_conn_id='wine_input',
            source_bucket=wine_bucket,
            destination_bucket=wine_bucket,
            source_object='input/*.csv',
            destination_object='data/',
            project_id=gcp_project,
            default_args=default_args
        )
        data_transformation = BashOperator(
            task_id='data_transformation',
            bash_command='echo "imagine that we transform a data"',
            default_args=default_args
        )
        odahuflow_conn = GcpConnectionToOdahuConnectionOperator(
            task_id='odahuflow_connection_creation',
            google_cloud_storage_conn_id='wine_input',
            api_connection_id=api_connection_id,
            conn_template=wine,
            default_args=default_args
        )

        train = TrainingOperator(
            task_id="training",
            api_connection_id=api_connection_id,
            training=training,
            default_args=default_args
        )

        wait_for_train = TrainingSensor(
            task_id='wait_for_training',
            training_id=training_id,
            api_connection_id=api_connection_id,
            default_args=default_args
        )

        pack = PackagingOperator(
            task_id="packaging",
            api_connection_id=api_connection_id,
            packaging=packaging,
            trained_task_id="wait_for_training",
            default_args=default_args
        )

        wait_for_pack = PackagingSensor(
            task_id='wait_for_packaging',
            packaging_id=packaging_id,
            api_connection_id=api_connection_id,
            default_args=default_args
        )

        dep = DeploymentOperator(
            task_id="deployment",
            api_connection_id=api_connection_id,
            deployment=deployment,
            packaging_task_id="wait_for_packaging",
            default_args=default_args
        )

        wait_for_dep = DeploymentSensor(
            task_id='wait_for_deployment',
            deployment_id=deployment_id,
            api_connection_id=api_connection_id,
            default_args=default_args
        )

        model_predict_request = ModelPredictRequestOperator(
            task_id="model_predict_request",
            model_deployment_name=deployment_id,
            api_connection_id=api_connection_id,
            model_connection_id=model_connection_id,
            request_body=model_example_request,
            default_args=default_args
        )

        model_info_request = ModelInfoRequestOperator(
            task_id='model_info_request',
            model_deployment_name=deployment_id,
            api_connection_id=api_connection_id,
            model_connection_id=model_connection_id,
            default_args=default_args
        )

        data_extraction >> data_transformation >> odahuflow_conn >> train
        train >> wait_for_train >> pack >> wait_for_pack >> dep >> wait_for_dep
        wait_for_dep >> model_info_request
        wait_for_dep >> model_predict_request


In this file, we create four dags:

- DAG on line 190 extract and transform data, create Odahu-flow connection and run :term:`Train`
- DAG on line 191 sequentially run phases :term:`Train`, :term:`Package`, :term:`Deploy`
- DAG on line 192 wait for model deploy and then extract schema of model predict API
- DAG on line 193 wait for model deploy and then invoke model prediction API
