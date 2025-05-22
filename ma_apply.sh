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

curl -X PATCH \
-H "Authorization: Bearer $GCLOUD_AUTH_TOKEN" \
-H "Content-Type: application/json" \
-d "$FILTER_CONFIG" \
"https://modelarmor.us-central1.rep.googleapis.com/v1alpha/projects/ignite2024-446018/locations/us-central1/templates/apigee_template?update_mask=filter_config"

curl -X PATCH \
-H "Authorization: Bearer $GCLOUD_AUTH_TOKEN" \
-H "Content-Type: application/json" \
-d $FILTER_CONFIG \
"https://modelarmor.us-central1.rep.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/$LOCATION/templates/$TEMPLATE_ID?update_mask=filter_config"

https://modelarmor.us-central1.rep.googleapis.com/v1alpha/projects/ignite2024-446018/locations/us-central1/templates/apigee-template?update_mask=filter_config