var payload = JSON.parse(context.getVariable('maResponse.content'));
var  dlpContent = context.getVariable('dlpContent');

var reason = "";

if (payload.sanitizationResult.filterMatchState === "MATCH_FOUND") {
    dlpResponse = payload.sanitizationResult.filterResults.sdp.sdpFilterResult.deidentifyResult.data.text
} else  dlpResponse = dlpContent;

context.setVariable("dlpResponse", dlpResponse);
