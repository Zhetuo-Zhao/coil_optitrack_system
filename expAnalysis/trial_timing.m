function trialTim=trial_timing(tagData,VIEW)
    for trialIdx=length(tagData.trialEnds):-1:1
        trialTim(trialIdx,2)=tagData.trialEnds(trialIdx);
        trialTim(trialIdx,1)=max(tagData.trialStarts(tagData.trialStarts<tagData.trialEnds(trialIdx)));
        if( trialIdx < length(tagData.trialEnds) && trialTim(trialIdx,1) == trialTim(trialIdx+1,1) )
        	trialTim(trialIdx,1) = NaN;
    end
    trialTim( isnan(trialTim(:,1)), : ) = [];
    
    if VIEW
        figure; plot(trialTim);
    end
end