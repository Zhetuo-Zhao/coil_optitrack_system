% Apply 
% just fit the rotation matrix

function fieldCalib=eye_calibration2(NptsCell,estField, VIEW, outputFolder)
    %% fit field at the eye position
    training_V=[]; training_nc=[];
    for ptIdx=length(NptsCell.num):-1:1
        traning_idx=randsample(NptsCell.num(ptIdx),round(mean(NptsCell.num)),true);

        training_V=[training_V NptsCell.eyeCoil{ptIdx}(:,traning_idx)];
        training_nc=[training_nc NptsCell.trueVector{ptIdx}(:,traning_idx)];
    end
    
    
    eyePosV=[];
    for ptIdx=1:length(NptsCell.num)
        eyePosV=[eyePosV mean(NptsCell.eyePos{ptIdx},2)];
    end
    eyePos=mean(eyePosV,2); 
    
    F3=getField(estField,eyePos(1:2));

    
    fun=@(param)norm(param(4)*F3{1}'*Eang2rtM(param(1),param(2),param(3))*training_nc-training_V(1,:))...
              +norm(param(4)*F3{2}'*Eang2rtM(param(1),param(2),param(3))*training_nc-training_V(2,:))...
              +norm(param(4)*F3{3}'*Eang2rtM(param(1),param(2),param(3))*training_nc-training_V(3,:));

    for i=20:-1:1
        [paramV(i,:), costV(i)] = fmincon(fun,rand(1,4),[],[],[],[],[-pi,-pi,-pi,-5],[pi,pi,pi,5],[],optimoptions('fmincon','Display','off'));
    end
    [~,minIdx]=min(costV);
    param=paramV(minIdx,:);
    
   
    fieldCalib.x=eyePos(1); 
    fieldCalib.y=eyePos(2);
    fieldCalib.z=eyePos(3);
    for Bidx=1:3
        Bn{Bidx}=param(4)*F3{Bidx}'*Eang2rtM(param(1),param(2),param(3));
        fieldCalib.B{Bidx}=norm(Bn{Bidx});
        fieldCalib.nf{Bidx}=Bn{Bidx}'/norm(Bn{Bidx});   
    end
    fieldCalib.param=param;      
    fieldCalib.M=[Bn{1}; Bn{2}; Bn{3}];

    figure; hold on;
    colors=get(gca,'colororder');
    tmp=vec2ang(training_V); scatter(tmp(1,:),tmp(2,:),'MarkerEdgeColor',colors(2,:));
    tmp=vec2ang([F3{1}'; F3{2}'; F3{3}']\training_V); scatter(tmp(1,:),tmp(2,:),'MarkerEdgeColor',colors(3,:));
    tmp=vec2ang([Bn{1}; Bn{2}; Bn{3}]\training_V); scatter(tmp(1,:),tmp(2,:),'MarkerEdgeColor',colors(4,:));
    tmp=vec2ang(training_nc); scatter(tmp(1,:),tmp(2,:),'MarkerEdgeColor',colors(1,:),'lineWidth',1.5);
    grid on; 
    legend({'raw coil vector','after field calibration','consider coil offset','eye orientation'});    
    xlabel('azimuth (degree)'); ylabel('altitude (degree)');
    saveFigure('ang2D_calib2', outputFolder)


color3=get(gca,'colororder');
figure; hold on;
for i=1:3
    tmp=[Bn{1}; Bn{2}; Bn{3}]*training_nc;
    plot(tmp(i,:),'color',color3(i,:),'lineWidth',1.5)
    plot(training_V(i,:),'color',color3(i,:),'lineWidth',1.5,'lineStyle','--')
end


    figure;
    subplot(2,1,1); plot(training_V');
    subplot(2,1,2); plot(training_nc');
    saveFigure('headFix_trainingData2_1D',outputFolder)
    %% show and test fitting result
    color3=get(gca,'colororder');
    if VIEW
        figure;
        for ptIdx=length(NptsCell.num):-1:1
%             eyeVec=[Bn{1}; Bn{2}; Bn{3}]\NptsCell.eyeCoil{ptIdx};
            eyeVec=-[F3{1}'; F3{2}'; F3{3}']\NptsCell.eyeCoil{ptIdx};
            subplot(3,3,ptIdx); hold on;
            for i=1:3
                plot(eyeVec(i,:),'color',color3(i,:),'lineWidth',1.5)
                plot(NptsCell.trueVector{ptIdx}(i,:),'color',color3(i,:),'lineWidth',1.5,'lineStyle','--')
            end
        end
        fileName='calib9PtsVec';
        saveas(gcf,[outputFolder fileName '.png'])
        saveas(gcf,[outputFolder fileName], 'epsc')
        saveas(gcf,[outputFolder fileName '.fig'])
        
        figure;
        for ptIdx=length(NptsCell.num):-1:1
            eyeVec=[Bn{1}; Bn{2}; Bn{3}]\NptsCell.eyeCoil{ptIdx};
            trueVec=NptsCell.trueVector{ptIdx};
            subplot(3,3,ptIdx); hold on;
            plot(atand(eyeVec(2,:)./eyeVec(1,:))*60)
            plot(atand(trueVec(2,:)./trueVec(1,:))*60)
        end
        fileName='calib9PtsX';
        saveas(gcf,[outputFolder fileName '.png'])
        saveas(gcf,[outputFolder fileName], 'epsc')
        saveas(gcf,[outputFolder fileName '.fig'])
        
        
        figure;
        for ptIdx=length(NptsCell.num):-1:1
            eyeVec=[Bn{1}; Bn{2}; Bn{3}]\NptsCell.eyeCoil{ptIdx};
            trueVec=NptsCell.trueVector{ptIdx};
            subplot(3,3,ptIdx); hold on;
            plot(atand(eyeVec(3,:)./sqrt(eyeVec(1,:).^2+eyeVec(2,:).^2))*60)
            plot(atand(trueVec(3,:)./sqrt(trueVec(1,:).^2+trueVec(2,:).^2))*60)
        end
        fileName='calib9PtsY';
        saveas(gcf,[outputFolder fileName '.png'])
        saveas(gcf,[outputFolder fileName], 'epsc')
        saveas(gcf,[outputFolder fileName '.fig'])
        
        
    end

    
    

end