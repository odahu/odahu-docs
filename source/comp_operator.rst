========
Operator
========

**Operator** monitors Odahu-provided Kubernetes (K8s)
`Custom Resources <https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/>`_.
This gives Operator the ability to manage Odahu entities using K8s infrastructure (Secrets, Pods, Services, etc).
The K8s entities that belong to Odahu are referred to as :term:`Odahu-flow's CRDs`.

Operator is a mandatory component in Odahu clusters.

Implementation details
----------------------------------

:term:`Operator` is a Kubernetes Operator, written using Kubernetes Go packages.

.. csv-table::
   :stub-columns: 1
   :width: 100%

    "Technologies used", "GoLang"
    "Distribution representation", "Docker Image"
    "Source code location", "`packages/operator <https://github.com/odahu/odahu-flow/tree/develop/packages/operator>`_"
    "Can be used w/o Odahu Platform?", "Yes"
    "Does it connect to another services?", "Yes (Kubernetes API)"
    "Can be deployed locally?", "If local Kubernetes cluster is present"
    "Does it provide any interface?", "No"
