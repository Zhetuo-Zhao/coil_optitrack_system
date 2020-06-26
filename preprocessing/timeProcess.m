function timings=timeProcess(tagData,params,eye)

    
    

    
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






%% extract fixation from a trial
while (1)
% choose a task
disp('Choose a task (type STOP if you want to stop)'); 
[taskName,idx]=wordSearch(timings.taskNames); 
if isempty(taskName)
    break;
else
    disp(['task: ' taskName])
    tmp=eval(['timings.' taskName]); % selected task.

    % choose a trial and name it currTrial
    if length(tmp)>1
       trialIdx=input(sprintf('which of the %d trials ? ', length(tmp)));
       currTrial= tmp{trialIdx};
    else
       currTrial= tmp{1};
    end

    % choose a threshold of eye coil velocity for saccade detection.
    trialDur=currTrial.trial(1)-0.5*240:currTrial.trial(2)+0.8*240;
    thre = 6E-3; % threshold of eye coil velocity for saccade detection.
    figure('position',[100 100 1200 800]); 
    h1=subplot(2,1,1); plot(eye.coil_sync{1}(:,trialDur)'); title('raw eye coil data');
    h2=subplot(2,1,2); hold on; plot(eye.coilVel_sync{1}(trialDur));  title('velocity of eye coil');
    line(xlim,[thre thre],'lineStyle','--', 'color',[0.5 0.5 0.5]);
    linkaxes([h1 h2],'x');
    while(1)
        goodFlag=input('Is the threshold for eye velocity OK, Y/N? ','s');
        if strcmp(goodFlag,'N')
            thre=input('Input new threshold ');
            line(xlim,[thre thre],'lineStyle','--', 'color',[0.5 0.5 0.5]);
        else
            break;
        end
    end


    % choose fixations that corresponding to the fixation points 
    trans=[0 find(diff(eye.coilVel_sync{1}(trialDur)>thre)) length(trialDur)]; 
    transIdx=find(diff(trans)>300); % extract fixations long than 0.3 sec

    % mark fixation candidates
    subplot(2,1,1); hold on;
    for i=length(transIdx):-1:1
        line([trans(transIdx(i)) trans(transIdx(i))],ylim,'color','r');
        line([trans(transIdx(i)+1) trans(transIdx(i)+1)],ylim,'color','b');
    end

    % delete if more, most case is the first fixation
    fixNum=input('How many fixation points expected? ');
    if length(transIdx)>fixNum
        fi=input('More than expected fixations are detected. Which fixations to exclude? ');
        for i=length(fi):-1:1
            transIdx(fi(i))=[]; 
        end
    end

    % replot to confirm correctness
    figure('position',[100 100 1200 800]); 
    h1=subplot(2,1,1); hold on;
    plot(eye.coil_sync{1}(:,trialDur)'); title('raw eye coil data');
    for i=length(transIdx):-1:1
        line([trans(transIdx(i)) trans(transIdx(i))],ylim,'color','r');
        line([trans(transIdx(i)+1) trans(transIdx(i)+1)],ylim,'color','b');
    end
    h2=subplot(2,1,2); hold on; plot(eye.coilVel_sync{1}(trialDur));  title('velocity of eye coil');
    line(xlim,[thre thre],'lineStyle','--', 'color',[0.5 0.5 0.5]);
    linkaxes([h1 h2],'x');

    % if still incorrect, we ask the user the delete incorrect ones and add
    % the ones missing
    goodFlag=input('Are fixations marked correct, Y/N? ','s');
    if strcmp(goodFlag,'N')
        fi=input('Which fixations to exclude? ');
        for i=length(fi):-1:1
            transIdx(fi(i))=[]; 
        end

        extraFix_tmp=input('Which fixations to add? [p1x p1y p2x p2y ...]');
        extraFix=reshape(extraFix_tmp,[2 length(extraFix_tmp)/2]);
    end

    % save fixation points to timing struct
    for ptIdx = length(transIdx):-1:1
        fix(ptIdx,1)=trans(transIdx(ptIdx))+trialDur(1);
        fix(ptIdx,2)=trans(transIdx(ptIdx)+1)+trialDur(1);
    end
    if exist('extraFix')
        fix=[fix extraFix];
    end

    eval(['timings.' taskName '{' num2str(trialIdx) '}.fix=fix'])
end
end
%% save data
disp('saving data');
save([params.inputPath 'processed_timings.mat'],'timings');
disp('Done!')
