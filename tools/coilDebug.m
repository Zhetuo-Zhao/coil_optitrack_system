clear; close all;
addpath('..\tools\')
%% set directory
session='03-Mar-2020';
direct=['Z:/fieldCalibrate/data/' session '/'];
folder='eyeCoil_80K';

VIEW=1; 

outputFolder=[direct folder '/Figures/'];
if ~exist(outputFolder)
   mkdir(outputFolder); 
end

R_opti2room=[0 0 -1;-1 0 0 ; 0 1 0];

%% load files
coil_fileName=[folder '_coil.csv'];
optitrack_fileName=[folder '.csv'];

disp('loading coil data');
cidx=[1 3 4]; % channels that have coils plugged in. [1 5 3 4]


SETTINGS_FILENAME = [folder '_settings.mat'];
TAGS_FILENAME = [folder '_tags.csv'];
DATA_FILENAME = [folder '_coil.csv'];
coil_loader = CoilLoader([direct folder '/'],DATA_FILENAME, TAGS_FILENAME, SETTINGS_FILENAME);

% tagData.eyeProbe= coil_loader.computeEyeprobeFramesRaw();
% tagData.calib= coil_loader.computeCalibrationFrames();
% [tagData.trialStarts, tagData.trialEnds]= coil_loader.computeTrials(); % needs update
% [tagData.user1, tagData.user2]= coil_loader.computeUserTagFrames();

[refRawData{1}, refRawData{2}, refRawData{3}] = coil_loader.getReferenceCoils();
[coilRaw{1}, coilRaw{2}] = coil_loader.getEyeCoils();
[coilRaw{3}, coilRaw{4}] = coil_loader.getHelmetCoils();

t=coil_loader.getTimeStamps(); coilData.t=t;
Fs=1/mean(diff(t));  coilData.Fs=Fs;
[frame_sync, t_sync] = coil_loader.computeFrameStarts();
coilData.t_sync=t_sync';
tagData.t_sync=t_sync';

t_1k=t_sync(1):1/1200:t_sync(end);
frame_1k=round(frame_sync(1):Fs/1200:frame_sync(end));

coilData.t_1k=t_1k;
coilData.frame_1k=frame_1k;
clearvars coil_loader


%% construct wavelets
freq3=[12E3 16E3 20E3];

L=round(Fs/100); std=L/3;
Gau=exp(-(-L:L).^2/(2*std^2))/sqrt(2*pi*std^2);
for i=3:-1:1
    wavelets{i}=Gau.*(exp(1i*2*pi*freq3(i)/Fs*(-L:L))); 
end


%% extract three frequency component from test coil

for i=3:-1:1
    for ci=cidx
        tmp=conv(coilRaw{ci},wavelets{i}); tmp=tmp(L+1:end-L);
        
        coilData.amp_sync{ci}(i,:)=abs(tmp(frame_sync));
        coilData.phase_sync{ci}(i,:)=angle(tmp(frame_sync));
        
        coilData.amp_1k{ci}(i,:)=abs(tmp(frame_1k));
        coilData.phase_1k{ci}(i,:)=angle(tmp(frame_1k));
        clearvars tmp;
    end
    for refCoilIdx=1:3
        tmp=conv(refRawData{refCoilIdx},wavelets{i}); tmp=tmp(L+1:end-L);
        
        coilData.ref_amp_sync{refCoilIdx}(i,:)=abs(tmp(frame_sync));
        coilData.ref_phase_sync{refCoilIdx}(i,:)=angle(tmp(frame_sync));
        
        coilData.ref_amp_1k{refCoilIdx}(i,:)=abs(tmp(frame_1k));
        coilData.ref_phase_1k{refCoilIdx}(i,:)=angle(tmp(frame_1k));
        clearvars tmp;
    end
end

save([direct folder '/coilDebug.mat'],'coilRaw','refRawData','coilData')
