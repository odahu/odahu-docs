
======================
Feedback aggregator
======================

:term:`Feedback aggregator` is a service that provides a :term:`Model Feedback API` and gathers input and output
:term:`prediction requests <Model prediction API>`

API-provided URLs
--------------------------

:term:`Model Feedback API` provide just single endpoint that
allow you send feedback on a :term:`prediction request <Model prediction API>`:

`POST /api/v1/feedback`

Information about this URL can be viewed using the auto-generated, interactive Swagger page. It is located at ``<api-address>/swagger/index.html``.
You can read all of the up-to-date documentation and invoke this endpoint (allowed for your account) right from this web page.

Authentication and authorization
--------------------------------

:term:`Feedback aggregator` distributed in :ref:`odahu-flow-core helm chart <gen_distros:Distributions>` with enabled authorization
and pre-defined OPA policies. If :ref:`Security Subsystem <comp_security:Security-subsystem>` is installed then all requests
to :term:`Model Feedback API` service will be enforced using :ref:`pre-defined OPA policies <gen_security:ODAHU API and Feedback aggregator policies>`.

Implementation details
----------------------

:term:`Feedback aggregator` contains two major subcomponents

- REST Server that provides :term:`Model Feedback API` and send them to configured fluentd server
- Envoy Proxy tap filter that catch all requests and response of deployed models and send this info
  to configured fluentd server

.. csv-table::
   :stub-columns: 1
   :width: 100%

    "Technologies used", "GoLang, Envoy Proxy"
    "Distribution representation", "Docker Image"
    "Source code location", "`packages/operator <https://github.com/odahu/odahu-flow/tree/develop/packages/feedback>`_"
    "Can be used w/o Odahu Platform?", "No"
    "Does it connect to other services?", "Yes (Fluentd, Envoy Proxy)"
    "Can it be deployed locally?", "If a local Kubernetes cluster is present"
    "Does it provide any interface?", "Yes (HTTP REST API)"
