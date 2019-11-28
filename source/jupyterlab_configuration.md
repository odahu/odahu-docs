# Jupyterlab

Odahu provides the Jupyterlab plugin as part of the platform.

## Internal deployment

Every Odahu deployment contains Jupyterlab instance.
Its URL is `https://jupyterlab.<root-domain>/`.

## Installation

For now, there is no way to install the plugin from pypy\npm.
You can use the prebuilt Docker image, which is located in [repository](https://hub.docker.com/r/odahu/odahu-flow-jupyterlab/tags).

```bash
odahuflowctl sandbox --image odahu/jupyterlab:latest
./odahu-flow-activate.sh
```

To setup an instance of Jupyterlab, you can use an environment variables. Available configuration options:
* `DEFAULT_API_ENDPOINT` - preconfigured API endpoint, for example `http://odahu.demo.ailifecycle.org`.
* `ODAHUFLOWCTL_OAUTH_AUTH_URL` - Keycloak authorization endpoint, for example `https://keycloak.company.org/auth/realms/master/protocol/openid-connect/auth` 
* `JUPYTER_REDIRECT_URL` - JupyterLab external URL.
* `ODAHUFLOWCTL_OAUTH_SCOPE` - Oauth2 scopes. Th default value is `openid profile email offline_access groups`.
* `ODAHUFLOWCTL_OAUTH_CLIENT_SECRET` - Oauth2 client secret
* `ODAHUFLOWCTL_OAUTH_CLIENT_ID` - Oauth client ID

To enable SSO, you should provide the following options:
* `ODAHUFLOWCTL_OAUTH_AUTH_URL`
* `JUPYTER_REDIRECT_URL`
* `ODAHUFLOWCTL_OAUTH_CLIENT_SECRET`
* `ODAHUFLOWCTL_OAUTH_CLIENT_ID`
