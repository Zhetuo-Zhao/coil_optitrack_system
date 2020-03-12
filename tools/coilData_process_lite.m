function coilData=coilData_process_lite(direct,folder,channels,VIEW, outputFolder,opt)


%% load .csv file
SETTINGS_FILENAME = [folder '_settings.mat'];
TAGS_FILENAME = [folder '_tags.csv'];
DATA_FILENAME = [folder '_coil.csv'];
coil_loader = CoilLoader([direct folder '/'],DATA_FILENAME, TAGS_FILENAME, SETTINGS_FILENAME);

% reference coil
[ref12k, ref16k, ref20k] = coil_loader.getReferenceCoils();
refRawData{1}=ref12k';  refRawData{2}=ref16k';  refRawData{3}=ref20k'; 

[left_eye_voltage, right_eye_voltage] = coil_loader.getEyeCoils();
[side_helmet, back_helmet] = coil_loader.getHelmetCoils();

% signal coil
coilRaw{1}=left_eye_voltage';
coilRaw{2}=right_eye_voltage';
coilRaw{3}=side_helmet';
coilRaw{4}=back_helmet';

% t_sync
t=coil_loader.getTimeStamps();
Fs=1/mean(diff(t));
[frame_sync, t_sync] = coil_loader.computeFrameStarts();
if isempty(t_sync)
    if exist('opt','var')
        coilData.t_sync=opt;
        for tt=length(opt):-1:1
            [~,idx]=min(abs(t-opt(tt)));
            frame_sync(tt)=idx;
        end
    else
        error('no camera exposure tags, need time stamp from optitrack data');
    end
else
    coilData.t_sync=t_sync';
end
clearvars coil_loader left_eye_voltage right_eye_voltage side_helmet back_helmet ref12k ref16k ref20k;


%% construct wavelets
bw=500; 
freq3=[12E3 16E3 20E3];

L=round(Fs/500); std=L/3;
Gau=exp(-(-L:L).^2/(2*std^2))/sqrt(2*pi*std^2);
for i=3:-1:1
    wavelets{i}=Gau.*(exp(1i*2*pi*freq3(i)/Fs*(-L:L))); 
end


%% extract three frequency component from test coil

for i=3:-1:1
    for chIdx=channels
        tmp=conv(coilRaw{chIdx},wavelets{i}); tmp=tmp(L+1:end-L);
        coilData.amp_sync{chIdx}(i,:)=abs(tmp(frame_sync));
        coilData.phase_sync{chIdx}(i,:)=angle(tmp(frame_sync));
        clearvars tmp;
    end
    
    for refCoilIdx=1:3
        tmp=conv(refRawData{refCoilIdx},wavelets{i}); tmp=tmp(L+1:end-L);
        coilData.ref_amp_sync{refCoilIdx}(i,:)=abs(tmp(frame_sync));
        coilData.ref_phase_sync{refCoilIdx}(i,:)=angle(tmp(frame_sync));
        clearvars tmp;
    end
end



%% figure out the sign
for i=3:-1:1
    for chIdx=channels
        diff_tmp=coilData.ref_phase_sync{i}(i,:)- coilData.phase_sync{chIdx}(i,:);
        phDiff_sync=min(abs([-2*pi+diff_tmp; diff_tmp; 2*pi+diff_tmp]));

        coilData.sig_sync{chIdx}(i,:)=signDecode(coilData.amp_sync{chIdx}(i,:), phDiff_sync,outputFolder,VIEW,i);
    end
end




for t=length(coilData.sig_sync{channels(1)}):-1:1
    for chIdx=channels
        coilData.sig_syncR{chIdx}(:,t)=[coilData.ref_amp_sync{1}(:,t) coilData.ref_amp_sync{2}(:,t) coilData.ref_amp_sync{3}(:,t)]\coilData.sig_sync{chIdx}(:,t);
    end
end
   

%    
% axis3={'x','y','z'};
%     if VIEW
%    
%         
%         figure;
%         for i=1:3
%         subplot(3,1,i);  hold on;
%         plot(coilData.amp_sync(i,:));
%         plot(coilData.sig_sync(i,:));
%         title([axis3{i} ' readings'])
%         end
%         saveas(gcf,[outputFolder 'coil_sync' '.png'])
%         saveas(gcf,[outputFolder 'coil_sync'], 'epsc')
%         saveas(gcf,[outputFolder 'coil_sync.fig'])
%         
%         figure;
%         for i=1:3
%         subplot(3,1,i);  hold on;
%         plot((coilData.sig_sync(i,:)-coilData.sig_sync(i,1))/var(coilData.sig_sync(i,:)));
%         plot((coilData.sig_syncR(i,:)-coilData.sig_syncR(i,1))/var(coilData.sig_syncR(i,:)));
%         title([axis3{i} ' readings'])
%         end
%         saveas(gcf,[outputFolder 'coil_syncR' '.png'])
%         saveas(gcf,[outputFolder 'coil_syncR'], 'epsc')
%         saveas(gcf,[outputFolder 'coil_syncR.fig'])
%     end
end