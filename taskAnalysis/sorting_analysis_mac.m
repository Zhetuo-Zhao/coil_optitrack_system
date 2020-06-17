clear; close all;

datapath = '/Users/ShellyCox/Box/APLab-Projects/Equipment/Eye Coil/data/06-Mar-2020/run3/';

load([datapath 'sorting_color_processed.mat']);
colorData=data; clear data
load([datapath 'sorting_identity_processed.mat']);
identityData=data; clear data
load([datapath 'eyeCalibTable.mat'])


colorData.eye.sightVec2_1k{1}=vec2ang(colorData.eye.sightVec_1k{1});
colorData.eye.sightVec2_sync{1}=vec2ang(colorData.eye.sightVec_sync{1});
identityData.eye.sightVec2_1k{1}=vec2ang(identityData.eye.sightVec_1k{1});
identityData.eye.sightVec2_sync{1}=vec2ang(identityData.eye.sightVec_sync{1});




figure

for j = 1:2
    subplot(2,1,j)
    plot(identityData.eye.sightVec2_1k{1}(j,:),'k-'); hold on;
    plot(colorData.eye.sightVec2_1k{1}(j,:),'r--'); hold on;
    xlabel('Time (ms)')
    if j == 1
        ylabel('Horizontal Angle (deg)'); 
    else
        xlabel('Vertical Angle (deg)'); 
    end
    set(gca,'box','off','tickdir','out','Xgrid','on','ygrid','on','FontSize',12)
axis tight; 
    legend('identityData','colorData','location','best')

end


figure

ln = min([length(identityData.eye.sightVec2_1k{1}) length(colorData.eye.sightVec2_1k{1})]);
for j = 1:2
    subplot(2,1,j)
    plot(identityData.eye.sightVec2_1k{1}(j,1:ln) - colorData.eye.sightVec2_1k{1}(j,1:ln) ,'b-'); hold on;
    xlabel('Time (ms)')
    if j == 1
        ylabel('Horizontal Angle (deg)'); 
    else
        xlabel('Vertical Angle (deg)'); 
    end
    set(gca,'box','off','tickdir','out','Xgrid','on','ygrid','on','FontSize',12)
    axis tight
        legend('identityData - colorData','location','best')

end


error('stop here')

%%

colorData.eye.EM=trace_segment(colorData.eye.sightVec2_1k{1}*60);
identityData.eye.EM=trace_segment(identityData.eye.sightVec2_1k{1}*60);

for i = 1:length(eyeCalibTable.eyePos)
eyeCalibTable.eyePos{i} = vec2ang(eyeCalibTable.eyePos{i});
end



grid on

figure
subplot(1,2,1)
plot(colorData.eye.sightVec2_1k{1}(1,:),colorData.eye.sightVec2_1k{1}(2,:),'k'); hold on;








%% fixaiton duration
driftDur{1}=[]; driftDur{2}=[];
for i=length(colorData.eye.EM.drifts):-1:1
    dur=colorData.eye.EM.drifts(i).startTime:colorData.eye.EM.drifts(i).endTime;
    if mean(colorData.eye.gaze2D{1}(2,dur))>0.02
        driftDur{1}=[driftDur{1} colorData.eye.EM.drifts(i).duration];
    end
end
for i=length(identityData.eye.EM.drifts):-1:1
    dur=identityData.eye.EM.drifts(i).startTime:identityData.eye.EM.drifts(i).endTime;
    if mean(identityData.eye.gaze2D{1}(2,dur))>0.02
        driftDur{2}=[driftDur{2} identityData.eye.EM.drifts(i).duration];
    end
end

figure; hold on;
histogram(driftDur{1},30,'normalization','probability');
histogram(driftDur{2},30,'normalization','probability');

% eye in the head
eye2head{1}=[]; eye2head{2}=[];
for i=length(colorData.eye.EM.drifts):-1:1
    dur=colorData.eye.EM.drifts(i).startTime:colorData.eye.EM.drifts(i).endTime;
    if mean(colorData.eye.gaze2D{1}(2,dur))>0.02
        eye2head{1}=[eye2head{1} mean(vecnorm(colorData.eye.ang2head_1k{1}(:,dur)))];
    end
end
for i=length(identityData.eye.EM.drifts):-1:1
    dur=identityData.eye.EM.drifts(i).startTime:identityData.eye.EM.drifts(i).endTime;
    if mean(identityData.eye.gaze2D{1}(2,dur))>0.02
        eye2head{2}=[eye2head{2} mean(vecnorm(identityData.eye.ang2head_1k{1}(:,dur)))];
    end
end

figure; hold on;
histogram(eye2head{1},30,'normalization','probability');
histogram(eye2head{2},30,'normalization','probability');