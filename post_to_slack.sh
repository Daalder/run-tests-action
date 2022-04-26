#!/bin/bash

# Define/get all variables
SLACK_BASE_URL="https://slack.com/api/chat.postMessage"
SLACK_BEARER_TOKEN=$1
SLACK_CHANNEL=$2
ACTION_STATUS=$3
ACTION_PREVIOUS_STATUS=$4
ACTION_RUN_ID=$5
GITHUB_REPOSITORY=$6
GIT_BRANCH=$7
GIT_SHA=$8
GIT_SHORT_SHA=$9
GIT_COMMIT_MESSAGE=${10}
GIT_AUTHOR_FIRSTNAME=${11}
GIT_AUTHOR_FULLNAME=${12}
ACTION_URL="https://github.com/$GITHUB_REPOSITORY/actions/runs/$ACTION_RUN_ID"

# If previous and current action succeeded, there is no need for a Slack notification
if [ "$ACTION_STATUS" == "success" ] && [ "$ACTION_PREVIOUS_STATUS" == "success" ]; then
  # Exit script without sending a Slack notification
  exit 0;
fi

# Define message string
pretext=""
color=""

# If action failed
if [ "$ACTION_STATUS" == "failure" ]; then
  pretext+=":no_entry: <$ACTION_URL|Pipeline #$ACTION_RUN_ID> *failed* for \`$GIT_BRANCH\` @ \`<https://github.com/$GITHUB_REPOSITORY/commit/$GIT_SHA|$GIT_SHORT_SHA>\`."
  color="#FF5630"
else
  # If action succeeded
  pretext+=":white_check_mark: <$ACTION_URL|Pipeline #$ACTION_RUN_ID> *fixed* for \`$GIT_BRANCH\` @ \`<https://github.com/$GITHUB_REPOSITORY/commit/$GIT_SHA|$GIT_SHORT_SHA>\`."
  color="#36B37E"
fi

# Get Slack user id
SLACK_USER_ID=$(curl -X GET \
  -H "Authorization: Bearer $SLACK_BEARER_TOKEN" \
  "https://slack.com/api/users.list" \
  | jq .members \
  | jq -c ".[] | select(.name | test(\"$GIT_AUTHOR_FIRSTNAME\"; \"i\"))" \
  | jq .id \
  | xargs)

# Prepare Slack message
message="{
  \"channel\": \"$SLACK_CHANNEL\",
  \"link_names\": 1,
  \"attachments\": [
    {
      \"mrkdwn_in\": [\"text\"],
      \"color\": \"$color\",
      \"pretext\": \"$pretext\",
      \"author_name\": \"$GIT_AUTHOR_FULLNAME\",
      \"fields\": [
        {
          \"value\": \"\`<https://github.com/$GITHUB_REPOSITORY/commit/$GIT_SHA|$GIT_SHORT_SHA>\` $GIT_COMMIT_MESSAGE (by <@$SLACK_USER_ID>).\",
          \"short\": false
        }
      ],
      \"footer\": \"<https://github.com/$GITHUB_REPOSITORY|$GITHUB_REPOSITORY>\",
      \"footer_icon\": \"https://daalder.io/app/themes/daalder/assets/images/favicons/favicon.ico\"
    }
  ]
}"

# Debugging:
#echo "========================="
#echo "$message"
#echo "========================="

## Post formatted message to Slack
curl -X POST \
  -H "Authorization: Bearer $SLACK_BEARER_TOKEN" \
  -H 'Content-Type: application/json; charset=utf-8' \
  "$SLACK_BASE_URL?channel=$SLACK_CHANNEL&link_names=true&pretty=1" \
  --data "$message"
