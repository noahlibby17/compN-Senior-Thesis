

% Extract Relevant Features
[featData, labels, winTime, featOptions] = extractFeatures([preProcFinalRoot saveFname '.mat'], featOptions);

save([preProcFinalRoot saveFname '_Features_Overlap_Time.mat'], 'featData', 'labels', 'featOptions', 'winTime');