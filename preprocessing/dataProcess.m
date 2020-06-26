addpath('..\tools\')

direct = 'C:\Users\Ruccilab\Box\coil\data\';
Date = '06-Mar-2020';
session = 'run3';

inputPath = [direct Date '/' session '/'];
outputPath = [inputPath '/Figures/']; 
if ~exist(outputPath)
    mkdir(outputPath); 
end

params.VIEW =1;  % whether to plot figures
params.SAVE =1; % whether to save figures

%% load parameter file
load([inputPath 'params.mat'])
params.direct = direct; params.date = Date;  params.session = session;
params.inputPath = inputPath; params.outputPath = outputPath;
save([inputPath 'params.mat'],'params')

%% loading coil and optitrack data, will take a long period of time
[objects,optiData,tagData,coilData,optSyncIdx] = loadData(params);


%% print out and define the names of all objects
disp('extract object names');
for i=1:length(objects)
    objectsName{i}=objects{i}.name;
end


[objName,idx]=wordSearch(objectsName,{'nine','p','t'});   ninePoints = objects{idx};
[objName,idx]=wordSearch(objectsName,{'table'},{'grid'});   table = objects{idx};
[objName,idx]=wordSearch(objectsName,{'table','grid'});   tableGrid = objects{idx};
[objName,idx]=wordSearch(objectsName,{'helmet'});   helmet = objects{idx};
[objName,idx]=wordSearch(objectsName,{'eye','probe'});   eyeProbe = objects{idx};
[objName,idx]=wordSearch(objectsName,{'tray'});   iceTray = objects{idx};
[objName,idx]=wordSearch(objectsName,{'head','rest'});   headRest = objects{idx};
[objName,idx]=wordSearch(objectsName,{'head','eye'});   head_eye = objects{idx};

disp('Done');

%% head and eye coil [Left, Right]
disp('extract head and eye coil data');
for coilIdx=1:length(params.eyeChannel)
    channelIdx=params.eyeChannel(coilIdx);
    if ~isempty(coilData.sig_syncR{channelIdx})... 
    && sum(coilData.sig_syncR{channelIdx}(1,:)<0)/length(coilData.sig_syncR{channelIdx}(1,:))<0.4 ...
    && sum(coilData.sig_syncR{channelIdx}(2,:)<0)/length(coilData.sig_syncR{channelIdx}(2,:))<0.4
        eye.coil_sync{coilIdx}=-coilData.sig_syncR{channelIdx};
        eye.coil_1k{coilIdx}=-coilData.sig_1kR{channelIdx}; 
    else
        eye.coil_sync{coilIdx}=coilData.sig_syncR{channelIdx};
        eye.coil_1k{coilIdx}=coilData.sig_1kR{channelIdx}; 
    end
    eye.coilVel_sync{coilIdx}=vecnorm(diff(eye.coil_sync{coilIdx}')');
end

for coilIdx=1:length(params.headChannel)
    head.coil_sync{coilIdx}=coilData.sig_syncR{params.headChannel(coilIdx)}; 
    head.coil_1k{coilIdx}=coilData.sig_1kR{params.headChannel(coilIdx)}; 
end
disp('Done');

%% process timing 
data2plot{1}=helmet.pos-mean(helmet.pos,2);  data2plot{2}=helmet.q; data2plot{3}=eye.coil_sync{1};
taggingPlot(tagData.t_sync,data2plot, {'helmet position', 'helmet rotation', 'eye coil'}, tagData);

disp('Entering time process');
timings = timeProcess(tagData,params,eye);

%% process rigid objects
disp('Entering object process');
objectProcess

%% process head and eye related parameters 
disp('Entering head eye process');
headEyeProcess

%% eye coil calibration
ninePtGrid_eyeCalib

tableGrid_eyeCalib
