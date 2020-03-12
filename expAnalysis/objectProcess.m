LOADDATA=1;

if LOADDATA
    session='05-Feb-2020';
    direct=['Z:/fieldCalibrate/data/' session '/'];
    folder='session2';
    R_opti2room=[0 0 -1;-1 0 0 ; 0 1 0];
    load([direct folder '\rawData_opti.mat'])
end
%% print out the names of all objects
for i=1:length(objects)
   {i, objects{i}.name}
end

%% assign object index    %improvement needed
helmet=objects{4}; headRest=objects{7}; eyeProbe=objects{5}; ninePoints=objects{1}; tableGrid = objects{3}; table=objects{2};
iceTray=objects{6}; head_eye=objects{8};
%% helmet
plot_each_frame(helmet,1E4, R_opti2room);
helmet.coilMarkerL=5;
helmet.coilMarkerR=1;
data2plot{1}=helmet.pos; data2plot{2}=helmet.q;
tagging_plot(coilData.t_sync,data2plot, {'helmet position (m)', 'helmet quanternion'}, tagData);


%% headRest
headRestFrame=[211293:219338];  % the time samples in which the headrest is mounted on the table
plot_each_frame(headRest,10000, R_opti2room)
data2plot{1}=helmet.pos; data2plot{2}=headRest.pos;
tagging_plot(tagData.t_sync,data2plot, {'helmet position (m)', 'headRest position (m)'}, tagData);
% this function gives the norm vector orthogonal to the head rest plane (facing forward)
headRest=optitrack_headRest(headRest,headRestFrame,[1 2 3 4 5]); %first 3 marker are in the same vertical plane
headRest.Frames=headRestFrame;

%% eyeProbe
plot_each_frame(eyeProbe,1E4, R_opti2room)
data2plot{1}=eyeProbe.pos; data2plot{2}=eyeProbe.q;
tagging_plot(tagData.t_sync,data2plot, {'eyeProbe position (m)', 'eyeProbe quanternion'}, tagData);

eyeProbeFrames{1}=[228001:228241];
eyeProbe=optitrack_eyeProbe(eyeProbe,eyeProbeFrames,0.012,[5 4 2 6]); % the last index is the end of the probe
eyeProbe.Frames=eyeProbeFrames;

%% 9-point grid
plot_each_frame(ninePoints,1E4, R_opti2room)
ninePoints.markerIdx=[9 6 4 8 1 3 7 2 5];   % order of left to right, top to bottom
for ptIdx=1:length(ninePoints.markerIdx)
    ninePoints.markerPos_room{ptIdx}=R_opti2room*ninePoints.marker{ninePoints.markerIdx(ptIdx)}.pos;
end

%% table
plot_each_frame( table, 1E4, R_opti2room );
table.markerIdx = [5 1 2 3 4]; % clockwise starting from top left
for ptIdx=1:length(table.markerIdx)
    table.markerPos_room{ptIdx}=R_opti2room*table.marker{table.markerIdx(ptIdx)}.pos;
end

%% table grid
plot_each_frame( tableGrid, 1E4, R_opti2room );
tableGrid.markerIdx = [7 3 4 5 6 2 1 8]; % clockwise starting from top left
for ptIdx=1:length(tableGrid.markerIdx)
    tableGrid.markerPos_room{ptIdx}=R_opti2room*tableGrid.marker{tableGrid.markerIdx(ptIdx)}.pos;
end

save([direct folder '\processed_objects.mat'],'helmet','headRest','eyeProbe','ninePoints','tableGrid','table','iceTray','head_eye');

