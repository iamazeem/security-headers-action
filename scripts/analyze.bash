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

  # INPUT_MAX_RETRIES_ON_API_ERROR

  local API_URL="https://api.securityheaders.com/?q=$INPUT_DOMAIN_OR_URL&followRedirects=$INPUT_FOLLOW_REDIRECTS&hide=$INPUT_HIDE_RESULTS_ON_HOMEPAGE"
  echo "Making API request [$API_URL]"
  local API_RESPONSE="$(curl -s -m "$INPUT_API_TIMEOUT_IN_SECONDS" -H "x-api-key: $INPUT_API_KEY" "$API_URL" 2>&1)"
  if [[ -z $API_RESPONSE ]]; then
    echo "Empty response!"
    exit 1
  elif ! jq '.' <<<"$API_RESPONSE" >/dev/null 2>&1; then
    echo "Invalid respone!"
    echo "$API_RESPONSE"
    exit 1
  fi

  echo "Checking status"
  local STATUS="$(jq -r '.status | ascii_downcase' <<<"$API_RESPONSE")"
  if [[ $STATUS != "good" ]]; then
    echo "Invalid response status received! [$STATUS]"
    jq -r '.' <<<"$API_RESPONSE"
    exit 1
  else
    echo "STATUS: [$STATUS]"
  fi

  if [[ -n $INPUT_EXPECTED_GRADE ]]; then
    echo "Checking expected grade [$INPUT_EXPECTED_GRADE]"
    local GRADE="$(jq -r '.summary.grade | ascii_upcase' <<<"$API_RESPONSE")"
    echo "Expected: [$INPUT_EXPECTED_GRADE], Found: [$GRADE]"
    if [[ $INPUT_EXPECTED_GRADE != "$GRADE" ]]; then
      echo "Unexpected grade found!"
      exit 1
    else
      echo "Expected grade found! [$INPUT_EXPECTED_GRADE]"
    fi
  fi

  echo "Setting output parameters"

  {
    echo "$OUTPUT_RESULTS_AS_JSON=$(jq -rc '.' <<<"$API_RESPONSE")"
    echo "$OUTPUT_SUMMARY_AS_JSON=$(jq -rc '.summary' <<<"$API_RESPONSE")"
    echo "$OUTPUT_GRADE=$(jq -r '.summary.grade | ascii_upcase' <<<"$API_RESPONSE")"
  } | tee -a "$GITHUB_OUTPUT"

  echo "::endgroup::"
}

# start

analyze
