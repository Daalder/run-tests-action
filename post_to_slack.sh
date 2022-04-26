#!/bin/bash

SLACK_BASE_URL="https://slack.com/api/chat.postMessage"
SLACK_BEARER_TOKEN=$1
SLACK_CHANNEL=$2
GIT_STATUS=$3
GIT_BRANCH=$4
GIT_SHA=$5
GIT_SHORT_SHA=$6
GIT_COMMIT_MESSAGE=$7
GIT_AUTHOR_FIRSTNAME=$8

message=""

if [ "$GIT_STATUS" == "failure" ]; then
  message+=":no_entry: daalder/feeds tests failed"
else
  message+=":white_check_mark: daalder/feeds tests succeeded"
fi

message+=" for \`$GIT_BRANCH\` @ \`<https://github.com/Daalder/feeds/commit/$GIT_SHA|$GIT_SHORT_SHA>\` by @$GIT_AUTHOR_FIRSTNAME."
message+=" Commit message: \`$GIT_COMMIT_MESSAGE\`"

echo "$message"
echo ""

curl -X POST \
  -H "Authorization: Bearer $SLACK_BEARER_TOKEN" \
  "$SLACK_BASE_URL?channel=$SLACK_CHANNEL&link_names=true&pretty=1" \
  --data-urlencode "text=$message"
