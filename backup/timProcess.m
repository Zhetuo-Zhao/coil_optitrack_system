function timings=timProcess(tagData)

trialTime = trialTiming(tagData,0);
trialTime = [trialTime [1:size(trialTime,1)]']; 
timings.trialTime = trialTime;


headFixRowId_1 = input("which row in trialTime corresponds to first fixed head 9pt calib?"); %11
headFixRowId_2 = input("which row in trialTime corresponds to second fixed head 9pt calib?"); %12

timings.headFix9pt{1}.trial=trialTime(headFixRowId_1,:);
timings.headFix9pt{2}.trial=trialTime(headFixRowId_2,:);

headFreeRowId_1 = input("which row in trialTime corresponds to first free head 9pt calib?"); %7
headFreeRowId_2 = input("which row in trialTime corresponds to second free head 9pt calib?"); %8

timings.headFree9pt{1}.trial=trialTime(headFreeRowId_1,:);
timings.headFree9pt{2}.trial=trialTime(headFreeRowId_2,:);

% timings.headFixTable{1}.trial=trialTim(16,:);
headFree_table_RowId_1 = input("which row in trialTime corresponds to first free head table 9pt calib?"); %9
headFree_table_RowId_2 = input("which row in trialTime corresponds to second free head table 9pt calib?"); %10


timings.headFreeTable{1}.trial=trialTime(headFree_table_RowId_1,:);
timings.headFreeTable{2}.trial=trialTime(headFree_table_RowId_2,:);

hESacc_RowId_1 = input("which row in trialTime corresponds to 1st head eye saccade?"); %3
hESacc_RowId_2 = input("which row in trialTime corresponds to 2nd head eye saccade?"); %4
hESacc_RowId_3 = input("which row in trialTime corresponds to 3rd head eye saccade?"); %5
hESacc_RowId_4 = input("which row in trialTime corresponds to 4rth head eye saccade?"); %6

timings.headEyeSacc{1}.trial=trialTime(hESacc_RowId_1,:);
timings.headEyeSacc{2}.trial=trialTime(hESacc_RowId_2,:);
timings.headEyeSacc{3}.trial=trialTime(hESacc_RowId_3,:);
timings.headEyeSacc{4}.trial=trialTime(hESacc_RowId_4,:);

sort_rowId_1 = input("which row to use for first sorting time?");
sort_rowId_2 = input("which row to use for second sorting time?");

timings.sorting{1}.trial=trialTime(sort_rowId_1,:); %1
timings.sorting{2}.trial=trialTime(sort_rowId_2,:); %2

eyeProbe_rowId = input("which row to use for eye probe?");
timings.eyeProbe.trial=trialTim(eyeProbe_rowId,:);
%eyeIdx = 1;


%% extract fixation from a trial
trialIdx = input("which idx of the trial do you want to look into?"); %2 
%thre = 5E-3;
trialDur = timings.headFree9pt{trialIdx}.trial(1):timings.headFree9pt{trialIdx}.trial(2);
trans=[0 find(diff(eye.coil_vel{params.eyeIdx}(trialDur)>params.threshold)) length(trialDur)]; 
transIdx=find(diff(trans)>500);

figure; 
subplot(2,1,1); plot(eye.coil_sync{1}(:,trialDur)');
subplot(2,1,2); hold on;
plot(eye.coil_vel{params.eyeIdx}(trialDur))
for i=length(transIdx):-1:1
    line([trans(transIdx(i)) trans(transIdx(i))],[0 max(eye.coil_vel{params.eyeIdx}(trialDur))],'color','r');
    line([trans(transIdx(i)+1) trans(transIdx(i)+1)],[0 max(eye.coil_vel{params.eyeIdx}(trialDur))],'color','b');
end
if length(transIdx)~= params.numCalibPts
    transIdx(1)=[]; 
end

for ptIdx = params.numCalibPts:-1:1
    timings.headFree9pt{trialIdx}.fix(ptIdx,1)=trans(transIdx(ptIdx))+trialDur(1);
    timings.headFree9pt{trialIdx}.fix(ptIdx,2)=trans(transIdx(ptIdx)+1)+trialDur(1);
end

for ptIdx = params.numCalibPts:-1:2
    timings.headFree9pt{trialIdx}.fix(ptIdx-1,1)=trans(transIdx(ptIdx))+trialDur(1);
    timings.headFree9pt{trialIdx}.fix(ptIdx-1,2)=trans(transIdx(ptIdx)+1)+trialDur(1);
end
timings.headFree9pt{trialIdx}.fix(9,1)=trans(transIdx(9)+1)+trialDur(1);
timings.headFree9pt{trialIdx}.fix(9,2)=trialDur(end);

%%
disp('saving data');
save([params.inputPath 'processed_timings.mat'],'timings');
disp('Done!')
