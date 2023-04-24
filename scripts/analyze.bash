#!/bin/bash

# https://www.shellcheck.net/wiki/SC2155
# shellcheck disable=SC2155

set -eE -o functrace

fatal() {
  local LINE="$1"
  local CMD="$2"
  echo "[FATAL] $LINE: $CMD" >&2
}

trap 'fatal "$LINENO" "$BASH_COMMAND"' ERR

# functions

analyze() {
  echo "::group::Analyzing [$INPUT_DOMAIN_OR_URL]"

  if [[ $INPUT_FOLLOW_REDIRECTS == "off" ]]; then
    echo
    echo "NOTE: Following of redirect status codes is disabled."
    echo "      Set \`follow-redirects: true\` to get full resutls."
    echo "      Otherwise, you may get an 'R' grade."
    echo
  fi

  local API_URL="https://api.securityheaders.com/?q=$INPUT_DOMAIN_OR_URL&followRedirects=$INPUT_FOLLOW_REDIRECTS&hide=$INPUT_HIDE_RESULTS_ON_HOMEPAGE"
  echo "API URL: [$API_URL]"

  for ((RETRY = 0; RETRY <= INPUT_MAX_RETRIES_ON_API_ERROR; RETRY++)); do
    echo "- Making an API request [$RETRY / $INPUT_MAX_RETRIES_ON_API_ERROR]"

    local IS_ERROR=false
    local API_RESPONSE=""
    if ! API_RESPONSE="$(curl -sS -m "$INPUT_API_TIMEOUT_IN_SECONDS" -H "x-api-key: $INPUT_API_KEY" "$API_URL" 2>&1)"; then
      echo "  $API_RESPONSE"
      IS_ERROR=true
    elif [[ -z $API_RESPONSE ]]; then
      echo "  Empty response!"
      IS_ERROR=true
    elif ! jq '.' <<<"$API_RESPONSE" >/dev/null 2>&1; then
      echo "  $API_RESPONSE"
      IS_ERROR=true
    else
      echo "  Checking API response status"
      local STATUS="$(jq -r '.status | ascii_downcase' <<<"$API_RESPONSE")"
      if [[ $STATUS != "good" ]]; then
        echo "  Invalid status received! [$STATUS]"
        jq -r '.' <<<"$API_RESPONSE"
        IS_ERROR=true
      else
        echo "  API RESPONSE STATUS: [$STATUS]"
      fi
    fi

    if [[ $IS_ERROR == true ]]; then
      if ((RETRY < INPUT_MAX_RETRIES_ON_API_ERROR)); then
        echo "  Retrying..."
      else
        echo "  Exiting..."
        exit 1
      fi
    else
      break
    fi
  done

  local ACTUAL_GRADE="$(jq -r '.summary.grade | ascii_upcase' <<<"$API_RESPONSE")"
  if [[ -n $INPUT_EXPECTED_GRADE ]]; then
    echo "- Checking expected grade"
    echo "  Expected: [$INPUT_EXPECTED_GRADE], Actual: [$ACTUAL_GRADE]"

    local GRADES=(R F E D C B A A+)
    local EXPECTED_GRADE_INDEX=0
    local ACTUAL_GRADE_INDEX=0

    for INDEX in ${!GRADES[*]}; do
      local GRADE="${GRADES[$INDEX]}"
      if [[ $GRADE == "$INPUT_EXPECTED_GRADE" ]]; then
        EXPECTED_GRADE_INDEX="$INDEX"
      fi
      if [[ $GRADE == "$ACTUAL_GRADE" ]]; then
        ACTUAL_GRADE_INDEX="$INDEX"
      fi
    done

    if ((ACTUAL_GRADE_INDEX < EXPECTED_GRADE_INDEX)); then
      echo "  Lower grade found!"
      echo "  Exiting..."
      exit 1
    elif ((ACTUAL_GRADE_INDEX == EXPECTED_GRADE_INDEX)); then
      echo "  Expected grade found!"
    else
      echo "  Higher grade found!"
    fi
  fi

  echo "- Setting output parameters"

  {
    echo "$OUTPUT_RESULTS_AS_JSON=$(jq -rc '.' <<<"$API_RESPONSE")"
    echo "$OUTPUT_SUMMARY_AS_JSON=$(jq -rc '.summary' <<<"$API_RESPONSE")"
    echo "$OUTPUT_GRADE=$ACTUAL_GRADE"
  } | tee -a "$GITHUB_OUTPUT"

  echo "  Output parameters set successfully!"

  echo "::endgroup::"
}

# start

analyze
