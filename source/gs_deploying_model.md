================
Deploying models
================

Odahu supports deploying [Odahu-compatible models](./gs_what_is_model.md) on top of cluster or on any machine with installed Docker Engine. This chapter describes on-cluster deployment. For local deployment please refer [local mode section](./gs_local_run.md).

**WARNING: Not every Docker Image can be deployed on Odahu. Odahu only supports deploying of [compatible models](./gs_what_is_model.md#built-model).**

To deploy Odahu model on top of cluster next mechanisms can be used:
* Creationing of [ModelDeployment CR](./ref_crds.md).
* Using `odahuflowctl` tool. [See chapter](./cmp_odahuflowctl.md).
* Calling API service using HTTP requests.

Each deployed model is available to:
* Be queried using HTTP API. [See chapter](./gs_querying_model.md)
* Be scaled using `odahuflowctl` / API call.
* Be undeployed (using same ways as for deployment).

## Examples of VCS credentials management

### Using `kubectl`

```bash
kubectl create -f - <<EOF
kind: Connection
id: vcs-examlpe
spec:
  credential: bG9sa2VrbG9sa2VrCg==
  defaultReference: master
  type: git
  uri: git@github.com:odahu/odahu-examples.git
EOF
```

### Using Plain HTTP

```bash
curl -X POST "https://<apu-url>/api/v1/connection" \
     -H "accept: application/json" \
     -H "Content-Type: application/json" \
     -d '{ "id": "vcs-examlpe", "spec": { "credential": "bG9sa2VrbG9sa2VrCg==", "defaultReference": "master", "type": "git", "uri": "git@github.com:odahu/odahu-examples.git" }}'
```


## Examples of training management

### Using `kubectl`

```bash
kubectl create -f - <<EOF
kind: ModelDeployment
id: deployment-example
spec:
  image: <docker-repository>/odahu/example:1.0
  replicas: 2
EOF
```

### Using Plain HTTP

```bash
curl -X POST "https://<api-url>/api/v1/model/deployment" \
     -H "accept: application/json" \
     -H "Content-Type: application/json" \
     -d '{"name":"deployment-example","spec": {"image":"<docker-repository>/odahu/example:1.0","replicas": 2 }}'
```
