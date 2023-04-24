#!/bin/bash

# https://www.shellcheck.net/wiki/SC2155
# shellcheck disable=SC2155

set -eE -o functrace

fatal() {
  local LINE="$1"
  local CMD="$2"
  echo "[FATAL] $LINE: $CMD"
  exit 1
}

trap 'fatal "$LINENO" "$BASH_COMMAND"' ERR

# functions

analyze() {
  echo "::group::Analyzing [$INPUT_DOMAIN_OR_URL]"

  if [[ $INPUT_FOLLOW_REDIRECTS == "off" ]]; then
    echo
    echo "NOTE: Following of redirect status codes is disabled."
    echo "      You may get an 'R' grade."
    echo "      Set \`follow-redirects: true\` to get full resutls."
    echo
  fi

  local API_URL="https://api.securityheaders.com/?q=$INPUT_DOMAIN_OR_URL&followRedirects=$INPUT_FOLLOW_REDIRECTS&hide=$INPUT_HIDE_RESULTS_ON_HOMEPAGE"
  echo "API URL: [$API_URL]"

  for ((RETRY = 0; RETRY <= INPUT_MAX_RETRIES_ON_API_ERROR; RETRY++)); do
    echo "- Making API request [$RETRY / $INPUT_MAX_RETRIES_ON_API_ERROR]"
    local API_RESPONSE="$(curl -sS -m "$INPUT_API_TIMEOUT_IN_SECONDS" -H "x-api-key: $INPUT_API_KEY" "$API_URL" 2>&1)"
    local IS_ERROR=false
    if [[ -z $API_RESPONSE ]]; then
      echo "  Empty response!"
      IS_ERROR=true
    elif ! jq '.' <<<"$API_RESPONSE" >/dev/null 2>&1; then
      echo "  Invalid respone!"
      echo "$API_RESPONSE"
      IS_ERROR=true
    else
      echo "  Checking status"
      local STATUS="$(jq -r '.status | ascii_downcase' <<<"$API_RESPONSE")"
      if [[ $STATUS != "good" ]]; then
        echo "  Invalid status received! [$STATUS]"
        jq -r '.' <<<"$API_RESPONSE"
        IS_ERROR=true
      else
        echo "  STATUS: [$STATUS]"
      fi
    fi
    if [[ $IS_ERROR == true ]]; then
      if ((INPUT_MAX_RETRIES_ON_API_ERROR)); then
        echo "  Retrying..."
      else
        echo "  Exiting..."
        exit 1
      fi
    fi
  done

  local GRADE="$(jq -r '.summary.grade | ascii_upcase' <<<"$API_RESPONSE")"
  if [[ -n $INPUT_EXPECTED_GRADE ]]; then
    echo "- Checking expected grade [$INPUT_EXPECTED_GRADE]"
    if [[ $INPUT_EXPECTED_GRADE != "$GRADE" ]]; then
      echo "  Unexpected grade found!"
      echo "  Expected: [$INPUT_EXPECTED_GRADE], Found: [$GRADE]"
      exit 1
    else
      echo "  Expected grade found! [$INPUT_EXPECTED_GRADE]"
    fi
  fi

  echo "- Setting output parameters"

  {
    echo "$OUTPUT_RESULTS_AS_JSON=$(jq -rc '.' <<<"$API_RESPONSE")"
    echo "$OUTPUT_SUMMARY_AS_JSON=$(jq -rc '.summary' <<<"$API_RESPONSE")"
    echo "$OUTPUT_GRADE=$GRADE"
  } | tee -a "$GITHUB_OUTPUT"

  echo "  Output parameters set successfully!"

  echo "::endgroup::"
}

# start

analyze
