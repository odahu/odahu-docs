# Development hints

## Set up a development environment

Odahu product contains 5 main development parts:
* Python packages
    * Executes the `make install-all` command to downloads all dependencies and install Odahu python packages.
    * Verifies that the command finished successfully, for example: `odahuflowctl --version`
    * Main entrypoints:
      * Odahu-flow SDK - `packages/sdk`
      * Odahu-flow CLI - `packages/cli`
* Odahu-flow JupyterLab plugin
    * Workdir is `odahu/jupyterlab-plugin`
    * Executes the `yarn install` command to download all JavaScript dependencies.
    * Executes the `npm run build && jupyter labextension install` command to build the JupyterLab plugin.
    * Starts the JyputerLab server using `jupyter lab` command.
* Golang services:
    * Executes the `dep ensure` command in the `packages/operator` directory to downloads all dependencies.
    * Executes the `make build-all` command in the `packages/operator` to build all Golang services.
    * Main entrypoints:
      * API Gateway service - `packages/operator/cmd/edi/main.go`
      * Kubernetes operator - `packages/operator/cmd/operator/main.go`
      * AI Trainer - `packages/operator/cmd/trainer/main.go`
      * AI Packager - `packages/operator/cmd/packager/main.go`
      * Service catalog - `packages/operator/cmd/service_catalog/main.go`
* Odahu-flow Mlflow integration
    * Executes the `pip install -e .` command in the `odahu-flow-mlflow` repository.
* Odahu-flow Airflow plugin
    * Executes the `pip install -e .` command in the `odahu-flow-airflow-plugins` repository.

## Update dependencies

* `Python`. Update dependencies in a `Pipfile`. Execute `make update-python-deps` command.

* `Golang`. Update dependencies in a `Gopkg.toml`. Execute `dep ensure` command in `packages/operator` directory.

* `Typescript`. Odahu-flow uses the `yarn` to manipulate the typescript dependencies. 

## Make changes in API entities

All API entities are located in `packages/operator/pkg/api` directory.

To generate swagger documentation execute `make generate-all` in `packages/operator` directory. 
Important for Mac users: Makefile uses GNU `sed` tool, but MacOS uses BSD `sed` by default. They are not fully 
compatible. So you need install and use GNU `sed` on your Mac for using Makefile.

After previous action you can update python and typescript clients using the following command: `make generate-clients`.

## Actions before a pull request

Make sure you have done the following actions before a pull request:

* for python packages:
    * `make unittest` - Run the python unit tests.
    * `make lint` - Run the python linters.
* for golang services in the `packages/operator` directory:
    * `make test` - Run the golang unit tests.
    * `make lint` - Run the golang linters.
    * `make build-all` - Compile all golang Odahu-flow services
* for typescript code in the `packages/jupyterlab-plugin` directory:
    * `yarn lint` - Run the typescript linter.
    * `jlpm run build` - Compile the jupyterlab plugin.

## Local Helm deploy

During development, you often have to change the helm chart, to test the changes you can use the following command
quickly: `make helm-install`.

Optionally, you can create the variables helm file and specify it using the `HELM_ADDITIONAL_PARAMS` Makefile option.
You always can download real variables file from a Terraform state. 
