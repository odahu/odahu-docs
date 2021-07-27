Changelog
=========

Odahu 1.5.0
--------------------------
Features:
""""""""""""

- Core:
    * `New Batch Inference API <https://docs.odahu.org/ref_batch.html>`_
      (`#500 <https://github.com/odahu/odahu-flow/issues/500>`_,
      `#537 <https://github.com/odahu/odahu-flow/issues/537>`_)
    * Object storage added as an option of ML project source code repository (`#360 <https://github.com/odahu/odahu-flow/issues/360>`_).

- Python SDK:
    * Add clients to work with User and Feedback entities (`#295 <https://github.com/odahu/odahu-flow/issues/295>`_)

Updates
""""""""""""
- Core:
    * Set `model-name`/`model-version` headers on service mesh level. That looses the requirements to inference servers.
      Previously any inference server (typically a model is packed into one on Packaging stage) was obligated to
      include the headers into response for feedback loop to work properly. That rule restricts from using any
      third-party inference servers (such as NVIDIA Triton), because we cannot control the response headers.
      (`#496 <https://github.com/odahu/odahu-flow/issues/496>`_).
    * Removed deprecated fields `updateAt`/`createdAt` from core API entities
      (`#394 <https://github.com/odahu/odahu-flow/issues/394>`_)
    * Move to recommended and more high-level way of using Knative which under-the-hood is responsible for a big part
      of `ModelDeployment` functionality (`#347 <https://github.com/odahu/odahu-flow/issues/347>`_)

- CLI:
    * Model `info` and `invoke` parameter `jwt` renamed to `token` (`#577 <https://github.com/odahu/odahu-flow/issues/577>`_).
    * Usage descriptions updated (`#577 <https://github.com/odahu/odahu-flow/issues/577>`_).
    * Auth tokens are automatically refreshing (`#509 <https://github.com/odahu/odahu-flow/issues/509>`_).

- Aiflow plugin:

    * Airflow plugin operators expect a service account's ``client_secret`` in a ``password`` field of `Airflow Connection` now.
      previously it expects ``client_secret`` in ``extra`` field. (`#29 <https://github.com/odahu/odahu-airflow-plugin/issues/29>`_).
      `Breaking change!`: You should recreate all Airflow connections for ODAHU server by moving the ``client_secret``
      from the ``extra`` field into the ``password`` field. Please do not forget to remove your ``client_secret`` from
      the ``extra`` field for security reasons.

Bug Fixes:
""""""""""""

- Core:
    * Fix & add missing updatedAT/createdAT (`#583 <https://github.com/odahu/odahu-flow/issues/583>`_, `#600 <https://github.com/odahu/odahu-flow/issues/600>`_, `#601 <https://github.com/odahu/odahu-flow/issues/601>`_, `#602 <https://github.com/odahu/odahu-flow/issues/602>`_).
    * Training result doesn't contain commit ID when using object storage as algorythm source (`#584 <https://github.com/odahu/odahu-flow/issues/584>`_).
    * RunID is now present for model training with mlflow toolchain (`#581 <https://github.com/odahu/odahu-flow/issues/581>`_).
    * InferenceJob objects can now be deleted correctly (`#555 <https://github.com/odahu/odahu-flow/issues/555>`_).
    * Deployment `roleName` changes now applies correctly (`#533 <https://github.com/odahu/odahu-flow/issues/533>`_).
    * X-REQUEST-ID header are now correctly handled on service mesh layer to support third-party inference servers (`#525 <https://github.com/odahu/odahu-flow/issues/525>`_).
    * Fix packaging deletion via `bulk delete` command (`#416 <https://github.com/odahu/odahu-flow/issues/416>`_).


Odahu 1.4.0, 26 February 2021
--------------------------

Features:
""""""""""""

- Core:
    * Triton Packaging Integration (:ref:`ref_packagers:Nvidia Triton Packager`) added as a part of Triton pipeline (`#437 <https://github.com/odahu/odahu-flow/issues/437>`_).
    * Local training & packaging now covered with tests (`#157 <https://github.com/odahu/odahu-flow/issues/157>`_).
    * MLflow toolchain with custom format for model training artifact (`#31 <https://github.com/odahu/odahu-trainer/issues/31>`_).

- UI:
    * New `Play` tab on Deployment page provides a way to get deployed model metadata and make inference requests
      from the UI (`#61 <https://github.com/odahu/odahu-ui/issues/61>`_).
    * New `Logs` tab on Deployment page provides a way to browse logs of deployed model (`#45 <https://github.com/odahu/odahu-ui/issues/45>`_).
    * User now can create packaging and deployments based on finished trainings and packagings (`#38 <https://github.com/odahu/odahu-ui/issues/38>`_).

