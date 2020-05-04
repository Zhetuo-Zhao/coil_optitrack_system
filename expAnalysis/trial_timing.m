function trialTime = trial_timing(tagData,VIEW)
    for trialIdx=length(tagData.trialEnds):-1:1
        trialTime(trialIdx,2)=tagData.trialEnds(trialIdx);
        trialTime(trialIdx,1)=max(tagData.trialStarts(tagData.trialStarts<tagData.trialEnds(trialIdx)));
        if( trialIdx < length(tagData.trialEnds) && trialTime(trialIdx,1) == trialTime(trialIdx+1,1) )
        	trialTime(trialIdx,1) = NaN;
        end
    end
    trialTime( isnan(trialTime(:,1)), : ) = [];
    
    if VIEW
        figure; plot(trialTime);
    end
end
