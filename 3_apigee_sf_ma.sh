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

echo "Creating KVM"
apigeecli kvms create -e $APIGEE_ENVIRONMENT -n solar-keys -o $PROJECT -t $TOKEN

echo "Adding GMAPS_KEY to KVM"
apigeecli kvms entries create -m solar-keys -k gmaps_key -l $GMAPS_KEY -e $APIGEE_ENVIRONMENT -o $PROJECT -t $TOKEN

echo "Creating Model Armor Templates"
export FILTER_CONFIG='{
    "filterConfig": {
      "piAndJailbreakFilterSettings": {
        "filterEnforcement": "ENABLED",
        "confidenceLevel": "LOW_AND_ABOVE"
      },
      "sdpSettings": {
        "basicConfig": {
          "filterEnforcement": "ENABLED"
        }
      }
    }
  }'
curl -X POST \
  -d $FILTER_CONFIG \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  "https://modelarmor.googleapis.com/v1/projects/$PROJECT/locations/$REGION/templates?template_id=apigee_template_request"
curl -X POST \
  -d $FILTER_CONFIG \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  "https://modelarmor.googleapis.com/v1/projects/$PROJECT/locations/$REGION/templates?template_id=apigee_template_response"

echo "Deploying Shared Flows..."
cd shared-flows

echo "Creating and deploying cl-dataLossPrevention shared flow"
REV=$(apigeecli sharedflows create bundle -f ./cl-dataLossPrevention/sharedflowbundle -n cl-dataLossPrevention --org "$PROJECT" --token "$TOKEN" --disable-check | jq ."revision" -r)
apigeecli sharedflows deploy --wait --name cl-dataLossPrevention --ovr --rev "$REV" --org "$PROJECT" --env "$APIGEE_ENV" --token "$TOKEN"

echo "Creating and deploying cl-ma-sanatizeResponse shared flow"
REV=$(apigeecli sharedflows create bundle -f ./cl-ma-sanatizeResponse/sharedflowbundle -n cl-ma-sanatizeResponse --org "$PROJECT" --token "$TOKEN" --disable-check | jq ."revision" -r)
apigeecli sharedflows deploy --wait --name cl-ma-sanatizeResponse --ovr --rev "$REV" --org "$PROJECT" --env "$APIGEE_ENV" --token "$TOKEN"

echo "Creating and deploying cl-tokenNumber shared flow"
REV=$(apigeecli sharedflows create bundle -f ./cl-tokenNumber/sharedflowbundle -n cl-tokenNumber --org "$PROJECT" --token "$TOKEN" --disable-check | jq ."revision" -r)
apigeecli sharedflows deploy --wait --name cl-tokenNumber --ovr --rev "$REV" --org "$PROJECT" --env "$APIGEE_ENV" --token "$TOKEN"

echo "Creating and deploying clModelArmor shared flow"
REV=$(apigeecli sharedflows create bundle -f ./clModelArmor/sharedflowbundle -n clModelArmor --org "$PROJECT" --token "$TOKEN" --disable-check | jq ."revision" -r)
apigeecli sharedflows deploy --wait --name clModelArmor --ovr --rev "$REV" --org "$PROJECT" --env "$APIGEE_ENV" --token "$TOKEN"

echo "Creating and deploying semantic-cache-request shared flow"
REV=$(apigeecli sharedflows create bundle -f ./semantic-cache-request/sharedflowbundle -n semantic-cache-request --org "$PROJECT" --token "$TOKEN" --disable-check | jq ."revision" -r)
apigeecli sharedflows deploy --wait --name semantic-cache-request --ovr --rev "$REV" --org "$PROJECT" --env "$APIGEE_ENV" --token "$TOKEN"

echo "Creating and deploying semantic-cache-response shared flow"
REV=$(apigeecli sharedflows create bundle -f ./semantic-cache-response/sharedflowbundle -n semantic-cache-response --org "$PROJECT" --token "$TOKEN" --disable-check | jq ."revision" -r)
apigeecli sharedflows deploy --wait --name semantic-cache-response --ovr --rev "$REV" --org "$PROJECT" --env "$APIGEE_ENV" --token "$TOKEN"

echo "Done creating and deploying shared flows"
echo " "
