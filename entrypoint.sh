#!/bin/sh -l

URL=$1
TOKEN=$2
APP_ID=$3
ENVIRONMENT=${4:-production}
BRANCH="${5:-$GITHUB_REF_NAME}"
HASH="${6:-$GITHUB_SHA}"

if [ -z "$HASH" ]; then
    PAYLOAD="{ \"environment\":\"$ENVIRONMENT\", \"git\": { \"branch\": \"$BRANCH\" } }"
else
    PAYLOAD="{ \"environment\":\"$ENVIRONMENT\", \"git\": { \"branch\": \"$BRANCH\", \"hash\": \"$HASH\" } }"
fi

response_code=$(curl -s -o result.json -w "%{response_code}" -X POST \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    "$URL/api/v1/apps/$APP_ID/deployments" \
    -d "$PAYLOAD")

if [ $response_code != "201" ]; then
    echo "Failed to create the deployment"
    cat result.json
    exit 1
fi

deployment_number=$(cat result.json | jq -r '.deployment_number')

echo "Deployment #$deployment_number created, waiting for it to complete..."

while true
do
    response_code=$(curl -s -o result.json -w "%{response_code}" -X GET \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        "$URL/api/v1/apps/$APP_ID/deployments/$deployment_number")

    if [ $response_code != "200" ]; then
        echo "Failed to get the deployment status"
        cat result.json
        exit 1
    fi

    status=$(cat result.json | jq -r '.state.status')

    if [ $status == "2" ]; then
        echo "Deployment failed: $(cat result.json | jq -r '.state.error_code')"
        break
    elif [ $status == "3" ]; then
        echo "Deployment succeeded!"
        echo "url=$(cat result.json | jq -r '.state.services[].entrypoints[] | select( .is_custom == false ).url')" >> $GITHUB_OUTPUT
        break
    fi

    sleep 3
done