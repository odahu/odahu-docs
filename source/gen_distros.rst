=============
Distributions
=============

HELM charts
-----------

- Release and pre-release :term:`Helm charts <Odahu HELM Chart>` are in `github <https://github.com/odahu/odahu-helm>`_.

.. csv-table::
   :header: "Helm chart name", "Repository", "Description"
   :widths: 20, 30, 40

   "odahu-flow-fluentd", "odahu/odahu-automation", "Fluentd with gcp, s3 and abs plugins"
   "odahu-flow-k8s-gke-saa", "odahu/odahu-automation", "GKE role assigner"
   "odahu-flow-knative", "odahu/odahu-automation", "Custom knative chart"
   "odahu-flow-monitoring", "odahu/odahu-automation", "Prometheus, grafana and alertmanager"
   "odahu-flow-tekton", "odahu/odahu-automation", "Custom tekton chart"
   "odahu-flow-core", "odahu/odahu-flow", "Core Odahu-flow services"
   "odahu-flow-jupyterlab", "odahu/odahu-flow-jupyterlab-plugin", "Jupyterlab with the Odahu-flow plugin"
   "odahu-flow-mlflow", "odahu/odahu-trainer", "Odahu-flow mlflow toolchain"
   "odahu-flow-rest-packager", "odahu/odahu-packager", "Odahu-flow REST packager"

Docker Images
-------------

 Release versions of images are on Docker Hub in the `odahu <https://hub.docker.com/u/odahu>`_ team.

.. csv-table::
   :header: "Image name", "Repository", "Description"
   :widths: 20, 30, 40

   "odahu-flow-automation", "odahu/odahu-automation", "CI/CD pipeline component (not used by Odahu cluster)"
   "odahu-flow-fluentd", "odahu/odahu-automation", "Fluentd with gcp, s3 and abs plugins"
   "odahu-flow-api", "odahu/odahu-flow", "Odahu-flow API service"
   "odahu-flow-model-cli", "odahu/odahu-flow", "Odahu-flow CLI"
   "odahu-flow-model-trainer", "odahu/odahu-flow", "Trainer helper"
   "odahu-flow-model-packager", "odahu/odahu-flow", "Packager helper"
   "odahu-flow-service-catalog", "odahu/odahu-flow", "Swagger for model deployments"
   "odahu-flow-operator", "odahu/odahu-flow", "Odahu-flow kubernetes orchestrator"
   "odahu-flow-feedback-collector", "odahu/odahu-flow", "REST API for user feedback service"
   "odahu-flow-feedback-rq-catcher", "odahu/odahu-flow", "Model deployment request-response catcher"
   "odahu-flow-mlflow-toolchain", "odahu/odahu-trainer", "Odahu-flow mlflow toolchain"
   "odahu-flow-mlflow-toolchain-gpu", "odahu/odahu-trainer", "Odahu-flow mlflow toolchain with NVIDIA GPU"
   "odahu-flow-mlflow-tracking-server", "odahu/odahu-trainer", "MLflow tracking service"
   "odahu-flow-packagers", "odahu/odahu-packager", "Odahu-flow packagers"
   "odahu-flow-jupyterlab", "odahu/odahu-flow-jupyterlab-plugin", "Jupyterlab with the Odahu-flow plugin"

Python packages
---------------

- Release versions of Python packages are on PyPi in project `odahu <https://pypi.org/project/odahu/>`_.

.. csv-table::
   :header: "Package name", "Repository", "Description"
   :widths: 20, 30, 40

   "odahu-flow-cli", "odahu/odahu-flow", "Odahu-flow CLI"
   "odahu-flow-sdk", "odahu/odahu-flow", "Odahu-flow SDK"
   "odahu-flow-jupyterlab-plugin", "odahu/odahu-flow-jupyterlab-plugin", "Jupyterlab with the Odahu-flow plugin"
   "odahu-flow-airflow-plugin", "odahu/odahu-airflow-plugin", "Odahu-flow Airflow plugin(operators, hooks and so on)"

NPM packages
------------

- Release versions of Python packages are on npm in project odahu.

.. csv-table::
   :header: "Package name", "Repository", "Description"
   :widths: 20, 30, 40

   "odahu-flow-jupyterlab-plugin", "odahu/odahu-flow-jupyterlab-plugin", "Jupyterlab with the Odahu-flow plugin"
