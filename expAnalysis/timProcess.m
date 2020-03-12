if ~exist('session')
    session='05-Feb-2020';
    direct=['Z:/fieldCalibrate/data/' session '/'];
    folder='session2';
end

if ~exist('head')
    load([direct folder '\processed_head.mat'])
end
if ~exist('eye')
    load([direct folder '\processed_eye.mat'])
end
if ~exist('tagData')
    load([direct folder '\rawData_tag.mat'])
end

trialTim=trial_timing(tagData,0);
trialTim=[trialTim [1:size(trialTim,1)]']; 
timings.trialTim=trialTim;


data2plot{1}=eye.coil_sync{1};  data2plot{2}=eye.pos{1}; data2plot{3}=head.Euler_head;
tagging_plot(tagData.t_sync,data2plot, {'eye coil', 'eye position', 'head rotation'}, tagData);

timings.headFix9pt{1}.trial=trialTim(11,:);
timings.headFix9pt{2}.trial=trialTim(12,:);

timings.headFree9pt{1}.trial=trialTim(7,:);
timings.headFree9pt{2}.trial=trialTim(8,:);

% timings.headFixTable{1}.trial=trialTim(16,:);

timings.headFreeTable{1}.trial=trialTim(9,:);
timings.headFreeTable{2}.trial=trialTim(10,:);

timings.headEyeSacc{1}.trial=trialTim(3,:);
timings.headEyeSacc{2}.trial=trialTim(4,:);
timings.headEyeSacc{3}.trial=trialTim(5,:);
timings.headEyeSacc{4}.trial=trialTim(6,:);

timings.sorting{1}.trial=trialTim(1,:);
timings.sorting{2}.trial=trialTim(2,:);


eyeIdx=1;
%% extract fixation from a trial
trialIdx=2; 
numPts=9;
thre=5E-3;
trialDur=timings.headFree9pt{trialIdx}.trial(1):timings.headFree9pt{trialIdx}.trial(2);
trans=[0 find(diff(eye.coil_vel{eyeIdx}(trialDur)>thre)) length(trialDur)]; 
transIdx=find(diff(trans)>500);

figure; 
subplot(2,1,1); plot(eye.coil_sync{1}(:,trialDur)');
subplot(2,1,2); hold on;
plot(eye.coil_vel{eyeIdx}(trialDur))
for i=length(transIdx):-1:1
    line([trans(transIdx(i)) trans(transIdx(i))],[0 max(eye.coil_vel{eyeIdx}(trialDur))],'color','r');
    line([trans(transIdx(i)+1) trans(transIdx(i)+1)],[0 max(eye.coil_vel{eyeIdx}(trialDur))],'color','b');
end
if length(transIdx)~=numPts
    transIdx(1)=[]; 
end

for ptIdx=numPts:-1:1
    timings.headFree9pt{trialIdx}.fix(ptIdx,1)=trans(transIdx(ptIdx))+trialDur(1);
    timings.headFree9pt{trialIdx}.fix(ptIdx,2)=trans(transIdx(ptIdx)+1)+trialDur(1);
end

for ptIdx=numPts:-1:2
    timings.headFree9pt{trialIdx}.fix(ptIdx-1,1)=trans(transIdx(ptIdx))+trialDur(1);
    timings.headFree9pt{trialIdx}.fix(ptIdx-1,2)=trans(transIdx(ptIdx)+1)+trialDur(1);
end
timings.headFree9pt{trialIdx}.fix(9,1)=trans(transIdx(9)+1)+trialDur(1);
timings.headFree9pt{trialIdx}.fix(9,2)=trialDur(end);

%%
disp('saving data');
save([direct folder '\processed_timings.mat'],'timings');
disp('Done!')