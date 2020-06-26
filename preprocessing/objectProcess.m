

helmet.coilMarkerL = params.headCoilL; %5
helmet.coilMarkerR = params.headCoilR; %1

plot_each_frame(helmet,timings.eyeProbe.trial(1), params.opti2roomTransMatrix)
disp(sprintf('[left head coil:%d;  right head coil: %d ]',helmet.coilMarkerL,helmet.coilMarkerR));

confirmFlag=input('Are the marker corresponding to head coils correct?  Y/N: ','s');
if strcmp(confirmFlag,'N')
    headCoilMarker = input('what are the markers? '); 
    helmet.coilMarkerL=headCoilMarker(1);
    helmet.coilMarkerR=headCoilMarker(2);
end

%% headRest
taskName=wordSearch(timings.taskNames,{'eye','probe'}); 
taskTime=eval(['timings.' taskName]); % selected task.
if length(taskTime)>1
    trialTime=taskTime{1}.trial;
else
    trialTime=taskTime.trial;
end
trialDur=[trialTime(1):trialTime(2)];

data2plot{1}=helmet.pos-mean(helmet.pos(:,trialDur),2); data2plot{2}=helmet.q-mean(helmet.q(:,trialDur),2); data2plot{3}=headRest.pos-mean(headRest.pos(:,trialDur),2);
taggingPlot(1:length(tagData.t_sync),data2plot, {'helmet position (m)','helmet rotation', 'headRest position (m)'},tagData,...
           [timings.eyeProbe.trial(1)-200 timings.eyeProbe.trial(2)+200]);
startSample_headRestFrame=timings.eyeProbe.trial(1);
endSample_headRestFrame=timings.eyeProbe.trial(2);
confirmFlag=input(sprintf('Is the time interval [%d %d] correct?  Y/N: ',startSample_headRestFrame,endSample_headRestFrame),'s');
if strcmp(confirmFlag,'N')
    startSample_headRestFrame = input('what is the starting sample of head rest ON? '); %211293
    endSample_headRestFrame = input('what is the ending sample of head rest ON? '); %219338  
end
headRest.Frames= [startSample_headRestFrame:endSample_headRestFrame];  % the time samples in which the headrest is mounted on the table


plot_each_frame(headRest,trialTime(1), params.opti2roomTransMatrix)
markerIdx=params.headRestMarkers;
if length(headRest.marker)==4
    disp(sprintf('[%d %d %d %d]',markerIdx(1),markerIdx(2),markerIdx(3),markerIdx(4)));
end
if length(headRest.marker)==5
    disp(sprintf('[%d %d %d %d %d]',markerIdx(1),markerIdx(2),markerIdx(3),markerIdx(4),markerIdx(5)));
end
confirmFlag=input('Is the order of markers correct (the extra marker should be the last one, first 3/4 should be in the same vertical plane)?  Y/N: ','s');
if strcmp(confirmFlag,'N')
    markerIdx = input('what are the active markers? (SHOULD BE A LIST)'); %[1 2 3 4 5]
end
% this function gives the norm vector orthogonal to the head rest plane (facing forward)
headRest = getHeadRestFromOptiTrack(headRest,headRest.Frames,markerIdx); %first 3 marker are in the same vertical plane


%% eyeProbe
taskName=wordSearch(timings.taskNames,{'eye','probe'}); 
taskTime=eval(['timings.' taskName]); % selected task.
if length(taskTime)>1
    trialTime=taskTime{1}.trial;
else
    trialTime=taskTime.trial;
end
plot_each_frame(eyeProbe,trialTime(1),params.opti2roomTransMatrix);
eyeProbeMarkers=params.eyeProbeMarkers;
disp(sprintf('[%d %d %d %d]',eyeProbeMarkers(1),eyeProbeMarkers(2),eyeProbeMarkers(3),eyeProbeMarkers(4)));
confirmFlag=input('Is the order of markers correct (the end of the probe should be the last one)?  Y/N: ','s');
if strcmp(confirmFlag,'N')
    eyeProbeMarkers = input('what are the eye probe indexes? (the end of the probe should be the last one) '); %[5 4 2 6]
end

trialDur=[trialTime(1):trialTime(2)];
data2plot{1}=eyeProbe.pos-mean(eyeProbe.pos(:,trialDur),2); data2plot{2}=vecnorm(eyeProbe.pos-helmet.pos); data2plot{3}=eyeProbe.q-mean(eyeProbe.q(:,trialDur),2);
taggingPlot([1:size(eyeProbe.pos,2)],data2plot, {'eyeProbe position (m)','distance between eyeProbe and helmet (m)', 'eyeProbe quanternion'}, tagData,[timings.eyeProbe.trial(1)-200 timings.eyeProbe.trial(2)+200]);

