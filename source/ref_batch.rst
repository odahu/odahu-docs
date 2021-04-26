
###################
Batch Inference
###################

This section describes API and protocols related to Batch inference using ODAHU.

ODAHU Batch Inference feature allows user to get inferences using ML model for large datasets that are delivered asyncronously, not via
HTTP API, but through other mechanisms.

Currently Batch Inference supports the following ways to delivery data for forecasting:

- Object storage

  - GCS
  - S3
  - Azureblob

In future we consider to add ability to process data directly from Kafka topic and other async data sources.

Please also take a look at `example <https://github.com/odahu/odahu-examples/tree/1.5.0-rc4/batch-inference>`_.



**************
API Reference
**************


=================
InferenceService
=================

InferenceService represents the following required entities:

- Predictor docker image that contains predictor code
- Model files location on object storage (directory or .zip / .tar.gz archive)
- Command and Arguments that describe how to execute image

When a user trains a model then they should build an image with code that follows `Predictor code protocol`_ and register
this image as well as appropriate model files using ``InferenceService`` entity in ODAHU Platform.

User describes how inference should be triggered using different options in ``[].spec.triggers``.

.. openapi:: odahu-core-openapi.yaml
   :paths:
      /api/v1/batch/service


==================
InferenceJob
==================

``InferenceJob`` describes forecast process that was triggered by one of the triggers in ``InferenceService``.
If ``[].spec.triggers.webhook`` is enabled then its possible to run ``InferenceJob`` by making POST request as described
below. By default webhook trigger is enabled. Note, that currently its the only one way to trigger jobs.


.. openapi:: odahu-core-openapi.yaml
   :paths:
      /api/v1/batch/job



*********************************
Predictor code protocol
*********************************

ODAHU Platform launches docker image provided by user as ``[].spec.image`` (InferenceService_) and guarantees the
next conventions about input/model location inside container as well as format of input and output data.

==============
Env variables
==============

.. list-table:: Title
   :widths: 50 50
   :header-rows: 1

   * - Env variable
     - Description
   * - $ODAHU_MODEL
     - Path in local filesystem that contains all model files from ``[].spec.modelSource``
   * - $ODAHU_MODEL_INPUT
     - Path in local filesystem that contains all input files from ``[].spec.dataSource``
   * - $ODAHU_MODEL_OUTPUT
     - Path in local filesystem that will be uploaded to ``[].spec.outputDestination``

=========================
Input and output formats
=========================

Predictor code must expect input as set of JSON files with extensions ``.json`` located in folder that can be found
in ``$ODAHU_MODEL_INPUT`` environment variable. These JSON files have structure of
`Kubeflow inference request objects <https://github.com/kubeflow/kfserving/blob/v0.5.1/docs/predict-api/v2/required_api.md#inference-request-json-object>`_.


Predictor code must save results as set of JSON files with extension ``.json`` in the folder that can be found in ``$ODAHU_MODEL_INPUT`` environment variable.
These JSON files must have structure of
`Kubeflow inference response objects <https://github.com/kubeflow/kfserving/blob/v0.5.1/docs/predict-api/v2/required_api.md#inference-response-json-object>`_.



***********************
Implementation details
***********************

This section helps with deeper understanding of underlying mechanisms.


``InferenceJob`` is implemented as TektonCD TaskRun with 9 steps

  1. Configure rclone using ODAHU connections described in ``BatchInferenceService``
  2. Sync data input from object storage to local fs using rclone
  3. Sync model from object storage to local fs using rclone
  4. Validate input to `Predict Protocol - Version 2 <https://github.com/kubeflow/kfserving/blob/v0.5.1/docs/predict-api/v2/required_api.md#inference-request-json-object>`_
  5. Log Model Input to feedback storage
  6. Run user container with setting ``$ODAHU_MODEL``, ``$ODAHU_MODEL_INPUT``, ``$ODAHU_MODEL_OUTPUT``
  7. Validate output to `Predict Protocol - Version 2 <https://github.com/kubeflow/kfserving/blob/v0.5.1/docs/predict-api/v2/required_api.md#inference-response-json-object>`_
  8. Log Model Output to feedback storage
  9. Upload data from ``$ODAHU_MODEL_OUTPUT`` to ``[].spec.outputDestination.path``

