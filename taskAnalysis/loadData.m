    
function [objects,optiData,tagData,coilData,optSyncIdx] = loadData(params)
   
% load coil data
disp('loading coil data');
[coilData,tagData] = processCoilData(params); 
disp('Done!');

% load optitrack data
disp('loading optitrack data');
optiData = loadOptiTrack([params.inputPath params.session '.csv'],20);
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
save([params.inputPath 'rawData_coil.mat'],'coilData');
save([params.inputPath 'rawData_tag.mat'],'tagData');
save([params.inputPath 'rawData_opti.mat'],'objects');
disp('Done!')



end