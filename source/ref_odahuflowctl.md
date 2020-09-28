# Odahuflowctl

Odahuflowctl (`odahuflowctl`) is a command-line interface for interacting with Odahu-flow API service.

## Prerequisites:

-  Python 3.6 or higher

## Installation

Odahu-flow CLI is available in PyPi repository. You should execute the following command to install `odahuflowctl`:

```bash
pip install odahu-flow-cli
odahuflowctl --version
```

## Help

To read odahuflowctl help, you should use the following command:

```bash
odahuflowctl --help
```

for a specific command, for example, get list of model deployments:

```bash
odahuflowctl deployment get --help
```

## Login

There are two authentication types for Odahu CLI.

### Specifying of a token explicitly

You should open an API server URL in a browser to get the login command.
The command already contains your token.
Copy and paste provided command into your shell. 

Example of command:
```bash
odahuflowctl login --url <api-url> --token <your-token>
```

### Sign in interactively

This method will use a web browser to sign in. 

Run the login command:
```bash
odahuflowctl login --url <api-url>
```

Odahu CLI will open an IAM server in your default browser. Sign in with your account credentials.

<br>

## Completion

`odahuflowctl` cli supports completion for following shells: bash, zsh, fish, PowerShell.

To activate it, evaluate the output of `odahuflowctl completion <YOUR_SHELL>`.  
`<YOURSHELL>` is the optional, it can be automatically identified.

Bash example:
```shell script
source <(odahuflowctl completion bash)
```

powershell example: 
```shell script
odahuflowctl completion > $HOME\.odahuflow\odahu_completion.ps1;
. $HOME\.odahuflow\odahu_completion.ps1;
Remove-Item $HOME\.odahuflow\odahu_completion.ps1
```

<br>

To activate completion automatically in any new shell, you can save the completion code to a file 
and add it to your shell profile.

Bash example:
```shell script
odahuflowctl completion bash > ${HOME}/.odahuflow/odahuflowctl_completion.sh
(echo ""; echo "source ${HOME}/.odahuflow/odahuflowctl_completion.sh"; echo "") >> ${HOME}/.bashrc
```

powershell example: 
```shell script
write "`n# odahuflowctl completion" (odahuflowctl completion) >> $PROFILE.CurrentUserAllHosts
```