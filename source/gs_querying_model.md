# Querying model

Each deployed on cluster model can be queried using HTTP Api (if API and Ingress are enabled in configuration).

To perform this call, JWT token, generated by API service, is required (if it is enabled in configuration). For details [see chapter](./cmp_odahuflowctl.md).

Models can be queries using next mechanisms:
* `odahuflowctl` CLI tool. [See chapter](./cmp_odahuflowctl.md)
* `EdgeClient` in Python SDK (**not in toolchain**)
* Plain HTTP calls. [See chapter](./ref_model_rest_api.md)