Updates:
""""""""""""

- Core:
    * Service catalog is rewritten (`#457 <https://github.com/odahu/odahu-flow/issues/457>`_).
    * Deployed ML models performance optimized (`#357 <https://github.com/odahu/odahu-flow/issues/357>`_).
    * OpenPolicyAgent-based RBAC for deployed models are implemented (`#238 <https://github.com/odahu/odahu-flow/issues/238>`_).

- CLI:
    * Option ``--disable-target`` for ``odahuflowctl local pack run`` command added. It allows you disable targets which will be passed to packager process. You can use multiple options at once. For example:
      ``odahuflowctl local pack run ... --disable-target=docker-pull --disable-target=docker-push``.
    * Options ``--disable-package-targets/--no-disable-package-targets`` for ``odahuflowctl local pack run`` command are deprecated.
    * ``odahuflowctl local pack run`` behavior that implicitly disables all targets by default is deprecated.

Bug Fixes:
""""""""""""

- Core:
    * Knative doesn't create multiple releases anymore when using multiple node pools (`#434 <https://github.com/odahu/odahu-flow/issues/434>`_).
    * Liveness & readiness probes lowest values are now 0 instead of 1 (`#442 <https://github.com/odahu/odahu-flow/issues/442>`_). 
    * Correct error code now returned on failed deployment validation (`#441 <https://github.com/odahu/odahu-flow/issues/441>`_).
    * Empty `uri` param is not longer validated for `ecr` connection type (`#440 <https://github.com/odahu/odahu-flow/issues/440>`_).
    * Return correct error when missed `uri` param passed for `git` connection type (`#436 <https://github.com/odahu/odahu-flow/issues/436>`_).
    * Return correct error when user has insufficient privileges (`#444 <https://github.com/odahu/odahu-flow/issues/444>`_).
    * Default branch is now taken for VCS connection if it's not provided by user (`#148 <https://github.com/odahu/odahu-flow/issues/148>`_).

- UI:
    * Auto-generated predictor value doesn't show warning on deploy creation (`#80 <https://github.com/odahu/odahu-ui/issues/80>`_).
    * Default deploy liveness & readiness delays are unified with server values (`#74 <https://github.com/odahu/odahu-ui/issues/74>`_).
    * Deployment doesn't raise error when valid predictor value passed (`#46 <https://github.com/odahu/odahu-ui/issues/46>`_).
    * Sorting for some columns fixed (`#48 <https://github.com/odahu/odahu-ui/issues/48>`_).
    * Secrets are now masked on review stage of connection creation (`#42 <https://github.com/odahu/odahu-ui/issues/42>`_).
    * Interface is now works as expected with long fields on edit connection page (`#65 <https://github.com/odahu/odahu-ui/issues/65>`_)


Odahu 1.3.0, 07 October 2020
--------------------------

Features:
""""""""""""

- Core:
    * Persistence Agent added to synchronize k8s CRDS into main storage (`#268 <https://github.com/odahu/odahu-flow/issues/268>`_).
    * All secrets passed to ODAHU API now should be base64 encoded. Decrypted secrets retrieved from ODAHU API via `/connection/:id/decrypted` are now also base64 encoded. (`#181 <https://github.com/odahu/odahu-flow/issues/181>`_, `#308 <https://github.com/odahu/odahu-flow/issues/308>`_).
    * Positive and negative (for 404 & 409 status codes) API tests via odahuflow SDK added (`#247 <https://github.com/odahu/odahu-flow/issues/247>`_).

Updates:
""""""""""""

- Core:
    * Robot tests will now output pods state after each API call to simplify debugging.

Bug Fixes:
""""""""""""

- Core:
    * Refactoring: some abstractions & components were renamed and moved to separate packages to facilitate future development.
    * For connection create/update operations ODAHU API will mask secrets in response body.
    * Rclone output will not reveal secrets on unit test setup stage anymore.
    * `Output-dir` option path is now absolute (`#208 <https://github.com/odahu/odahu-flow/issues/208>`_).
    * Respect `artifactNameTemplate` for local training result directory name (`#193 <https://github.com/odahu/odahu-flow/issues/193>`_).
    * Allow to pass Azure BLOB URI without schema on connection creation (`#345 <https://github.com/odahu/odahu-flow/issues/345>`_)
    * Validate model deployment ID to ensure it starts with alphabetic character (`#294 <https://github.com/odahu/odahu-flow/issues/294>`_)