for eyeIdx=1:length(params.eyeChannel)
    startSample_eyeProbeFrame = input('what is the starting sample for eye probe touching the eyelid? '); %228001
    endSample_eyeProbeFrame = input('what is the ending sample for eye probe touching the eyelid? '); %228241
    eyeProbe.Frames{eyeIdx}=[startSample_eyeProbeFrame:endSample_eyeProbeFrame]; 
    eyeProbe = getEyeProbeFromOptiTrack(eyeProbe,eyeProbe.Frames,0.012,eyeProbeMarkers); 
end

%% 9-point grid
taskName=wordSearch(timings.taskNames,{'9pt','head','fix'},{'table'}); 
taskTime=eval(['timings.' taskName]); % selected task.
if length(taskTime)>1
    trialTime=taskTime{1}.trial;
else
    trialTime=taskTime.trial;
end
plot_each_frame(ninePoints,trialTime(1),params.opti2roomTransMatrix)
ninePtsMarkerIdxs=params.ninePtsMarkers;
disp(sprintf('[%d %d %d]',ninePtsMarkerIdxs(1),ninePtsMarkerIdxs(2),ninePtsMarkerIdxs(3)));
disp(sprintf('[%d %d %d]',ninePtsMarkerIdxs(4),ninePtsMarkerIdxs(5),ninePtsMarkerIdxs(6)));
disp(sprintf('[%d %d %d]',ninePtsMarkerIdxs(7),ninePtsMarkerIdxs(8),ninePtsMarkerIdxs(9)));
confirmFlag=input('Is the order of markers for the 9pt grid correct (left to right, top to bottom)?  Y/N: ','s');
if strcmp(confirmFlag,'N')
    ninePtsMarkerIdxs = input("what are the marker indexes for the 9pt grid? (left to right, top to bottom)");
end
ninePoints.markerIdx=ninePtsMarkerIdxs;    %[9 6 4 8 1 3 7 2 5]
for ptIdx=1:length(ninePoints.markerIdx)
    ninePoints.markerPos_room{ptIdx}=params.opti2roomTransMatrix*ninePoints.marker{ninePoints.markerIdx(ptIdx)}.pos;
end

%% table
taskName=wordSearch(timings.taskNames,{'table'}); 
taskTime=eval(['timings.' taskName]);
if length(taskTime)>1
    trialTime=taskTime{1}.trial;
else
    trialTime=taskTime.trial;
end
plot_each_frame( table, trialTime(1),params.opti2roomTransMatrix);
tableMarkerIdxs=params.tableMarkers;
disp(sprintf('[%d %d %d %d %d]',tableMarkerIdxs(1),tableMarkerIdxs(2),tableMarkerIdxs(3),tableMarkerIdxs(4),tableMarkerIdxs(5)));
confirmFlag=input('Is the order of markers for the table correct (clockwise starting from top left)?  Y/N: ','s');
if strcmp(confirmFlag,'N')
    tableMarkerIdxs = input("what are the marker indexes for table? (clockwise starting from top left)");
end
table.markerIdx = tableMarkerIdxs; %[5 1 2 3 4]
for ptIdx=1:length(table.markerIdx)
    table.markerPos_room{ptIdx}=params.opti2roomTransMatrix*table.marker{table.markerIdx(ptIdx)}.pos;
end

%% table grid
taskName=wordSearch(timings.taskNames,{'table'});
if length(taskTime)>1
    trialTime=taskTime{1}.trial;
else
    trialTime=taskTime.trial;
end
taskTime=eval(['timings.' taskName]);
plot_each_frame( tableGrid, trialTime(1),params.opti2roomTransMatrix);
tableGridMarkerIdxs=params.tableGridMarkers;
disp(sprintf('[%d %d %d]',tableGridMarkerIdxs(1),tableGridMarkerIdxs(2),tableGridMarkerIdxs(3)));
disp(sprintf('[%d   %d]',tableGridMarkerIdxs(7),tableGridMarkerIdxs(4)));
disp(sprintf('[%d   %d]',tableGridMarkerIdxs(6),tableGridMarkerIdxs(5)));
confirmFlag=input('Is the order of markers for the table grid correct (clockwise starting from top left)?  Y/N: ','s');
if strcmp(confirmFlag,'N')
    tableGridMarkerIdxs = input("what are the marker indexes for table grid? (clockwise starting from top left)");
end
tableGrid.markerIdx = tableGridMarkerIdxs; %[7 3 4 5 6 2 1 8]
for ptIdx=1:length(tableGrid.markerIdx)
    tableGrid.markerPos_room{ptIdx}=params.opti2roomTransMatrix*tableGrid.marker{tableGrid.markerIdx(ptIdx)}.pos;
end

%% save
save([params.inputPath 'processed_objects.mat'],'helmet','headRest','eyeProbe','ninePoints','tableGrid','table','iceTray','head_eye');










