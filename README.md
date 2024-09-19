# security-headers-action

[![CI](https://github.com/iamazeem/security-headers-action/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/iamAzeem/security-headers-action/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-darkgreen.svg?style=flat-square)](https://github.com/iamAzeem/security-headers-action/blob/master/LICENSE)
[![GitHub release](https://img.shields.io/github/v/release/iamazeem/security-headers-action?style=flat-square)](https://github.com/iamazeem/security-headers-action/releases)

[GitHub Action](https://docs.github.com/en/actions) to analyze HTTP response
headers using [securityheaders.com](https://securityheaders.com/)
[API](https://securityheaders.com/api/docs/).

This
[composite](https://docs.github.com/en/actions/creating-actions/about-custom-actions#types-of-actions)
action uses standard
[Bash](https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html)
facilities along with [`curl`](https://curl.se/) and
[`jq`](https://stedolan.github.io/jq/).

Tested on Linux, macOS, and Windows GHA runners. See
[CI workflow](./.github/workflows/ci.yml) for details.

## Usage

### Inputs

|           Input            | Required | Default | Description                                                                                     |
| :------------------------: | :------: | :-----: | :---------------------------------------------------------------------------------------------- |
|         `api-key`          |  `true`  |         | API key from https://securityheaders.com/api/                                                   |
|      `domain-or-url`       |  `true`  |         | Domain or URL to analyze HTTP response headers                                                  |
|     `follow-redirects`     | `false`  | `true`  | Follow redirect status codes                                                                    |
| `hide-results-on-homepage` | `false`  | `true`  | Hide results on homepage                                                                        |
|  `api-timeout-in-seconds`  | `false`  |  `30`   | API timeout in seconds (must be +ve, -ve value means default)                                   |
| `max-retries-on-api-error` | `false`  |   `0`   | Maximum number of retries on API error (must be +ve; -ve value means default)                   |
|      `expected-grade`      | `false`  |         | Expected grade [A+ to F; or maybe R if `follow-redirects: false`] (invalid value means default) |

- To store the API key, prefer using GitHub Actions
  [secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets).

- The grade lower than `expected-grade` will result in failure.

### Outputs

|      Output       | Description                                                        |
| :---------------: | :----------------------------------------------------------------- |
| `results-as-json` | Complete results in JSON format                                    |
| `summary-as-json` | Extracted summary in JSON format                                   |
|      `grade`      | Extracted grade [A+ to F; or maybe R if `follow-redirects: false`] |

### Examples

#### Analyze and print output in the next step

```yaml
- name: Analyze HTTP response headers
  uses: iamazeem/security-headers-action@v1
  id: analyze
  with:
    api-key: ${{ secrets.API_KEY }}
    domain-or-url: securityheaders.com

- name: Print output
  env:
    RESULTS_AS_JSON: ${{ steps.analyze.outputs.results-as-json }}
    SUMMARY_AS_JSON: ${{ steps.analyze.outputs.summary-as-json }}
    GRADE: ${{ steps.analyze.outputs.grade }}
  run: |
    jq '.' <<<"$RESULTS_AS_JSON"
    jq '.' <<<"$SUMMARY_AS_JSON"
    echo "GRADE: [$GRADE]"
```

#### Analyze and fail on an unexpected grade

```yaml
- name: Analyze HTTP response headers
  uses: iamazeem/security-headers-action@v1
  id: analyze
  with:
    api-key: ${{ secrets.API_KEY }}
    domain-or-url: securityheaders.com
    expected-grade: A+                    # should fail on lower grade
```

#### Analyze and retry on failure

```yaml
- name: Analyze HTTP response headers
  uses: iamazeem/security-headers-action@v1
  id: analyze
  with:
    api-key: ${{ secrets.API_KEY }}
    domain-or-url: securityheaders.com
    max-retries-on-api-error: 2           # will retry on failure
```

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