- UI:
    * State of resources now updates correctly after changing in UI (`#11 <https://github.com/odahu/odahu-ui/issues/11>`_).
    * User aren't able to submit training when resource request is bigger than limit '(`#355 <https://github.com/odahu/odahu-flow/pull/355>`_).
    * Mask secrets on review page during conenction creation process (`#42 <https://github.com/odahu/odahu-ui/issues/42>`_)
    * UI now responds correct in case of concurrent deletion of entities (`#44 <https://github.com/odahu/odahu-ui/issues/44>`_).
    * Additional validation added to prevent creation of resources with unsupported names (`#342 <https://github.com/odahu/odahu-flow/issues/342>`_, `#34 <https://github.com/odahu/odahu-ui/issues/34>`_).
    * Sorting added for training & packaging views (`#13 <https://github.com/odahu/odahu-ui/issues/13>`_, `#48 <https://github.com/odahu/odahu-ui/issues/48>`_).
    * `reference` field become optional for VCS connection (`#50 <https://github.com/odahu/odahu-ui/issues/50>`_).
    * Git connection hint fixed (`#7 <https://github.com/odahu/odahu-ui/issues/7>`_).

- CLI:
    * Configuration secrets is now masked in config output (`#307 <https://github.com/odahu/odahu-flow/issues/307>`_).
    * Local model output path will now display correctly (`#371 <https://github.com/odahu/odahu-flow/issues/371>`_).
    * Local training output will now print only local training results (`#370 <https://github.com/odahu/odahu-flow/issues/370>`_).
    * Help message fixed for `odahuflowctl gppi` command (`#375 <https://github.com/odahu/odahu-flow/issues/375>`_).

- SDK:
    * All API connection errors now should be correctly handled and retried.

Odahu 1.2.0, 26 June 2020
--------------------------

Features:
""""""""""""

- Core:
    * PostgreSQL became main database backend as part of increasing project maturity (`#175 <https://github.com/odahu/odahu-flow/issues/175>`_). You can find additional documentation in :ref:`instructions <tutorials_installation:Install base Kubernetes services>`.

- ODAHU CLI:
    * Option `--ignore-if-exist` added for entities creation (`#199 <https://github.com/odahu/odahu-flow/issues/199>`_).
    * Descriptions updated for commands & options (`#160 <https://github.com/odahu/odahu-flow/issues/160>`_, `#197 <https://github.com/odahu/odahu-flow/issues/197>`_, `#209 <https://github.com/odahu/odahu-flow/issues/209>`_).

- ODAHU UI:
    * ODAHU UI turned into open-source software and now available on `github <https://github.com/odahu/odahu-ui/>`_ under Apache License Version 2.0. UDAHU UI is an WEB-interface for ODAHU based on React and TypeScript. It provides ODAHU workflows overview and controls, log browsing and entity management.

Updates:
""""""""""""

- Knative updated to version 0.15.0. That makes it possible to deploy model services to different node pools (`#123 <https://github.com/odahu/odahu-flow/issues/123>`_).
- Go dependencies was globally updated to migrate from GOPATH to go modules (`#32 <https://github.com/odahu/odahu-flow/issues/32>`_).

Bug Fixes:
""""""""""""

- Core:
    * Training now will fail if wrong data path or unexisted storage bucket name is provided (`#229 <https://github.com/odahu/odahu-flow/issues/229>`_).
    * Training log streaming is now working on log view when using native log viewer (`#234 <https://github.com/odahu/odahu-flow/issues/234>`_).
    * ODAHU pods now redeploying during helm chart upgrade (`#111 <https://github.com/odahu/odahu-flow/issues/111>`_).
    * ODAHU docker connection now can be created with blank username & password to install from docker public repo (`#184 <https://github.com/odahu/odahu-flow/issues/184>`_).

- ODAHU CLI:
    * Return training artifacts list sorted by name (`#165 <https://github.com/odahu/odahu-flow/issues/165>`_).
    * Don't output logs for bulk command (`#200 <https://github.com/odahu/odahu-flow/issues/200>`_).
    * Fix `local pack cleanup-containers` command (`#204 <https://github.com/odahu/odahu-flow/issues/204>`_).
    * Return correct message if entity not found (`#210 <https://github.com/odahu/odahu-flow/issues/210>`_).
    * Return correct message if no options provided (`#211 <https://github.com/odahu/odahu-flow/issues/211>`_).

