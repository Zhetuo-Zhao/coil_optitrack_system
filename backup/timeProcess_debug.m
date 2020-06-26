

    
    trialTime = trialTiming(tagData,0);
    trialTime = [trialTime [1:size(trialTime,1)]']; 
    timings.trialTime = trialTime;
    
    pattern = 'trials_';
    fields = fieldnames(params);
    params2Cell = struct2cell(params);
    check_reqdStrings = startsWith(fields,pattern);
    reqdIdxs = find(check_reqdStrings == 1);
    
    
    for taskI = 1:length(reqdIdxs)
        taskName = fields{reqdIdxs(taskI)};
        split_taskName = split(taskName, 'trials_');
        timings.taskNames{taskI}=split_taskName{2};
        trialNum = params2Cell{reqdIdxs(taskI)};
        
        for trialI = 1:trialNum
            trialTime
            trialIdx=input(['which row in trialTime corresponds to trial ' num2str(trialI) ' of task ' split_taskName{2} '? ']);
            
            varName1 = "timings" + "." + split_taskName{2} + "{" + num2str(trialI) + "}" + ".trial";
            %varName1 = "timings" + "." + split_taskName{2} + "(" + num2str(trialI) + "," + ":" + ")";
            varName2 = "trialTime" + "(" + num2str(trialIdx) + "," + ":" + ")";
            eval(varName1 + "=" + string(varName2));
            
        end
    end

trialTime
eyeProbe_rowId = input('which row in trialTime corresponds to trial eye probe? ');
timings.eyeProbe.trial=trialTime(eyeProbe_rowId,:);
timings.taskNames{taskI+1}='eyeProbe';


