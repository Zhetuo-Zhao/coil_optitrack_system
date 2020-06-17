addpath('..\tools\')

direct='C:/Users/sanjana/OneDrive - University of Rochester/Documents/Sanjana/Projects/coil/fieldCalibrate/data/';
date='06-Mar-2020';
session='run3';

inputPath= [direct date '/' session '/'];
outputPath= [inputPath '/Figures/']; 
if ~exist(outputPath)
    mkdir(outputPath); 
end

VIEW =1;
SAVE_Fig =1;
params = struct('opti2roomTransMatrix',[0 0 -1;-1 0 0 ; 0 1 0],...
    'activeChannels',[2,3,4],...
    'headChannel',[3 4],...
    'eyeChannel',[2],...
    'headCoilL',5,'headCoilR',1,...
    'headRestMarkers',[1 2 3 4 5],...
    'eyeProbeMarkers',[5 4 2 6],...
    'ninePtsMarkers',[9 6 4 8 1 3 7 2 5],...
    'tableGridMarkers',[7 3 4 5 6 2 1 8],...
    'tableMarkers',[5 1 2 3 4]);



%% loading data
loadParams.VIEW=VIEW; loadParams.SAVE=SAVE_Fig; 
loadParams.inputPath=inputPath; loadParams.outputPath=outputPath;
loadParams.session=session; loadParams.activeChannels=params.activeChannels;

[objects,optiData,tagData,coilData,optSyncIdx] = loadData(loadParams);


%% print out and define the names of all objects
for i=1:length(objects)
   {i, objects{i}.name};
   
   if strcmp(objects{i}.name, 'ninePts')
       ninePoints = objects{i};
   elseif strcmp(objects{i}.name, 'table')
       table = objects{i};
   elseif strcmp(objects{i}.name,'tableGrid')
       tableGrid = objects{i};
   elseif strcmp(objects{i}.name,'helmet')
       helmet = objects{i};
   elseif strcmp(objects{i}.name, 'eyeProbe')
       eyeProbe = objects{i};
   elseif strcmp(objects{i}.name, 'iceTray')
       iceTray = objects{i};
   elseif strcmp(objects{i}.name, 'headRest')
       headRest = objects{i};
   elseif strcmp(objects{i}.name, 'head_eye')
       head_eye = objects{i};
   end
end

%% head and eye coil 
for coilIdx=params.eyeChannel
    if ~isempty(coilData.sig_syncR{coilIdx})... 
    && sum(coilData.sig_syncR{coilIdx}(1,:)<0)/length(coilData.sig_syncR{coilIdx}(1,:))<0.4 ...
    && sum(coilData.sig_syncR{coilIdx}(2,:)<0)/length(coilData.sig_syncR{coilIdx}(2,:))<0.4
        eye.coil_sync{coilIdx}=-coilData.sig_syncR{coilIdx};
        eye.coil_1k{coilIdx}=-coilData.sig_1kR{coilIdx}; 
    else
        eye.coil_sync{coilIdx}=coilData.sig_syncR{coilIdx};
        eye.coil_1k{coilIdx}=coilData.sig_1kR{coilIdx}; 
    end
end

for coilIdx=params.headChannel
    head.coil_sync{coilIdx}=coilData.sig_syncR{coilIdx}; 
    head.coil_1k{coilIdx}=coilData.sig_1kR{coilIdx}; 
end


%% timing 
data2plot{1}=helmet.pos-mean(helmet.pos,2);  data2plot{2}=helmet.q; data2plot{3}=eye.coil_sync{1};
taggingPlot(tagData.t_sync,data2plot, {'helmet position', 'helmet rotation', 'eye coil'}, tagData);

timings=timeProcess(tagData);


%% objects
objectProcess

%% head eye process
headEyeProcess


%% eye coil calibration
ninePtGrid_eyeCalib

tableGrid_eyeCalib