- ODAHU UI:
    * Fix description of replicas of Model Deployment.
    * Trim spaces for input values.
    * Fix incorrect selection of VCS connection.
    * Close 'ODAHU components' menu after opening link in it.

Odahu 1.1.0, 16 March 2020
--------------------------

New Features:
""""""""""""

- Jupyterhub:
    Supported the JupyterHub in our deployment scripts.
    JupyterHub allows spawning multiple instances of the JupyterLab server.
    By default, we provide the prebuilt ODAHU JupyterLab plugin in the following Docker images: `base-notebook <https://hub.docker.com/r/odahu/base-notebook>`_, `datascience-notebook <https://hub.docker.com/r/odahu/datascience-notebook>`_, and `tensorflow-notebook <https://hub.docker.com/r/odahu/tensorflow-notebook>`_.
    To build a custom image, you can use `our Docker image template <https://github.com/odahu/odahu-flow-jupyterlab-plugin/blob/develop/containers/jupyter-stacks/Dockerfile>`_ or follow the :ref:`instructions <int_jupyterlab_extension:installation>`.

- GPU:
    Added the ability to deploy a model training on GPU nodes.
    You can find an example of training `here <https://github.com/odahu/odahu-examples/tree/develop/mlflow/tensorflow/flower_classifier>`_.
    This is one of the official MLFlow examples that classifies flower species from photos.

- Secuirty:
    We integrated our WEB API services with `Open Policy Agent <https://www.openpolicyagent.org/>`_ that flexibly allows managing ODAHU RBAC.
    Using `Istio <https://istio.io/>`_, we forbid non-authorize access to our services.
    You can find the ODAHU security documentation :ref:`here <gen_security:Security>`.

- Vault:
    ODAHU-Flow has the Connection API that allows managing credentials from Git repositories, cloud storage, docker registries, and so on.
    The default backend for Connection API is Kubernetes.
    We integrated the `Vault <https://www.vaultproject.io/>`_ as a storage backend for the backend for Connection API to manage your credentials securely.

- Helm 3:
    We migrated our Helm charts to the Helm 3 version.
    The main goals were to simplify a deployment process to an Openshift and to get rid of the tiller.

- ODAHU UI:
    ODAHU UI provides a user interface for the ODAHU components in a browser.
    It allows you to manage and view ODAHU Connections, Trainings, Deployments, and so on.

- Local training and packaging:
    You can train and package an ML model with the `odahuflowctl` utility using the same ODAHU manifests, as you use for the cluster training and packaging.
    The whole process is described :ref:`here <tutorials_local_wine:Local Quickstart>`.

- Cache for training and packaging:
    ODAHU Flow downloads your dependencies on every model training and packaging launch.
    To avoid this, you can provide a prebuilt Docker image with dependencies.
    Read more for model :ref:`training <training-model-dependencies-cache>` and :ref:`packagings <packaging-model-dependencies-cache>`.

- Performance improvement training and packaging:
    We fixed multiple performance issues to speed up the training and packaging processes.
    For our model examples, the duration of training and packaging was reduced by 30%.

- Documentation improvement:
    We conducted a hard work to improve the documentation.
    For example, the following new sections were added: :ref:`Security <gen_security:Security>`, :ref:`Installation <tutorials_installation:Installation>`, :ref:`Training <ref_trainings:Model Trainings>`, :ref:`Packager <ref_packagers:Model Packagers>`, and :ref:`Model Deployment <ref_deployments:Model Deployments>`.

- Odahu-infra:
    We created the new `odahu-infra <https://github.com/odahu/odahu-infra>`_ Git repository, where we placed the following infra custom helm charts: Fluentd, Knative, monitoring, Open Policy Agent, Tekton.

- Preemptible nodes:
    Preemptible nodes are priced lower than standard virtual machines of the same types.
    But they provide no availability guarantees.
    We added new deployment options to allow training and packaging pods to be deployed on preemptible nodes.

- Third-parties updates:
    * Istio
    * Grafana
    * Prometheus
    * MLFlow
    * Terraform
    * Buildah
    * Kubernetes

Misc/Internal
"""""""""""""

- Google Cloud Registry:
    We have experienced multiple problems while using Nexus as a main dev Docker registry.
    This migration also brings us additional advantages, such as in-depth vulnerability scanning.

- Terragrunt:
    We switched to using Terragrunt for our deployment scripts.
    That allows reducing the complexity of our terraform modules and deployment scripts.
