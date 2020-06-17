clear; close all;
addpath(fullfile('..', 'tools'));
% session='06-Mar-2020';
% direct=['../../data/' session '/'];
% folder='run3';
%
% load([direct folder '\sorting_color_processed.mat']);
% colorData=data;
% load([direct folder '\sorting_identity_processed.mat']);
% identityData=data;

datapath = '/Users/ShellyCox/Box/APLab-Projects/Equipment/Eye Coil/data/06-Mar-2020/run3/';
datapath = fullfile('..', '..', 'data', '06-Mar-2020', 'run3');

load(fullfile(datapath, 'sorting_color_processed.mat'));
colorData=data; clear data
load(fullfile(datapath, 'sorting_identity_processed.mat'));
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

driftData = struct();
dcount = 0;

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
        
        if length(dur) < 100
            continue;
        end
        
        % getDriftChar exists on gitlab in Utilities repository
        [span, mn_speed, mn_cur, varx, vary, smx, smy, smx1, smy1] = getDriftChar(...
            data.eye.EM.drifts(i).x, ...
            data.eye.EM.drifts(i).y, ...
            31, 31, inf, 1000);
        % smoothing window (31ms), cut first and last 31ms from each
        % trace, maximum velocity is inf, Fs = 1000
        
        dcount = dcount + 1;
        driftData(dcount).taskIndex = j;
        driftData(dcount).driftIndex = i;
        driftData(dcount).duration = length(dur);
        driftData(dcount).timeIndices = dur;
        driftData(dcount).span = span;
        driftData(dcount).speed = mn_speed;
        driftData(dcount).curvature = mn_cur;
        driftData(dcount).varx = varx;
        driftData(dcount).vary = vary;
        driftData(dcount).x = data.eye.EM.drifts(i).x;
        driftData(dcount).y = data.eye.EM.drifts(i).y;
        driftData(dcount).iceTray = gaze2D{j}(end) < 0.05;
        driftData(dcount).beads = gaze2D{j}(end) > 0.05;
    end
    lns{j} = length(data.eye.sightVec_1k{1})/1000;
end

%%
cols = 'rk';
taskIndex = [driftData.taskIndex];
onIceTray = [driftData.iceTray];
onBeads = [driftData.beads];
flds = {'span', 'speed', 'curvature'};
units = {'arcmin', 'arcmin/s', 'arcmin^{-1}'};
taskNames = {'Identity', 'Color'};
binedges = {linspace(0, 60, 30), linspace(60, 240, 30), linspace(0, 25, 30)};
for k = 1:2
    for fi = 1:length(flds)
        sv = cell(1, 2);
        figure; hold on;
        for j = 1:2
            if k == 1
                use = (taskIndex(:) == j) & onBeads(:); % check this task, & on beads
                tstrloc = 'gaze near beads';
            elseif k == 2
                use = (taskIndex(:) == j) & onIceTray(:); % check this task, & on beads
                tstrloc = 'gaze near ice tray';
            end
            xxx = [driftData(use).(flds{fi})];
            sv{j} = xxx;
            n = histcounts(xxx, binedges{fi});
            c = binedges{fi}(1:end-1) + mean(diff(binedges{fi}))/2;
            hh(j) = plot(c, n, [cols(j), '-'], 'linewidth', 2,...
                'DisplayName', sprintf('%s: M=%1.2f, SD=%1.2f, N=%i',...
                taskNames{j}, nanmean(xxx), nanstd(xxx), length(xxx)));
            xlabel(sprintf('%s (%s)', flds{fi}, units{fi}));
            ylabel('# Drifts');
        end
        [~, p, ~, stats] = ttest2(sv{1}, sv{2});
        [~, p_ks, ksstat] = kstest2(sv{1}, sv{2});
        
%         title(sprintf('%s\nt(%u) = %0.1f, p = %0.3f',tstrloc,stats.df,stats.tstat,p))
        title(sprintf('%s\np(%u) = %0.3f',tstrloc,ksstat,p_ks))
        set(gca,'box','off','tickdir','out','Xgrid','on','ygrid','on','FontSize',12)
        legend(hh, ...
            'location','southoutside');
    end
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



%% saccades
color_sacc_amp = cat(2, [colorData.eye.EM.saccs.size], [colorData.eye.EM.mSaccs.size]);
identity_sacc_amp = cat(2, [identityData.eye.EM.saccs.size], [identityData.eye.EM.mSaccs.size]);

binedges = linspace(0, 10, 50);
bincenters = binedges(1:end-1) + mean(diff(binedges))/1;

colorn = histcounts(color_sacc_amp / 60, binedges);
identityn = histcounts(identity_sacc_amp / 60, binedges);

figure(); hold on;
hh(2) = plot(bincenters, colorn, 'r-', 'linewidth', 2);
hh(1) = plot(bincenters, identityn, 'k-', 'linewidth', 2);
xlabel('amplitude (deg)');
ylabel('# Saccades');
legend(hh,...
    sprintf('Identity, N = %u saccades over %0.1f s', length(identity_sacc_amp),lns{1}),...
    sprintf('Color,  N = %u saccades over %0.1f s', length(color_sacc_amp),lns{2}),...
    'location','southoutside');
set(gca,'box','off','tickdir','out','Xgrid','on','ygrid','on','FontSize',12)
axis tight;

%% microsaccades

binedges = linspace(0, 121, 10);
bincenters = binedges(1:end-1) + mean(diff(binedges))/1;

colorn = histcounts(color_sacc_amp, binedges);
identityn = histcounts(identity_sacc_amp, binedges);

figure(); hold on;
hh(2) = plot(bincenters, colorn, 'k-', 'linewidth', 2);
hh(1) = plot(bincenters, identityn, 'r-', 'linewidth', 2);
xlabel('amplitude (arcmin)');
ylabel('# Saccades');
legend(hh,...
    sprintf('Identity, N = %u microsaccades over %0.1f s', sum(identity_sacc_amp <= 120),lns{1}),...
    sprintf('Color,  N = %u microsaccades over %0.1f s', sum(color_sacc_amp <= 120),lns{2}),...
    'location','southoutside');
set(gca,'box','off','tickdir','out','Xgrid','on','ygrid','on','FontSize',12)
axis tight;
