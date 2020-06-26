function [gazePosOnPlane,gaze2D]=plotEyeTraceOnPlane(eyePos,tim,lineSight,planeCell,outputFolder, fileName)


gazePosOnPlane=linePlaneInter(eyePos(:,tim), lineSight, planeCell.plane.param);
gaze2D=pts3to2(gazePosOnPlane, planeCell.plane.xAxis, planeCell.plane.yAxis, planeCell.plane.origin);
figure; hold on;
plot(100*gaze2D(1,:), 100*gaze2D(2,:),'Marker','+','color','r')
scatter(100*planeCell.pts2D{1}(1,:),100*planeCell.pts2D{1}(2,:),'lineWidth',3,'MarkerEdgeColor','k');
xlabel('cm'); ylabel('cm');
if exist('outputFolder','var') && exist('fileName','var')
    saveFigure([fileName '_trace2D_cm'], outputFolder)
end

eye2NinePtsDis=pt2planeDis(mean(eyePos(:,tim),2),planeCell.plane.param);
figure; hold on;
eyeAngle2D=atand(gaze2D/eye2NinePtsDis)*60;
plot(eyeAngle2D(1,:), eyeAngle2D(2,:),'Marker','+','color','r');
scatter(atand(planeCell.pts2D{1}(1,:)/eye2NinePtsDis)*60,atand(planeCell.pts2D{1}(2,:)/eye2NinePtsDis)*60,'lineWidth',3,'MarkerEdgeColor','k');
xlabel('arcmin'); ylabel('arcmin');
if exist('outputFolder','var') && exist('fileName','var')
    saveFigure([fileName '_trace2D_arcmin'], outputFolder)
end
end
