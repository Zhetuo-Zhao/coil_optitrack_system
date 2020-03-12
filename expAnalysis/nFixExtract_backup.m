function NptsOut=nFixExtract_backup(eye,nTim,nPts,thre,eyeIdx,VIEW)

% nTime: 1xN
% nPts: {N}(3xN)

    
    NptsOut.nPts=nPts;
    NptsOut.nTim=nTim;

    if VIEW
        figure;
    end
    for ptIdx=length(nTim):-1:2
        
        startTim=find(eye.coil_vel{eyeIdx}(1:nTim(ptIdx))>thre,1,'last')+30;
        NptsOut.eyeCoil{ptIdx}=eye.coil_sync{eyeIdx}(:,startTim:nTim(ptIdx)); %eyeCoil9pts{ptIdx}=normc(eyeCoil9pts{ptIdx});  
        NptsOut.eyePos{ptIdx}=eye.pos{eyeIdx}(:,startTim:nTim(ptIdx));
        trueVector{ptIdx}=nPts{ptIdx}(:,startTim:nTim(ptIdx))-NptsOut.eyePos{ptIdx};
        NptsOut.trueVector{ptIdx}=normc(trueVector{ptIdx}); 
        NptsOut.num(ptIdx)=length(NptsOut.eyePos{ptIdx});

        if VIEW
            subplot(3,3,ptIdx); hold on;
            plot(NptsOut.eyeCoil{ptIdx}')
            plot(NptsOut.trueVector{ptIdx}')
        end
    end


    if VIEW
        figure; hold on;

        eyePos=mean(eye.pos{eyeIdx}(:,nTim(1):nTim(end)),2);
        for ptIdx=1:length(nTim)
            coilVec=mean(NptsOut.eyeCoil{ptIdx},2);
            gazeVec=mean(NptsOut.trueVector{ptIdx},2);
            quiver3(eyePos(1),eyePos(2),eyePos(3),coilVec(1),coilVec(2),coilVec(3),'b');
            quiver3(eyePos(1),eyePos(2),eyePos(3),gazeVec(1),gazeVec(2),gazeVec(3),'r');
            nPtsPos(:,ptIdx)=mean(nPts{ptIdx},2);
        end
        view(3); grid on;

         
        scatter3(nPtsPos(1,:),nPtsPos(2,:),nPtsPos(3,:));
    end
 


end