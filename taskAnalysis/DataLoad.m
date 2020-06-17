clear; close all;
addpath('..\tools\')
%% set directory
session='06-Mar-2020';
direct=['Z:/fieldCalibrate/data/' session '/'];
folder='run3';

VIEW=1; 

outputFolder=[direct folder '/Figures/'];
if ~exist(outputFolder)
   mkdir(outputFolder); 
end

R_opti2room=[0 0 -1;-1 0 0 ; 0 1 0]; % transform matrix from optitrack coordinate to the cage coordinate

%% load files
coil_fileName=[folder '_coil.csv'];
optitrack_fileName=[folder '.csv'];

disp('loading coil data');
active_channels=[2 3 4]; % channels that have coils plugged in. [1 5 3 4]     %not clear 
[coilData,tagData]=coilData_process(direct,folder,active_channels,VIEW, outputFolder); 
disp('Done!');


disp('loading optitrack data');
optiData = loadOptiTrack([direct folder '/' optitrack_fileName],20);
disp('Done!')




% sync between coil and optitrack
disp('sync');
for i=length(coilData.t_sync):-1:1
    [~,idx]=min(abs(coilData.t_sync(i)-optiData.time));
    optSyncIdx(i)=idx;
end
objects=optSync(optiData,optSyncIdx);
disp('Done!')

tagData.t_sync=coilData.t_sync;
tagData.t_1k=coilData.t_1k;
disp('saving data');
save([direct folder '\rawData_coil.mat'],'coilData');
save([direct folder '\rawData_tag.mat'],'tagData');
save([direct folder '\rawData_opti.mat'],'objects');
disp('Done!')