# Integration Testing

This page provides information about testing of ODAHU.
ODAHU uses [Robot Framework](https://robotframework.org/) for an integration, system and end-to-end testings.

All tests are located in the following directories of the [ODAHU project](https://github.com/odahu/odahu-flow):
* `packages/robot/` - a python package with additional Robot libraries. For example: kubernetes, auth_client, feedback, and so on. 
* `packages/tests/stuff/` - setup, cleanup scripts and artifacts for integration testing. For example: pre-trained ML artifacts, test toolchain integrations, and so on.
* `packages/tests/e2e/` - directory with the Robot Framework tests.

## Preparing for testing
--------------------

It's expected that you are using a Unix-like operating system and have installed conda (4.10+), preferably [miniconda](https://docs.conda.io/en/latest/miniconda.html).

1. [Clone](https://github.com/odahu/odahu-flow) ODAHU project from git repository and proceed to main dir – `odahu-flow`.
1. [Create](https://conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html#creating-an-environment-with-commands) Conda virtual environment with python version 3.6+.
1. Update and/or install **pip** and **setuptools**:
    ```bash 
    $ pip install -U pip setuptools
    ```
1. Proceed to the `odahu-flow` main directory where the `Makefile` is located and run **make** command:
    ```bash 
    /odahu-flow$ make install-all 
    ```
1. Check that odahuflowctl works:
    ```bash 
    /odahu-flow$ odahuflowctl
    ```
1. Also, you should have installed [jq](https://stedolan.github.io/jq/) and [rclone](https://rclone.org/downloads/) packages.

## Running tests
--------------------

We set up robot tests for `gke-odahu-flow-test` cluster in the example below.

**NB.** Do not forget change **your cluster url** and **odahu-flow version**.

1. By default put `cluster_profile.json` file in `odahu-flow/.secrets/` folder (by default) or you can specify another default name of file or directory in *'Makefile'* in parameters: `SECRET_DIR` and `CLUSTER_PROFILE`.
1. You can optionally override the following parameters in `.env` file (which by default are taken from `Makefile`).
   * `CLUSTER_NAME`
   * `ROBOT_OPTIONS`
   * `ROBOT_FILES`
   * `HIERA_KEYS_DIR`
   * `SECRET_DIR`
   * `CLOUD_PROVIDER`
   * `DOCKER_REGISTRY`
   * `EXPORT_HIERA_DOCKER_IMAGE`
   * `ODAHUFLOW_PROFILES_DIR`
   * `ODAHUFLOW_VERSION`, etc.
   
   For that, you should create `.env` file in the main dir of the project (`odahu-flow`).
1. In our example, we will override the parameters of `Makefile` in `.env` file:
   ```bash
   # Cluster name
   CLUSTER_NAME=gke-odahu-flow-test
   # Optionally, you can provide RobotFramework settings below.
   # Additional robot parameters. For example, you can specify tags or variables.
   ROBOT_OPTIONS=-e disable
   # Robot files
   ROBOT_FILES=**/*.robot
   # Cloud which will be used
   CLOUD_PROVIDER=gcp
   # Docker registry
   DOCKER_REGISTRY=gcr.io/or2-msq-<myprojectid>-t1iylu/odahu
   # Version of odahu-flow
   ODAHUFLOW_VERSION=1.1.0-rc8
   ```

1. Afterwards, you should prepare an Odahu cluster for Robot Framework tests by using the command:
   ```bash 
    /odahu-flow$ make setup-e2e-robot
    ```
   **NB.** You should execute the `setup` command only once for a new cluster.

1. The next step is to run the Robot Framework tests:
   ```bash
   /odahu-flow$ make e2e-robot
   ```
   
1. Finally, cleanup the cluster after testing:
   ```bash
   /odahu-flow$ make cleanup-e2e-robot
   ```
   **NB.** You should run the `cleanup` command only once, after all testing has been completed.
