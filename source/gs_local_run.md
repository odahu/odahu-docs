# Local run (local model execution)

In order to run model in environment that is similar to train and execution environments Odahu Platform provides you `odahuflowctl create-sandbox` command that can create docker container with preinstalled requirements.

## Prerequirements
* Linux based system with bash (at least version 4)
* Docker engine (at least version 17.0) with access from current user (`docker ps` should executes without errors)
* Python 3.6

## How to run?
1. Firstly, you have to install `odahu-flow-cli` package from PyPi (you may do this in the dedicated environment, created by pipenv, for example).

```bash
pip install --user odahu-flow-cli
```
2. Then, you have to run `odahuflowctl create-sandbox` command that will create `odahu-flow-activate.sh` script **in the your current directory**.

```bash
odahuflowctl create-sandbox
```
You may override default parameters using CLI arguments or Odahu application configuration (see **configuration** section).

* `--image` - docker image (named Odahu Toolchain) from which container will be started. Default value comes from `odahuflow.config.SANDBOX_PYTHON_TOOLCHAIN_IMAGE`
* `--force-recreate` - recreate `odahu-flow-activate.sh` if it exists.

Image should be compatible with Odahu Platform. By default Odahu Platform provides **odahu/python-toolchain** public image.

Example of value: `docker-registry-host:900/odahu/python-toolchain:1.0.0`

3. Activate Odahu environment (go inside docker container)

```bash
./odahu-flow-activate.sh
```

Execution of this command starts temporarly docker container (will be removed on exit) with mounting actual working directory to `/work-directory` path inside container.

At bootup occupied ports (that will route traffic from host to container) information will be printed to console.

Example of ports information:
```
Bootup configuration:
* Jupyter server: 56388
* PYDEVD debugger (reverse connection to host): disabled (you have to define PYDEVD_HOST and PYDEVD_PORT)
* PTVSD debugger: 56387
* PTVSD wait-for-attach: is not configured (you may configure it using PTVSD_WAIT_ATTACH)
```

Block above says that ports 56388, 56387 have been mapped from your host to container, that means that traffic from `localhost:56388` will be routed to container's `56388` port. This ports choose at each `odahu-flow-activate.sh` execution.

## How to use with Jupyter Notebook?
You are free to run jupyter notebook (that is installed by default) inside development container.

Here is an example of command:
```bash
jupyter notebook
```

Jupyter notebook access URL will be printed to console.

## Debugging
To debug your applications you may use next debugging protocols:
* [PyDevd](https://pypi.org/project/pydevd/) that is supported in PyCharm Professional, PyDev, VSCode Python
* [ptvsd](https://pypi.org/project/ptvsd/) that is supported in VSCode

### PyDevd
PyDevd debugging works in a **client (in your code) - server (in IDE)** way through network connection.

To start debugging you have to:
1. Start debugging server in your IDE.
2. Run `odahu-flow-activate.sh` with environment variables `PYDEVD_HOST` and `PYDEVD_PORT`.

Example:
```bash
PYDEVD_HOST=127.0.0.1 PYDEVD_PORT=8090 ./odahu-flow-activate.sh
```

### How to configure debugging using PyDevd in PyCharm
You may use instructions from this link [https://www.jetbrains.com/help/pycharm/remote-debugging-with-product.html](https://www.jetbrains.com/help/pycharm/remote-debugging-with-product.html).

## ptvsd
**ptvsd** is a editor that has been developed dedicated for VSCode IDE. It works in a **server (in your code) - client (in IDE) way** through network connection. Your python application starts dedicated thread in which it server attach requests of debugger.

To start debugging you have to:
1. Configure attaching in your IDE, choose port (for example 8000)
2. Run `odahu-flow-activate.sh` (`PTVSD_PORT` and `PTVSD_WAIT_ATTACH` are optional, default `PTVSD_WAIT_ATTACH=0`).

Example:
```bash
PTVSD_WAIT_ATTACH=1 ./odahu-flow-activate.sh
```

### How to configure debugging using ptvsd in VsCode
1. Open debugging tab
2. Click on gear icon
3. Add next configuration
```json
{
    "name": "Attach ",
    "type": "python",
    "request": "attach",
    "port": 8000, // Actual debugging port from bootup configuration
    "host": "localhost",
    "pathMappings": [
        {
            "localRoot": "${workspaceFolder}",
            "remoteRoot": "/work-directory"
        }
    ],
    "redirectOutput": false
},
```
4. Run `./odahu-flow-activate.sh` with `PTVSD_*` environment variables.
5. Run debugging configuration

## Example of usage
```bash
# Go to project directory
host> cd /my-ml-project

# Install odahuflow CLI tools and python package
host> sudo pip3 install odahu-flow-cli

# Create sandbox
host> odahuflowctl create-sandbox

# Go inside sandbox
host> ./odahu-flow-activate.sh

# Run Jupyterlab server
sandbox> jupyter lab
```
