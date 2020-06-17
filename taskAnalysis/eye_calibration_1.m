%try to add three offsets, free parameters in the fitting.

function fieldCalib=eye_calibration_1(NptsCell,VIEW, outputFolder)
    %% fit field at the eye position
    training_V=[]; training_nc=[];
    for ptIdx=length(NptsCell.num):-1:1
        traning_idx=randsample(NptsCell.num(ptIdx),round(mean(NptsCell.num)),true);

        training_V=[training_V NptsCell.eyeCoil{ptIdx}(:,traning_idx)];
        training_nc=[training_nc NptsCell.trueVector{ptIdx}(:,traning_idx)];

    end


    for Bidx=1:3
        fun=@(nf)norm(nf(1:3)*training_nc-training_V(Bidx,:)-nf(4));

        for i=20:-1:1
    %         [nfV(i,:), resNorm(i)]=lsqnonlin(fun,rand(1,3),2*[-1 -1 -1],2*[1 1 1]);
            [nfV(i,:), costV(i)] = fmincon(fun,rand(1,4),[],[],[],[],[-2,-2,-2,-2],[2,2,2,2],[],optimoptions('fmincon','Display','off'));
        end
        [~,minIdx]=min(costV);
        Bn{Bidx}=nfV(minIdx,1:3);
        offset(Bidx,1)=nfV(minIdx,4);
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
    end
    fieldCalib.offset=offset;
    
    %% show and test fitting result
    if VIEW
        figure; hold on;
        color3=get(gca,'colororder');
        tmp=[Bn{1}; Bn{2}; Bn{3}]\(training_V+offset);
        for i=1:3
            plot(tmp(i,:),'color',color3(i,:));
            plot(training_nc(i,:),'color',color3(i,:),'lineStyle','--','lineWidth',2);
        end
        saveFigure('headFix_trainingResult_1D',outputFolder)
        
        
        figure;
        subplot(2,1,1); plot(training_V');
        subplot(2,1,2); plot(training_nc');
        saveFigure('headFix_trainingData_1D',outputFolder)
        
        figure; hold on;
        eyePos=mean(NptsCell.eyePos{1},2);
        for ptIdx=length(NptsCell.nPts):-1:1
            coilVec=mean(NptsCell.eyeCoil{ptIdx},2);
            gazeVec=mean(NptsCell.trueVector{ptIdx},2);
            quiver3(eyePos(1),eyePos(2),eyePos(3),coilVec(1),coilVec(2),coilVec(3),'b');
            quiver3(eyePos(1),eyePos(2),eyePos(3),gazeVec(1),gazeVec(2),gazeVec(3),'r');
            nPtsPos(:,ptIdx)=mean(NptsCell.nPts{ptIdx},2);
        end
        view(3); grid on;
        scatter3(nPtsPos(1,:),nPtsPos(2,:),nPtsPos(3,:));
        saveFigure('headFix_trainingData_3D',outputFolder)
        
        figure; hold on;
        tmp=vec2ang(training_nc); scatter(tmp(1,:),tmp(2,:));
        tmp=vec2ang(training_V); scatter(tmp(1,:),tmp(2,:));
%         tmp=vec2ang(-[F3{1}'; F3{2}'; F3{3}']\training_V); scatter(tmp(1,:),tmp(2,:));
        tmp=vec2ang([Bn{1}; Bn{2}; Bn{3}]\(training_V+offset)); scatter(tmp(1,:),tmp(2,:));
        grid on; 
        legend({'eye orientation','raw coil vector','after field and offset calibration'});    
        xlabel('azimuth (degree)'); ylabel('altitude (degree)');
        saveFigure('headFix_training_ang2D',outputFolder)
    
        
        
        figure;
        for ptIdx=length(NptsCell.num):-1:1
            subplot(3,3,ptIdx); hold on;
            eyeVec=[Bn{1}; Bn{2}; Bn{3}]\(NptsCell.eyeCoil{ptIdx}+offset);
            eyeVec2=vec2ang(eyeVec);
            plot(eyeVec')
            plot(NptsCell.trueVector{ptIdx}')
        end
        saveFigure('calib9PtsVec',outputFolder);
        
        figure;
        for ptIdx=length(NptsCell.num):-1:1
            eyeVec=[Bn{1}; Bn{2}; Bn{3}]\(NptsCell.eyeCoil{ptIdx}+offset);
            eyeVec2=vec2ang(eyeVec);
            trueVec2=vec2ang(NptsCell.trueVector{ptIdx});
            subplot(3,3,ptIdx); hold on;
            plot(eyeVec2(1,:)*60)
            plot(trueVec2(1,:)*60)
        end
        saveFigure('calib9PtsX',outputFolder);
  
        
        figure;
        for ptIdx=length(NptsCell.num):-1:1
            eyeVec=[Bn{1}; Bn{2}; Bn{3}]\(NptsCell.eyeCoil{ptIdx}+offset);
            eyeVec2=vec2ang(eyeVec);
            trueVec2=vec2ang(NptsCell.trueVector{ptIdx});
            subplot(3,3,ptIdx); hold on;
            plot(eyeVec2(2,:)*60)
            plot(trueVec2(2,:)*60)
        end
        saveFigure('calib9PtsY',outputFolder);
        
        
    end

    
    

end