####################################
Invoke ODAHU models for prediction
####################################

You want to call the model that was deployed on ODAHU programmatically

You can call ODAHU models using `REST API` or using `Python SDK`

Python SDK
===============

1. Install python SDK


.. code-block:: bash

   pip install odahu-flow-sdk


2. Configure SDK

By default SDK config is located in ~/.odahuflow/config

But you can override it location using `ODAHUFLOW_CONFIG` environment variable

Configure next values in the config

.. code-block:: ini

  [general]
  api_url = https://replace.your.models.host
  api_issuing_url = https://replace.your.oauth2.token.url


3. In python use ModelClient to invoke models

.. code-block:: bash

  from odahuflow.sdk.clients.model import ModelClient, calculate_url
  from odahuflow.sdk.clients.api import RemoteAPIClient
  from odahuflow.sdk import config

  # Change model deployment name to model name which you want to invoke
  MODEL_DEPLOYMENT_NAME = "<model-deployment-name>"

  # Get api token using client credentials flow via Remote client
  remote_api = RemoteAPIClient(client_id='<your-client-id>', client_secret='<your-secret>')
  remote_api.info()

  # Build model client and invoke models
  client = ModelClient(
      calculate_url(config.API_URL, model_deployment=MODEL_DEPLOYMENT_NAME),
      remote_api._token
  )

  # Get swagger specification of model service
  print(client.info())

  # Invoke model
  print(client.invoke(columns=['col1', 'col2'], data=[
      ['row1_at1', 'row1_at2'],
      ['row2_at1', 'row2_at2'],
  ]))


REST
=================

If you use another language you can use pure REST to invoke models

You should get token by yourself using OpenID provider and `OAuth2 Client Credentials Grant`_

Then call ODAHU next way

To get the swagger definition of model service

.. code-block:: bash

  curl -X GET "https://replace.your.models.host/model/${MODEL_DEPLOYMENT_NAME}/api/model/info" \
              -H "accept: application/json" \
              -H "Authorization: Bearer <token>"


To invoke the model

.. code-block:: bash

  curl -X POST "https://replace.your.models.host/model/${MODEL_DEPLOYMENT_NAME}/api/model/invoke" \
              -H "accept: application/json" \
              -H "Authorization: Bearer <token>" \
              -d @body.json


.. _`OAuth2 Client Credentials Grant`: https://tools.ietf.org/html/rfc6749#section-4.4
