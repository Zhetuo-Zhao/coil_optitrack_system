clear; close all;

session='24-Feb-2020';

VIEW=1; 

direct=['Z:/fieldCalibrate/data/' session '/'];
% direct=['\\opus.cvs.rochester.edu\aplab\fieldCalibrate\data\' session '/'];
% direct=['/media/aplab/fieldCalibrate/data/' session '/'];
folder='coilCalib';

outputFolder=[direct folder '/Figures/'];
if ~exist(outputFolder)
   mkdir(outputFolder); 
end
coil_fileName=[folder '_coil.csv'];
optitrack_fileName=[folder '.csv'];

addpath('../tools/') ;
R_opti2room=[0 0 -1; -1 0 0; 0 1 0];
coilIdx=2;

optiData = loadOptiTrack([direct folder '/' optitrack_fileName],20);

coilData=coilData_process_lite(direct,folder,coilIdx,VIEW,outputFolder,optiData.time);

save([direct folder '/' 'dataBackup.mat'],'coilData','optiData','-v7.3');

if VIEW
    figure;
    subplot(2,2,1); hold on; plot(coilData.t_sync); plot(optiData.time); 
    subplot(2,2,2); hold on; plot(diff(coilData.t_sync)); plot(diff(optiData.time)); 
    subplot(2,2,3); hist(diff(coilData.t_sync),20)
    subplot(2,2,4); hist(diff(optiData.time),20) 
    saveas(gcf,[outputFolder 'sync_debug' '.png'])
    saveas(gcf,[outputFolder 'sync_debug'], 'epsc')
    saveas(gcf,[outputFolder 'sync_debug.fig'])
end

for i=length(coilData.t_sync):-1:1
    [~,idx]=min(abs(coilData.t_sync(i)-optiData.time));
    optIdx(i)=idx;
end


optiObjects=optSync(optiData,optIdx);

sliderObj=optiObjects{1};
sliderCoil=coilData.sig_syncR{coilIdx};

figure; 
h1=subplot(2,1,1); plot(sliderObj.pos');
h2=subplot(2,1,2); plot(sliderObj.q');
linkaxes([h1 h2],'x')


