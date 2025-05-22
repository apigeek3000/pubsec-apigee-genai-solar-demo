#!/bin/bash

# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if [ -z "$PROJECT" ]; then
  echo "No PROJECT variable set"
  exit
fi

if [ -z "$REGION" ]; then
  echo "No REGION variable set"
  exit
fi

if [ -z "$APIGEE_ENVIRONMENT" ]; then
  echo "No APIGEE_ENVIRONMENT variable set"
  exit
fi

if [ -z "$GMAPS_KEY" ]; then
  echo "No GMAPS_KEY variable set"
  exit
fi

echo "Passed variable tests"

echo "Setting project to $PROJECT"
gcloud config set project $PROJECT

export TOKEN=$(gcloud auth print-access-token)

echo "Installing apigeecli"
curl -s https://raw.githubusercontent.com/apigee/apigeecli/main/downloadLatest.sh | bash
export PATH=$PATH:$HOME/.apigeecli/bin

echo "Creating and Deploying Apigee Solar-Agent-v1 proxy..."
REV=$(apigeecli apis create bundle -f api-proxies/Solar-Agent-v1/apiproxy -n Solar-Agent-v1 --org "$PROJECT" --token "$TOKEN" --disable-check | jq ."revision" -r)
apigeecli apis deploy --wait --name Solar-Agent-v1 --ovr --rev "$REV" --org "$PROJECT" --env "$APIGEE_ENV" --token "$TOKEN"

echo "Creating and Deploying Apigee Solar-Service-v1 proxy..."
REV=$(apigeecli apis create bundle -f api-proxies/Solar-Service-v1/apiproxy -n Solar-Service-v1 --org "$PROJECT" --token "$TOKEN" --disable-check | jq ."revision" -r)
apigeecli apis deploy --wait --name Solar-Service-v1 --ovr --rev "$REV" --org "$PROJECT" --env "$APIGEE_ENV" --token "$TOKEN"

# var is expected by integration test (apickli)
export AGENT_PROXY_URL="$APIGEE_HOST/v1/solar-agent"
export SERVICE_PROXY_URL="$APIGEE_HOST/v1/solar-service"

echo " "
echo "All the Apigee artifacts are successfully deployed!"

echo " "
echo "Your Agent Proxy URL is: https://$PROXY_URL"
echo "Your Service Proxy URL is: https://$PROXY_URL"
echo " "
