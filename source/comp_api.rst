.. _api-server-description:

===
API
===

:term:`API service` manages Odahu Platform entities.

- :term:`Connections <Connection>`
- :term:`Trainings <Train>`
- :term:`Packaging <Package>`
- :term:`Deployments <Deploy>`

:term:`API service` can provide the following data, when queried:

- Model Train and Deploy logs
- Model :term:`Trainer Metrics`
- Model :term:`Trainer Tags`

API-provided URLs
--------------------------

All information about URLs that :term:`API service` provides can be viewed using the auto-generated, interactive Swagger page. It is located at ``<api-address>/swagger/index.html``.
You can read all of the up-to-date documentation and invoke all methods (allowed for your account) right from this web page.

Authentication and authorization
--------------------------------

:term:`API service` distributed in :ref:`odahu-flow-core helm chart <gen_distros:Distributions>` with enabled authorization
and pre-defined OPA policies. If :ref:`Security Subsystem <comp_security:Security-subsystem>` is installed then all requests to api service will be
enforced using :ref:`pre-defined OPA policies <gen_security:ODAHU API and Feedback aggregator policies>`.


Implementation details
----------------------

:term:`API service` is a REST server, written in GoLang. For easy integration, it provides a Swagger endpoint with up-to-date protocol information.

.. csv-table::
   :stub-columns: 1
   :width: 100%

    "Technologies used", "GoLang"
    "Distribution representation", "Docker Image"
    "Source code location", "`packages/operator <https://github.com/odahu/odahu-flow/tree/develop/packages/operator>`_"
    "Can be used w/o Odahu Platform?", "Yes"
    "Does it connect to other services?", "Yes (Kubernetes API)"
    "Can it be deployed locally?", "If a local Kubernetes cluster is present"
    "Does it provide any interface?", "Yes (HTTP REST API)"
