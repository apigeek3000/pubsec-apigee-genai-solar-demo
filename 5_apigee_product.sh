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

echo "Creating API Products"
apigeecli products create --name solar-product --display-name "solar-product" --opgrp ./5_solar_product.json --envs "$APIGEE_ENV" --approval auto --quota 10 --interval 1 --unit minute --org "$PROJECT" --token "$TOKEN"

echo "Creating Developer"
apigeecli developers create --user solaruser --email solarusers@example.com --first Solar --last User --org "$PROJECT" --token "$TOKEN"

echo "Creating Developer Apps"
apigeecli apps create --name solar-app --email solarusers@example.com --prods solar-product --org "$PROJECT" --token "$TOKEN" --disable-check

echo " "
echo "Successfully created Apigee solar product, developer, and app"
echo " "