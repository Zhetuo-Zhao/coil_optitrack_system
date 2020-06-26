    
function [objects,optiData,tagData,coilData,optSyncIdx] = loadData(params)
   
%     inputPath = [params.inputPath params.date '/'];
%     optitrackFilename = [params.session '.csv'];
%     outputPath = [inputPath params.session '/Figures/'];
%     optitrackFilepath = [inputPath params.session '/' optitrackFilename];

%     
%     if ~exist(outputPath)
%        mkdir(outputPath); 
%     end

 

    disp('loading coil data (may take a long period of time)');
    [coilData,tagData] = processCoilData(params); 
    disp('Done!');

    inputPath = [params.inputPath params.date '/'];
    optitrackFilename = [params.session '.csv'];
    outputPath = [inputPath params.session '/Figures/'];
    optitrackFilepath = [inputPath params.session '/' optitrackFilename];

    % outputFolder=[direct folder '/Figures/'];
    if ~exist(outputPath)
       mkdir(outputPath); 
    end
    
    disp('loading optitrack data');
    optiData = loadOptiTrack(optitrackFilepath,20);
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
    save([inputPath params.session '\rawData_coil.mat'],'coilData');
    save([inputPath params.session '\rawData_tag.mat'],'tagData');
    save([inputPath params.session '\rawData_opti.mat'],'objects');
    disp('Done!')
end