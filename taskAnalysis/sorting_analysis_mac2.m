clear; close all;
% addpath('..\tools\');
% session='06-Mar-2020';
% direct=['../../data/' session '/'];
% folder='run3';
% 
% load([direct folder '\sorting_color_processed.mat']);
% colorData=data;
% load([direct folder '\sorting_identity_processed.mat']);
% identityData=data;

datapath = '/Users/ShellyCox/Box/APLab-Projects/Equipment/Eye Coil/data/06-Mar-2020/run3/';

load([datapath 'sorting_color_processed.mat']);
colorData=data; clear data
load([datapath 'sorting_identity_processed.mat']);
identityData=data; clear data


colorData.eye.sightVec2_1k{1}=vec2ang(colorData.eye.sightVec_1k{1});
colorData.eye.sightVec2_sync{1}=vec2ang(colorData.eye.sightVec_sync{1});
identityData.eye.sightVec2_1k{1}=vec2ang(identityData.eye.sightVec_1k{1});
identityData.eye.sightVec2_sync{1}=vec2ang(identityData.eye.sightVec_sync{1});

colorData.eye.EM=trace_segment(colorData.eye.sightVec2_1k{1}*60);
identityData.eye.EM=trace_segment(identityData.eye.sightVec2_1k{1}*60);


%% various measures of individual drifts
driftDur = cell([1,2]);
gaze2D   = cell([1,2]);
eye2head = cell([1,2]);

for j = 1:2
    clear data
    if j == 1
        data = identityData;
    else
        data = colorData;
    end
    for i=length(data.eye.EM.drifts):-1:1
        dur=data.eye.EM.drifts(i).startTime:data.eye.EM.drifts(i).endTime;
        gaze2D{j}   = [gaze2D{j}   mean(data.eye.gaze2D{1}(2,dur))];
        driftDur{j} = [driftDur{j} data.eye.EM.drifts(i).duration];
        eye2head{j} = [eye2head{j} mean(vecnorm(data.eye.ang2head_1k{1}(:,dur)))];
        
    end
    lns{j} = length(data.eye.sightVec_1k{1})/1000; 
end


%%

figure; set(gcf,'Color',[1 1 1],'Units','Inches','Position',[0 0 10 7]); 
clear hh
hh(1)=histogram(gaze2D{1},30,'normalization','probability','FaceColor','r'); hold on
hh(2)=histogram(gaze2D{2},30,'normalization','probability','FaceColor','k');
set(gca,'box','off','tickdir','out','Xgrid','on','ygrid','on','FontSize',12)
plot([0.05 0.05],ylim,'k','LineWidth',2)
legend(hh,...
    sprintf('Identity, N = %u fixations over %0.1f s', length(gaze2D{1}),lns{1}),...
    sprintf('Color,  N = %u fixations over %0.1f s', length(gaze2D{2}),lns{2}),...
    'location','southoutside')
ylabel('Normalized Frequency')
xlabel('Vertical Position of Gaze on Table (m)')


%%

figure; set(gcf,'Color',[1 1 1],'Units','Inches','Position',[0 0 10 7])

for k = 1:2
    if k == 1
        I = cellfun(@(x) x < 0.05, gaze2D,'UniformOutput',0); 
        tstrloc = 'gaze near ice tray';
    else
        I = cellfun(@(x) x > 0.05, gaze2D,'UniformOutput',0); 
        tstrloc = 'gaze near beads';
    end



subplot(2,2, 1 + (k-1))
histogram(driftDur{1}(I{1}),30,'normalization','probability','FaceColor','r'); hold on
histogram(driftDur{2}(I{2}),30,'normalization','probability','FaceColor','k');
[~,p,~,stats] = ttest2(driftDur{2}(I{2}),driftDur{1}(I{1}));

set(gca,'box','off','tickdir','out','Xgrid','on','ygrid','on','FontSize',12)
legend(...
    sprintf('Identity, M = %0.0f, SD = %0.0f',mean(driftDur{1}(I{1})),std(driftDur{1}(I{1}))),...
    sprintf('Color, M = %0.0f, SD = %0.0f ',mean(driftDur{2}(I{2})),std(driftDur{2}(I{2}))),...
    'location','southoutside')
ylabel('Normalized Frequency')
xlabel('Drift Duration (ms)')
title(sprintf('%s\nt(%u) = %0.1f, p = %0.3f',tstrloc,stats.df,stats.tstat,p))


subplot(2,2, 3 + (k-1))
histogram(eye2head{1}(I{1}),30,'normalization','probability','FaceColor','r'); hold on
histogram(eye2head{2}(I{2}),30,'normalization','probability','FaceColor','k');
[~,p,~,stats] = ttest2(eye2head{2}(I{2}),eye2head{1}(I{1}));
set(gca,'box','off','tickdir','out','Xgrid','on','ygrid','on','FontSize',12)
legend(...
    sprintf('Identity, M = %0.1f, SD = %0.1f',mean(eye2head{1}(I{1})),std(eye2head{1}(I{1}))),...
    sprintf('Color, M = %0.1f, SD = %0.1f ',mean(eye2head{2}(I{2})),std(eye2head{2}(I{2}))),...
    'location','southoutside')
ylabel('Normalized Frequency')
xlabel('eye2head')
title(sprintf('%s\nt(%u) = %0.1f, p = %0.3f',tstrloc,stats.df,stats.tstat,p))



end

%%


figure; set(gcf,'Color',[1 1 1],'Units','Inches','Position',[0 0 10 7])

for j = 1:2
    subplot(2,1,j)
    plot([1:length(identityData.eye.sightVec2_1k{1}(j,:))] ./ 1000,...
        identityData.eye.sightVec2_1k{1}(j,:),'r-'); hold on;
    plot([1:length(colorData.eye.sightVec2_1k{1}(j,:))] ./ 1000,...
        colorData.eye.sightVec2_1k{1}(j,:),'k-'); hold on;
    xlabel('Time (s)')
    if j == 1
        ylabel('Horizontal Angle (deg)');
    else
        ylabel('Vertical Angle (deg)');
    end
    set(gca,'box','off','tickdir','out','Xgrid','on','ygrid','on','FontSize',12)
    axis tight;
    legend('identityData','colorData','location','best')
    
end



