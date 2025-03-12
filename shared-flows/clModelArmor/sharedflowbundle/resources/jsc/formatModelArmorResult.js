var payload = JSON.parse(context.getVariable('maResponse.content'));
var reason = "";

if (payload.sanitizationResult.filterMatchState === "MATCH_FOUND") {
    for (var i = 0; i < payload.sanitizationResult.filterResults.length; i++) {
        var filterResult = payload.sanitizationResult.filterResults[i];
        for (var filterName in filterResult) { 
            if (filterResult[filterName].matchState === "MATCH_FOUND") {
                if (filterName === "raiFilterResult") {
                    for (var j = 0; j < filterResult[filterName].raiFilterTypeResults.length; j++) {
                        if (filterResult[filterName].raiFilterTypeResults[j].matchState === "MATCH_FOUND") {
                            reason += ", " + filterName + " (" + filterResult[filterName].raiFilterTypeResults[j].filterType + " - "+ filterResult[filterName].raiFilterTypeResults[j].confidenceLevel.toLowerCase() + ")";
                        }
                    }
                } else {
                    reason += ", " + filterName;
                }
            }
        }
    }
    if (reason.length > 2) {
        reason = reason.substring(2); // Remove leading ", "
    }
} else  reason = "none";

context.setVariable("modeleArmor_error", reason);
