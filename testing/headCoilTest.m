clear; %close all;
addpath('..\tools\')
direct='Z:\fieldCalibrate\data\20-Dec-2019\run1\';
outputFolder=[direct 'test\'];
if ~exist(outputFolder)
   mkdir(outputFolder); 
end

R_opti2room=[0 0 -1; -1 0 0; 0 1 0]; % transform from optitrack to room

load([direct 'helmetData.mat'])
backCoil=headCoil_sync{1}; 
sideCoil=headCoil_sync{2}; 
backPos=R_opti2room*helmet.marker{7}.pos;
sidePos=R_opti2room*helmet.marker{8}.pos;

% tt=[95202:100422];
% backCoil=backCoil(:,tt);
% sideCoil=sideCoil(:,tt);
% backPos=backPos(:,tt);
% sidePos=sidePos(:,tt);


load('Z:\fieldCalibrate\calibration\field\BinCoil\191220\estFieldR13_syncDebug.mat');
[backCoil_estField, backCoil_idealField, ~,debug.x, debug.y]=field_compensate(estField, backCoil, backPos);
load('Z:\fieldCalibrate\calibration\field\BinCoil\191220\estFieldR13_syncDebug.mat');
[sideCoil_estField, sideCoil_idealField]=field_compensate(estField, sideCoil, sidePos);


ang0 = acos(sum(backCoil_idealField.*sideCoil_idealField))/pi*180*60;
ang1 = acos(sum(backCoil_estField.*sideCoil_estField))/pi*180*60;

figure; hold on; plot(ang0); plot(ang1);
ylabel('arcmin')
legend({'without field calibration','with field calibration'});
fileName='angle between 2 coils';
saveas(gcf,[outputFolder fileName '.fig'])
saveas(gcf,[outputFolder fileName '.png'])
saveas(gcf,[outputFolder fileName],'epsc')


%%
q_opti2room=quaternion.rotationmatrix(R_opti2room);
q=quaternion(optiData.qV_sync(:,1:end-1)); q=q(tt);
q_opti=rdivide(q,q(1)*ones(1,length(q)));

q_room=times(ldivide(conj(q_opti2room)*ones(1,length(q)),q_opti),conj(q_opti2room)*ones(1,length(q)));
tmp=EulerAngles(q_room,'zyx');
tmp=reshape(tmp,[3 length(q)]);
headEuler_q=tmp/pi*180; % in degree



cXYZ1_room=vec2frame(sideCoil_estField(:,1),backCoil_estField(:,1));
    
for t=length(q):-1:1
    cXYZt_room=vec2frame(sideCoil_estField(:,t),backCoil_estField(:,t));
    q_room_coil(t)=quaternion.rotationmatrix(cXYZt_room/cXYZ1_room);
end

tmp=EulerAngles(q_room_coil,'zyx');
tmp=reshape(tmp,[3 length(q)]);
headEuler_coil=tmp/pi*180; % in degree


titles={'yaw (z)','pitch (y)','row (x)'};
figure; 
for i=1:3
    h(i)=subplot(3,1,i); hold on; 
    plot(headEuler_q(i,:)); plot(headEuler_coil(i,:))
    ylabel('degree');
    title(titles{i});
    legend({'optitrack','coil'});
end
linkaxes(h,'x')
fileName='EulerAngles';
saveas(gcf,[outputFolder fileName '.fig'])
saveas(gcf,[outputFolder fileName '.png'])
saveas(gcf,[outputFolder fileName],'epsc')

%%


    diffM=headEuler_coil-headEuler_q; 
    
    figure; hold on; 
    histogram((diffM(3,:))*60); 
    histogram((diffM(2,:))*60); 
    histogram((diffM(1,:))*60); 
    
    figure; hold on; 
    histogram((diffM(3,:)-mean(diffM(3,:)))*60); 
    histogram((diffM(2,:)-mean(diffM(2,:)))*60); 
     histogram((diffM(1,:)-mean(diffM(1,:)))*60); 
    
%     figure; hold on; 
%     histogram(diffM(1,:)*60); 
%     histogram(diffM(2,:)*60); 
%     histogram(diffM(3,:)*60)
%     
    legend({'yaw (z)','pitch (y)','roll (x)'});
    xlabel('difference between Euler angle given by optitrack and coil (arcmin)');
    fileName='angDiff';
    saveas(gcf,[outputFolder fileName '.fig'])
    saveas(gcf,[outputFolder fileName '.png'])
    saveas(gcf,[outputFolder fileName],'epsc')

    
    
    figure; 
    subplot(1,3,1); scatter(headEuler_q(3,:),diffM(1,:)); xlabel('roll (x) angle'); ylabel('yaw (z) error');
    subplot(1,3,2); scatter(headEuler_q(2,:),diffM(2,:)); xlabel('pitch (y) angle'); ylabel('pitch (y) error');
    subplot(1,3,3); scatter(headEuler_q(1,:),diffM(3,:)); xlabel('yaw (z) angle'); ylabel('roll (x) error');
    fileName='angCorrelation';
    saveas(gcf,[outputFolder fileName '.fig'])
    saveas(gcf,[outputFolder fileName '.png'])
    saveas(gcf,[outputFolder fileName],'epsc')
    
    
    titleNames={'x','y','z'};
    xNames={'yaw (z)','pitch (y)','roll (x)'};
    figure('Position', [10 10 1800 900]);
    for j=1:3
        for i=1:3
            subplot(3,3,3*(i-1)+j); hold on;
            scatter(headEuler_q(j,:),backV0(i,:)-backV0(i,1));
            scatter(headEuler_q(j,:),backV(i,:)-backV(i,1))
            legend({'without field calibration','with field calibration'});
            title(titleNames{i});
        end
        xlabel([xNames{j} ' angle (degree)'])
    end
    fileName='backCoilDebug';
    saveas(gcf,[outputFolder fileName '.fig'])
    saveas(gcf,[outputFolder fileName '.png'])
    saveas(gcf,[outputFolder fileName],'epsc')
    
    figure('Position', [10 10 1800 900]);
    for j=1:3
        for i=1:3
            subplot(3,3,3*(i-1)+j); hold on;
            scatter(headEuler_q(j,:),sideV0(i,:)-sideV0(i,1));
            scatter(headEuler_q(j,:),sideV(i,:)-sideV(i,1))
            legend({'without field calibration','with field calibration'});
            title(titleNames{i});
        end
        xlabel([xNames{j} ' angle (degree)'])
    end
    fileName='sideCoilDebug';
    saveas(gcf,[outputFolder fileName '.fig'])
    saveas(gcf,[outputFolder fileName '.png'])
    saveas(gcf,[outputFolder fileName],'epsc')
    
    
    figure('Position', [50 50 800 400]);
    for i=1:3
        subplot(1,3,i); hold on;
        scatter(headEuler_q(i,:),ang0);
        scatter(headEuler_q(i,:),ang1);
        ylabel('arcmin'); xlabel([xNames{j} ' angle (degree)']);
        title ('angle between two coils')
    end
    
    fileName='twoCoil_correlation';
    saveas(gcf,[outputFolder fileName '.fig'])
    saveas(gcf,[outputFolder fileName '.png'])
    saveas(gcf,[outputFolder fileName],'epsc')
    
    
    
    
    titleNames={'x','y','z'};
    xNames={'yaw (z)','pitch (y)','roll (x)'};
    figure('Position', [10 10 1800 900]);
    for j=1:3
        for i=1:3
            subplot(3,3,3*(i-1)+j); hold on;
            scatter(backPos(2,:),backV0(i,:)-backV0(i,1));
            scatter(backPos(2,:),backV(i,:)-backV(i,1))
            legend({'without field calibration','with field calibration'});
            title(titleNames{i});
        end
        xlabel([xNames{j} ' angle (degree)'])
    end
    
    
    
    