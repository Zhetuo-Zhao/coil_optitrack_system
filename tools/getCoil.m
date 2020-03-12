function coilOpti=getCoil(timeLine,posV,qV,coilIdx, R, VIEW,outputFolder)
% R is room2opti

    %alpha=43.073; theta=45.826; %blue coil
%     alpha=41.2; theta=44.5; % helmet coil
%     alpha=45; theta=45;
% alpha=43.8; theta=44.3; %thin coil
    %alpha=43.86; theta=44.19; %eye coil
    alpha=42.5; theta=43; % Bin coil
    coil2object=[ cosd(theta) * [cosd(alpha), sind(alpha)], sind(theta) ];%[0.5 0.5 sqrt(2)/2];
    
    addpath('../dataLoader/') ;

    coilOpti.qV=qV;
    q=quaternion(qV);
    nc=R\q.RotateVector(R*coil2object'); coilOpti.nc=nc;
  
    coilOpti.frameM{1}=R\q.RotateVector(R*[1 0 0]'); 
    coilOpti.frameM{2}=R\q.RotateVector(R*[0 1 0]'); 
    coilOpti.frameM{3}=R\q.RotateVector(R*[0 0 1]'); 
    
    if VIEW
        figure; plot(timeLine,coilOpti.nc');
        title('recovered coil reading from optitrack data');
        xlabel('time (s)'); ylabel('cos to each plane');
        legend('x (12k)','y (16k)','z (20k)')
        
        fileName=sprintf('coil%d_cos',coilIdx);
        saveas(gcf,[outputFolder fileName '.png'])
        saveas(gcf,[outputFolder fileName],'epsc')
    end
    
    
    % caculate coil position
    coilOpti.pos=R\posV+R\q.RotateVector(0.065*R*[0 0 1]');
    pivotPos=R\posV;
    if VIEW
        figure; 
        for i=1:3
            subplot(3,1,i);  hold on; 
            plot(pivotPos(i,:))
            plot(coilOpti.pos(i,:))
            xlabel('time (s)');
        end
        fileName=sprintf('coilpos%d',coilIdx);
        saveas(gcf,[outputFolder fileName '.png'])
        saveas(gcf,[outputFolder fileName],'epsc')
    end
end