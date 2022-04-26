#!/bin/bash

# Define/get all variables
SLACK_BASE_URL="https://slack.com/api/chat.postMessage"
SLACK_BEARER_TOKEN=$1
SLACK_CHANNEL=$2
ACTION_STATUS=$3
ACTION_PREVIOUS_STATUS=$4
GIT_BRANCH=$5
GIT_SHA=$6
GIT_SHORT_SHA=$7
GIT_COMMIT_MESSAGE=$8
GIT_AUTHOR_FIRSTNAME=$9

# If previous and current action succeeded, there is no need for a Slack notification
if [ "$ACTION_STATUS" == "success" ] && [ "$ACTION_PREVIOUS_STATUS" == "success" ]; then
  # Exit script without sending a Slack notification
  exit 0;
fi

# Define message string
message=""

# If action failed
if [ "$ACTION_STATUS" == "failure" ]; then
  message+=":no_entry: daalder/feeds tests failed for"
else
  # If action succeeded
  message+=":white_check_mark: daalder/feeds tests fixed with"
fi

# Include branch, url to commit, commiter name, commit message
message+=" \`$GIT_BRANCH\` @ \`<https://github.com/Daalder/feeds/commit/$GIT_SHA|$GIT_SHORT_SHA>\` by @$GIT_AUTHOR_FIRSTNAME."
message+=" Commit message: \`$GIT_COMMIT_MESSAGE\`"

# Post formatted message to Slack
curl -X POST \
  -H "Authorization: Bearer $SLACK_BEARER_TOKEN" \
  "$SLACK_BASE_URL?channel=$SLACK_CHANNEL&link_names=true&pretty=1" \
  --data-urlencode "text=$message"
