==========
Networking
==========

By default, Odahu does not provide NetworkPolicy instances, but any policy that uses Pod label
selection may be used (e.g. K8S NetworkPolicy).

Network rules
-------------
Odahu components require communication between:

* Operator, Trainer, Packager, and Deployer instances
* API and Deployer instances
* EDGE and Deployer instances
* API and Docker Registry
* Cluster ingress controller and EDGE
* Prometheus and Odahu components -- for exporting performance metrics
* EDGE and feedback components (aggregator and FluentD) -- for feedback loop
