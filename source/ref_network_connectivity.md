# Network rules

By default Odahu does not provide any NetworkPolicy instances. But Odahu installation can be secured using any policy that uses Pod label selection (like standard K8S NetworkPolicy).

## Network rules
You can use principle of least privilege that denies any connection in cluster and ingress/egress connection, but Odahu components requires some in-cluster connections (between Pods) for keeping working.

* Connection between [Operator](./comp_operator.md) and model training and model deployment instances - for inspecting training and deployed models
* Connection between [API](./comp_api.md) and model deployment instances - for inspecting deployed models
* Connection between [EDGE](./comp_edge.md) and model deployment instances - for routing model API traffic
* Connection between [API](./comp_api.md) and Docker Registry that is used for storing trained models - for inspecting meta-information about images before deploy
* Connection between cluster's Ingress controller (nginx-ingress or etc.) and [EDGE](./comp_edge.md) (for model API) and [API](./comp_api.md) (for manage API)
* Connection between Prometheus and Odahu's components - for exporting performance metrics
* Connection between [EDGE](./comp_edge.md) and feedback components (aggregator and FluentD) -- for feedback loop
