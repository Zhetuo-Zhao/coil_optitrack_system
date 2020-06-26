function NptsOut=nFixExtract(eye,nTim,nPts,thre,eyeIdx,VIEW)

% nTime: 1xN
% nPts: {N}(3xN)

    margin=20;
    
    NptsOut.nPts=nPts;
    NptsOut.nTim=nTim;

    if VIEW
        figure;
    end
    for ptIdx=length(nPts):-1:1
        % find out the fixation with longest duration
        trans=[0 find(diff(eye.coil_vel{eyeIdx}(nTim(ptIdx):nTim(ptIdx+1))>thre)) length(nTim(ptIdx):nTim(ptIdx+1))]; 
        [~,maxI]=max(diff(trans));
        fixTim=(trans(maxI)+margin+150:trans(maxI+1)-margin)+nTim(ptIdx);
 
        NptsOut.eyeCoil{ptIdx}=eye.coil_sync{eyeIdx}(:,fixTim); %eyeCoil9pts{ptIdx}=normc(eyeCoil9pts{ptIdx});  
        NptsOut.eyePos{ptIdx}=eye.pos{eyeIdx}(:,fixTim);
        trueVector{ptIdx}=nPts{ptIdx}(:,fixTim)-NptsOut.eyePos{ptIdx};
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
        for ptIdx=1:length(nPts)
            coilVec=mean(NptsOut.eyeCoil{ptIdx},2);
            gazeVec=mean(NptsOut.trueVector{ptIdx},2);
            quiver3(eyePos(1),eyePos(2),eyePos(3),coilVec(1),coilVec(2),coilVec(3),'b');
            quiver3(eyePos(1),eyePos(2),eyePos(3),gazeVec(1),gazeVec(2),gazeVec(3),'r');
            nPtsPos(:,ptIdx)=mean(nPts{ptIdx},2);
        end
        view(3); grid on;

         
        scatter3(nPtsPos(1,:),nPtsPos(2,:),nPtsPos(3,:));
    end
 
    if VIEW
        figure; 
        for ptIdx=length(NptsOut.num):-1:1
            eyeVec=eye.coil_sync{eyeIdx}(:,nTim(ptIdx):nTim(ptIdx+1));

            subplot(3,3,ptIdx); hold on;
            plot((eyeVec-mean(eyeVec,2))')
        end
    end

    
    if VIEW
        figure; 
        for ptIdx=length(NptsOut.num):-1:1
            eyeVec=NptsOut.eyeCoil{ptIdx};

            subplot(3,3,ptIdx); hold on;
            plot((eyeVec-mean(eyeVec,2))')
        end
    end

end