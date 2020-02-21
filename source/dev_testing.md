# Integration+ Testing

This page provides information about testing of ODAHU.
ODAHU uses [Robot Framework](https://robotframework.org/) for an integration, system and end-to-end testings.

All tests are located in the following directories of the [ODAHU project](https://github.com/odahu/odahu-flow):
* `packages/robot` - a python package with additional Robot libraries. For example: kubernetes, auth_client, feedback, and so on. 
* `packages/tests/stuff` - artifacts for integration testing. For example: pre-trained ML artifacts, test toolchain integrations, and so on.
* `packages/tests/e2e` - directory with the RobotFramework tests.

## Preparing for testing
--------------------

It's expected that you are using POSIX operating system and have install Python 3.6.9+ and pip.

1. [Clone](https://github.com/odahu/odahu-flow) ODAHU project from git repository and proceed to main dir – `odahu-flow`.
1. [Create](https://docs.python.org/3/library/venv.html) Python virtual environment
e.g. in the folder `./odahu-flow/virtual_environment` and activate one.
1. [Install](https://github.com/robotframework/robotframework/blob/master/INSTALL.rst) Robot Framework
1. Update and/or install **setuptools** and **pip**:
    ```bash 
    $ pip install -U setuptools && pip install -U pip
    ```
1. Proceed to the `odahu-flow` directory where the _'Makefile'_ is located and run make:
    ```bash 
    /odahu-flow$ make install-all 
    ```
1. Check that odahuflowctl works:
    ```bash 
    /odahu-flow$ odahuflowctl
    ```

## Running tests
--------------------

### *We set up robot tests for `gke-odahu-flow-test` cluster in the example below.*

#### * Do not forget change your cluster url and odahu-flow version.

Export cluster secrets from odahu-flow-profiles directory.
* Clones *internal* odahu-flow-profiles repository. Checkout your or the developer branch.
* Build hiera docker image using the `make docker-build-hiera` command in odahu-flow-profiles directory.
* You can optionally override the following parameters in `.env` file:
  * `CLUSTER_NAME`
  * `HIERA_KEYS_DIR`
  * `SECRET_DIR`
  * `CLOUD_PROVIDER`
  * `EXPORT_HIERA_DOCKER_IMAGE`
  * `ODAHUFLOW_PROFILES_DIR`
* Executes `make export-hiera` command.
* Verify that `${SECRET_DIR}/.cluster_profile.json` file was created.

Updates the `.env` file when you should override a default Makefile option:
```bash
# Cluster name
CLUSTER_NAME=gke-odahu-flow-test
# Optionnaly, you can provide RobotFramework settings below.
# Additional robot parameters. For example, you can specify tags or variables.
ROBOT_OPTIONS=-e disable
# Robot files
ROBOT_FILES=**/*.robot
```

Afterward, you should set up a Odahu cluster for RobotFramework tests using the `make setup-e2e-robot` command.
You should execute the previous command only once.

Finally, starts the robot tests:
```bash
make e2e-robot
```
