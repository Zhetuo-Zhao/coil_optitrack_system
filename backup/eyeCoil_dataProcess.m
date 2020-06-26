clear; close all;
addpath('..\tools\')
%% set directory
session='05-Feb-2020';
direct=['Z:/fieldCalibrate/data/' session '/'];
% direct=['\\opus.cvs.rochester.edu\aplab\fieldCalibrate/data/' session '/'];
folder='eyeCoilCalibration2';

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
active_channels=[2]; % channels that have coils plugged in. 
coilData=coilData_process_lite(direct,folder,active_channels,VIEW, outputFolder); 

disp('Done!');


disp('loading optitrack data');
optiData = loadOptiTrack([direct folder '/' optitrack_fileName],20);
disp('Done!')


% sync between coil and optitrack
for i=length(coilData.t_sync):-1:1
    [~,idx]=min(abs(coilData.t_sync(i)-optiData.time));
    optSyncIdx(i)=idx;
end
objects=optSync(optiData,optSyncIdx);

coilV=coilData.sig_syncR{2};
posV=objects{5}.pos;
qV=objects{5}.q;
save([direct folder '\processed_data.mat'],'coilV','posV','qV');
