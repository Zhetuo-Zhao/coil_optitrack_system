function [coilData, tagData] = processCoilData(params)
% inputs -> params containing 
% folder of coil data file
% filename: file name of coil data file
% VIEW: a flag determines whether to mat the figures
% outputFolder: folder to save the figures
% section: section of the data collection: 1, 2, 3, ...
%
% output: 
% coilData: 3xT matrix [coil 12k; coil 16k; coil 20k]
% timeLine: time stamp 
% Fs: sampling frequency

inputPath = [params.inputPath params.date '/'];
outputPath = [inputPath params.session '/Figures/'];

if ~exist(outputPath)
    mkdir(outputPath); 
end

%% load .csv file
SETTINGS_FILENAME = [params.session '_settings.mat'];
TAGS_FILENAME = [params.session '_tags.csv'];
DATA_FILENAME = [params.session '_coil.csv'];
coil_loader = CoilLoader([inputPath params.session '/'],DATA_FILENAME, TAGS_FILENAME, SETTINGS_FILENAME);

tagData.eyeProbe= coil_loader.computeEyeprobeFramesRaw();
tagData.calib= coil_loader.computeCalibrationFrames();
[tagData.trialStarts, tagData.trialEnds]= coil_loader.computeTrials(); % needs update
[tagData.user1, tagData.user2]= coil_loader.computeUserTagFrames();

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

L=round(Fs/300); std=L/3;
Gau=exp(-(-L:L).^2/(2*std^2))/sqrt(2*pi*std^2);
for i=3:-1:1
    wavelets{i}=Gau.*(exp(1i*2*pi*freq3(i)/Fs*(-L:L))); 
end


%% extract three frequency component from test coil

for i=3:-1:1
    for ci=params.activeChannels
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


%% figure out the sign
for i=3:-1:1
    for ci=params.activeChannels
        diff_tmp=coilData.ref_phase_sync{i}(i,:)- coilData.phase_sync{ci}(i,:);
        phDiff=min(abs([-2*pi+diff_tmp; diff_tmp; 2*pi+diff_tmp]));
        coilData.sig_sync{ci}(i,:)=signDecode(coilData.amp_sync{ci}(i,:), phDiff,outputPath,params.VIEW,i);
        
        
        diff_tmp=coilData.ref_phase_1k{i}(i,:)- coilData.phase_1k{ci}(i,:);
        phDiff=min(abs([-2*pi+diff_tmp; diff_tmp; 2*pi+diff_tmp]));
        coilData.sig_1k{ci}(i,:)=signDecode(coilData.amp_1k{ci}(i,:), phDiff,outputPath,params.VIEW,i);
    end
end

for t=length(t_sync):-1:1
    for ci=params.activeChannels
        coilData.sig_syncR{ci}(:,t)=[coilData.ref_amp_sync{1}(:,t) coilData.ref_amp_sync{2}(:,t) coilData.ref_amp_sync{3}(:,t)]\coilData.sig_sync{ci}(:,t); 
    end
end

for t=length(t_1k):-1:1
    for ci=params.activeChannels
       coilData.sig_1kR{ci}(:,t)=[coilData.ref_amp_1k{1}(:,t) coilData.ref_amp_1k{2}(:,t) coilData.ref_amp_1k{3}(:,t)]\coilData.sig_1k{ci}(:,t);
    end
end

for ci=params.activeChannels
    coilData.sig_syncR{ci}(1,:)=-coilData.sig_syncR{ci}(1,:);
    coilData.sig_1kR{ci}(1,:)=-coilData.sig_1kR{ci}(1,:);
end
   
axis3={'x','y','z'};
coilName={'leftEye','rightEye','helmetSide','helmetBack'};
    if params.VIEW
   
        for ci=params.activeChannels
            figure;
            for i=1:3     
                subplot(3,1,i);  hold on;
                plot(coilData.amp_sync{ci}(i,:));
                plot(coilData.sig_sync{ci}(i,:));
                plot(coilData.sig_syncR{ci}(i,:));
                title([axis3{i} ' readings'])
            end
%             saveas(gcf,[outputPath coilName{ci} '_coil_sync' '.png'])
%             saveas(gcf,[outputPath coilName{ci} '_coil_sync'], 'epsc')
%             saveas(gcf,[outputPath coilName{ci} '_coil_sync' '.fig'])
        end
        
        
        for ci=params.activeChannels
            figure;
            for i=1:3     
                subplot(3,1,i);  hold on;
                plot(coilData.amp_1k{ci}(i,:));
                plot(coilData.sig_1k{ci}(i,:));
                plot(coilData.sig_1kR{ci}(i,:));
                title([axis3{i} ' readings'])
            end
%             saveas(gcf,[outputPath coilName{ci} '_coil_1k' '.png'])
%             saveas(gcf,[outputPath coilName{ci} '_coil_1k'], 'epsc')
%             saveas(gcf,[outputPath coilName{ci} '_coil_1k' '.fig'])
        end
    end
end