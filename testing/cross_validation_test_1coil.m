clear; close all;

addpath('../tools/') ;


direct=['\\opus.cvs.rochester.edu\aplab\fieldCalibrate\data\05-Feb-2020\']; testFolder='fieldCalibration_high';
load([direct testFolder '\syncData_lite.mat'])
load([direct testFolder '\syncData.mat'])
%%
idx=1;%1:4;
for jjj=idx
    coil1=-coil{jjj}(:,2:end);
    coil1(1,:)=-coil1(1,:);
    nc1=nc{jjj}(:,1:end-1);
    pos1=pos{jjj}(:,1:end-1);


% direct='\\opus.cvs.rochester.edu\aplab\fieldCalibrate\calibration\field\BinCoil\191218\';
% direct='\\opus.cvs.rochester.edu\aplab\fieldCalibrate\data\05-Feb-2020\results\';
load([direct testFolder '\results\' 'estFieldR13_syncDebug.mat'])


coilV=coil1;
posV=pos1;
ncV=nc1;
frameM=coilOpti{jjj}.frameM;

[ncV_estField, ncV_idealField,heightV]=field_compensate(estField, coilV, posV);

ang1=zeros(1,size(coilV,2)); vqec1=zeros(3,size(coilV,2)); vec0=zeros(3,size(coilV,2));
ang0=zeros(1,size(coilV,2)); vecDiff=zeros(3,size(coilV,2));
for t=1:size(coilV,2)
    nc0=ncV_idealField(:,t);
    nc1=ncV_estField(:,t);

    ang0(t)=acos(sum(nc0.*ncV(:,t))/(norm(nc0)*norm(ncV(:,t))))/pi*180*60;
    ang1(t)=acos(sum(nc1.*ncV(:,t))/(norm(nc1)*norm(ncV(:,t))))/pi*180*60;

    nc33=-[frameM{1}(:,t) frameM{2}(:,t) frameM{3}(:,t)];
    
    vec0(:,t)=nc33'*ncV(:,t);
    vec1(:,t)=nc33'*nc1;
    vecDiff(:,t)=nc33'*(nc1-ncV(:,t));

end

yaw=atan(vecDiff(2,:)./vecDiff(1,:))/pi*180*60;
pitch=atan(vecDiff(3,:)./sqrt(vecDiff(1,:).^2+vecDiff(2,:).^2))/pi*180*60;

%     figure; num=2;     
%     h1=subplot(num,1,1); 
%     plot(vecDiff'); 
% 
%     h2=subplot(num,1,2); hold on;
%     plot(yaw); plot(pitch);
%     
%     linkaxes([h1 h2],'x')

figure; num=2;     
h1=subplot(num,1,1); hold on;
plot(ang0);  plot(ang1);
legend({'assume ideal field','estimated field','after calibration'});
xlabel('sample'); ylabel('arcmin');

h2=subplot(num,1,2); hold on;
plot(posV'); plot(heightV);
legend({'x','y','z','estimated field height'});
xlabel('sample'); ylabel('m');


%     h3=subplot(num,1,3);
%     yyaxis left;  plot(ncV_estField(1,:)-ncV(1,:)); ylim([-0.01 0.01]);
%     yyaxis right; hold on; plot(ncV_estField(1,:),'r'); plot(ncV(1,:),'g')
%     
%     h4=subplot(num,1,4);
%     yyaxis left;  plot(ncV_estField(2,:)-ncV(2,:)); ylim([-0.01 0.01]);
%     yyaxis right; hold on; plot(ncV_estField(2,:),'r'); plot(ncV(2,:),'g')
%     
%     h5=subplot(num,1,5);
%     yyaxis left;  plot(ncV_estField(3,:)-ncV(3,:)); ylim([-0.01 0.01]);
%     yyaxis right; hold on; plot(ncV_estField(3,:),'r'); plot(ncV(3,:),'g')
%     
%     linkaxes([h1 h2 h3 h4 h5],'x')


outputFolder=[direct 'crossValidate\'];
if ~exist(outputFolder)
 mkdir(outputFolder); 
end

fileName=['coil_angle_' testFolder '_' num2str(jjj)];
save([outputFolder fileName '.mat'],'ang1','ang0','vec1','vecDiff','ncV_idealField','ncV_estField','estField', 'coilV', 'posV','ncV');
saveas(gcf,[outputFolder fileName '.fig'])
saveas(gcf,[outputFolder fileName '.png'])
saveas(gcf,[outputFolder fileName],'epsc')

end
