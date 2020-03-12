clear; close all;

session='20-Dec-2019';

VIEW=1; 

%direct=['Z:/fieldCalibrate/data/' session '/'];
direct=['\\opus.cvs.rochester.edu\aplab\fieldCalibrate\data\' session '/'];
% direct=['/media/aplab/fieldCalibrate/data/' session '/'];
folder='calibrate1';

outputFolder=[direct folder '/Figures/'];
if ~exist(outputFolder)
   mkdir(outputFolder); 
end
coil_fileName=[folder '_coil.csv'];
optitrack_fileName=[folder '.csv'];

addpath('../dataLoader/') ;
R_opti2room=[0 0 -1; -1 0 0; 0 1 0];

% optiData = loadOptiTrack([direct folder '/' optitrack_fileName],20);

coilData=coilData_process_lite2(direct,[3 4],folder,VIEW,outputFolder);

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
sliderCoil=coilData.sig_syncR{2};

figure; 
h1=subplot(2,1,1); plot(slider.pos');
h2=subplot(2,1,2); plot(slider.q');
linkaxes([h1 h2],'x')


%%


startV=[0.2E4 1.16E5 2.41E5 3.07E5];
endV=[1.03E5 2.33E5 3.02E5 3.94E5];


for si=1:4
    coilOpti{si}=getCoil(coilData.t_sync(startV(si):endV(si)),sliderObj.pos(:,startV(si):endV(si)),sliderObj.q(:,startV(si):endV(si))...
                         ,si, R_opti2room', VIEW,outputFolder);
    if VIEW
        axis3={'x','y','z'};
        figure;
        for i=1:3
            h{i}=subplot(3,1,i);
            yyaxis left;
            plot(coilData.t_sync(startV(si):endV(si)),...
                 abs(sliderCoil(i,startV(si):endV(si))),...
                 'displayName','coil data');
             yyaxis right;
            plot(coilData.t_sync(startV(si):endV(si)),...
                 abs(coilOpti{si}.nc(i,:)),...
                 'displayName','optitrack data');

            legend show;
            title([axis3{i} ' reading']);
        end 
        linkaxes([h{1} h{2} h{3}],'x')
        saveas(gcf,[outputFolder sprintf('coil_opti_sync_%d',si) '.png'])
        saveas(gcf,[outputFolder sprintf('coil_opti_sync_%d',si)], 'epsc')
        saveas(gcf,[outputFolder sprintf('coil_opti_sync_%d',si) '.fig'])
    end
    
    coil{si}=sliderCoil(:,startV(si):endV(si));
    pos{si}=coilOpti{si}.pos;
    nc{si}=coilOpti{si}.nc;
end

coilData_varinfo=whos('coilData');
optiData_varinfo=whos('optiData');
coilOpti_varinfo=whos('coilOpti');
if coilData_varinfo.bytes+optiData_varinfo.bytes+coilOpti_varinfo.bytes>2^31
    save([direct folder '/' 'syncData.mat'],'coilData', 'optiData','coilOpti','-v7.3')
else           
    save([direct folder '/' 'syncData.mat'],'coilData', 'optiData','coilOpti')
end 
    
pos_varinfo=whos('pos');
nc_varinfo=whos('nc');
coil_varinfo=whos('coil');
if pos_varinfo.bytes+nc_varinfo.bytes+coil_varinfo.bytes>2^31
    save([direct folder '/' 'syncData_lite.mat'],'pos', 'nc', 'coil','-v7.3');
else
    save([direct folder '/' 'syncData_lite.mat'],'pos', 'nc', 'coil');
end


%localFit