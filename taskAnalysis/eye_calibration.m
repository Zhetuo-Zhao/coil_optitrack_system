% fit a 3x3 matrix that transfers eye coil readings to line of sight.
% This 3x3 matrix is the product of field parameters and offset from eye coil to eye ball 

function fieldCalib=eye_calibration(NptsCell,VIEW, outputFolder,fileName)
    %% fit field at the eye position
    training_V=[]; training_nc=[];
    for ptIdx=length(NptsCell.num):-1:1
        traning_idx=randsample(NptsCell.num(ptIdx),round(mean(NptsCell.num)),true);

        training_V=[training_V NptsCell.eyeCoil{ptIdx}(:,traning_idx)];
        training_nc=[training_nc NptsCell.trueVector{ptIdx}(:,traning_idx)];

    end


    for Bidx=1:3
        fun=@(nf)norm(nf*training_nc-training_V(Bidx,:));

        for i=20:-1:1
    %         [nfV(i,:), resNorm(i)]=lsqnonlin(fun,rand(1,3),2*[-1 -1 -1],2*[1 1 1]);
            [nfV(i,:), costV(i)] = fmincon(fun,rand(1,3),[],[],[],[],[-2,-2,-2],[2,2,2],[],optimoptions('fmincon','Display','off'));
        end
        [~,minIdx]=min(costV);
        Bn{Bidx}=nfV(minIdx,:);
    end

    eyePosV=[];
    for ptIdx=1:length(NptsCell.num)
        eyePosV=[eyePosV mean(NptsCell.eyePos{ptIdx},2)];
    end
    eyePos=mean(eyePosV,2);
    fieldCalib.x=eyePos(1);
    fieldCalib.y=eyePos(2);
    fieldCalib.z=eyePos(3);
    for Bidx=1:3
        fieldCalib.B{Bidx}=norm(Bn{Bidx});
        fieldCalib.nf{Bidx}=Bn{Bidx}'/norm(Bn{Bidx});
        fieldCalib.M=[Bn{1}; Bn{2}; Bn{3}];
    end
    
    %% show and test fitting result
    if VIEW
        figure; hold on;
        color3=get(gca,'colororder');
        tmp=[Bn{1}; Bn{2}; Bn{3}]\training_V;
        for i=1:3
            plot(tmp(i,:),'color',color3(i,:));
            plot(training_nc(i,:),'color',color3(i,:),'lineStyle','--','lineWidth',2);
        end
        saveFigure([fileName '_trainingResult_1D'],outputFolder)
        
        
        figure;
        subplot(2,1,1); plot(training_V');
        subplot(2,1,2); plot(training_nc');
        saveFigure([fileName '_trainingData_1D'],outputFolder)
        
        figure; hold on;
        eyePos=mean(NptsCell.eyePos{1},2);
        for ptIdx=length(NptsCell.nPts):-1:1
            coilVec=mean(NptsCell.eyeCoil{ptIdx},2);        coilVecM(:,ptIdx)=coilVec;
            eyeVec=[Bn{1}; Bn{2}; Bn{3}]\coilVec;           eyeVecM(:,ptIdx)=eyeVec;
            gazeVec=mean(NptsCell.trueVector{ptIdx},2);     gazeVecM(:,ptIdx)=gazeVec;
            quiver3(eyePos(1),eyePos(2),eyePos(3),coilVec(1),coilVec(2),coilVec(3),'b');
            quiver3(eyePos(1),eyePos(2),eyePos(3),eyeVec(1),eyeVec(2),eyeVec(3),'g');
            quiver3(eyePos(1),eyePos(2),eyePos(3),gazeVec(1),gazeVec(2),gazeVec(3),'r');
            nPtsPos(:,ptIdx)=mean(NptsCell.nPts{ptIdx},2);
        end
        view(3); grid on;
        scatter3(nPtsPos(1,:),nPtsPos(2,:),nPtsPos(3,:));
        saveFigure([fileName '_trainingData_3D'],outputFolder)
        
        figure; hold on;
        colors=get(gca,'colororder');
        
        tmp=vec2ang(training_V); scatter(tmp(1,:),tmp(2,:),'MarkerEdgeColor',colors(3,:));
%         tmp=vec2ang(-[F3{1}'; F3{2}'; F3{3}']\training_V); scatter(tmp(1,:),tmp(2,:));
        tmp=vec2ang([Bn{1}; Bn{2}; Bn{3}]\training_V); scatter(tmp(1,:),tmp(2,:),'MarkerEdgeColor',colors(2,:));
        tmp=vec2ang(training_nc); scatter(tmp(1,:),tmp(2,:),'MarkerEdgeColor',colors(1,:),'lineWidth',1.5);
        grid on; 
        legend({'raw coil vector','after field and offset calibration','eye orientation'});    
        xlabel('azimuth (degree)'); ylabel('altitude (degree)');
        saveFigure([fileName '_training_ang2D'],outputFolder)
    
        figure;
        for ptIdx=length(NptsCell.num):-1:1
            eyeVec=[Bn{1}; Bn{2}; Bn{3}]\NptsCell.eyeCoil{ptIdx};

            subplot(3,3,ptIdx); hold on;
            plot(eyeVec')
            plot(NptsCell.trueVector{ptIdx}')
        end
        saveFigure([fileName 'Vec'],outputFolder);
        
        figure;
        for ptIdx=length(NptsCell.num):-1:1
            eyeVec=[Bn{1}; Bn{2}; Bn{3}]\NptsCell.eyeCoil{ptIdx};
            trueVec=NptsCell.trueVector{ptIdx};
            subplot(3,3,ptIdx); hold on;
            plot(atand(eyeVec(2,:)./eyeVec(1,:))*60)
            plot(atand(trueVec(2,:)./trueVec(1,:))*60)
        end
        saveFigure([fileName 'X'],outputFolder);
  
        
        figure;
        for ptIdx=length(NptsCell.num):-1:1
            eyeVec=[Bn{1}; Bn{2}; Bn{3}]\NptsCell.eyeCoil{ptIdx};
            trueVec=NptsCell.trueVector{ptIdx};
            subplot(3,3,ptIdx); hold on;
            plot(atand(eyeVec(3,:)./sqrt(eyeVec(1,:).^2+eyeVec(2,:).^2))*60)
            plot(atand(trueVec(3,:)./sqrt(trueVec(1,:).^2+trueVec(2,:).^2))*60)
        end
        saveFigure([fileName 'Y'],outputFolder);
        
        
    end

    
    

end