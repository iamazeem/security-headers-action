# security-headers-action

[![CI](https://github.com/iamazeem/security-headers-action/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/iamAzeem/security-headers-action/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-darkgreen.svg?style=flat-square)](https://github.com/iamAzeem/security-headers-action/blob/master/LICENSE)
[![GitHub release](https://img.shields.io/github/v/release/iamAzeem/security-headers-action?style=flat-square)](https://github.com/iamazeem/security-headers-action/releases)
[![Buy Me a Coffee](https://img.shields.io/badge/Support-Buy%20Me%20A%20Coffee-orange.svg?style=flat-square)](https://www.buymeacoffee.com/iamazeem)

[GitHub Action](https://docs.github.com/en/actions) to analyze HTTP response
headers using [securityheaders.com](https://securityheaders.com/)
[API](https://securityheaders.com/api/docs/).

This
[composite](https://docs.github.com/en/actions/creating-actions/about-custom-actions#types-of-actions)
action uses standard
[Bash](https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html)
facilities along with [`curl`](https://curl.se/) and
[`jq`](https://stedolan.github.io/jq/).

## Usage

### Inputs

|           Input            | Required | Default | Description                                                                                  |
| :------------------------: | :------: | :-----: | :------------------------------------------------------------------------------------------- |
|         `api-key`          |  `true`  |         | API key from https://securityheaders.com/api/                                                |
|      `domain-or-url`       |  `true`  |         | Domain or URL to analyze HTTP response headers                                               |
|     `follow-redirects`     | `false`  | `true`  | Enable/disable following redirects                                                           |
| `hide-results-on-homepage` | `false`  | `true`  | Enable/disable hiding results on homepage                                                    |
|  `api-timeout-in-seconds`  | `false`  |  `30`   | API timeout in seconds (must be +ve, -ve value means default)                                |
| `max-retries-on-api-error` | `false`  |   `0`   | Maximum number of retries on API error (must be +ve; -ve value means 0)                      |
|      `expected-grade`      | `false`  |         | Expected grade [A+ to F; or maybe R if `follow-redirects: false`] (invalid grade is ignored) |

### Outputs

|      Output       | Description                                                        |
| :---------------: | :----------------------------------------------------------------- |
| `results-as-json` | Complete results in JSON format                                    |
| `summary-as-json` | Extracted summary in JSON format                                   |
|      `grade`      | Extracted grade [A+ to F; or maybe R if `follow-redirects: false`] |

## Examples

## Contribute

You may
[create issues](https://github.com/iamazeem/security-headers-action/issues/new/choose)
to report bugs or propose new features and enhancements.

PRs are always welcome. Please follow this workflow for submitting PRs:

- [Fork](https://github.com/iamazeem/security-headers-action/fork) the repo.
- Check out the latest `main` branch.
- Create a `feature` or `bugfix` branch from `main`.
- Commit and push changes to your forked repo.
- Make sure to add tests. See [CI](./.github/workflows/ci.yml).
- Lint and fix
  [Bash](https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html)
  issues with [shellcheck](https://www.shellcheck.net/) online or with
  [vscode-shellcheck](https://github.com/vscode-shellcheck/vscode-shellcheck)
  extension.
- Lint and fix README Markdown issues with
  [vscode-markdownlint](https://github.com/DavidAnson/vscode-markdownlint)
  extension.
- Submit the PR.

## License

[MIT](LICENSE)
