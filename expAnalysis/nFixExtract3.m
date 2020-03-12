% rely on input onset and offset of each fixation

function NptsOut=nFixExtract3(eye,fixTim,nPts,eyeIdx,VIEW)

% trialTim: 
% nPts: {N}(3xN)
margin=20;
NptsOut.nPts=nPts;%(1:end-1);

    if VIEW
        figure;
    end
    for ptIdx=length(NptsOut.nPts):-1:1
        % find out the fixation with longest duration
        fixDur=fixTim.fix(ptIdx,1)+margin+100: fixTim.fix(ptIdx,2)-margin;
        NptsOut.fixTim{ptIdx}=fixDur;
        NptsOut.eyeCoil{ptIdx}=eye.coil_sync{eyeIdx}(:,fixDur); 
        NptsOut.eyePos{ptIdx}=eye.pos{eyeIdx}(:,fixDur);
        trueVector{ptIdx}=NptsOut.nPts{ptIdx}(:,fixDur)-NptsOut.eyePos{ptIdx};
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

        eyePos=mean(eye.pos{eyeIdx}(:,fixTim.trial(1):fixTim.trial(2)),2);
        for ptIdx=length(NptsOut.nPts):-1:1
            coilVec=mean(NptsOut.eyeCoil{ptIdx},2);
            gazeVec=mean(NptsOut.trueVector{ptIdx},2);
            quiver3(eyePos(1),eyePos(2),eyePos(3),coilVec(1),coilVec(2),coilVec(3),'b');
            quiver3(eyePos(1),eyePos(2),eyePos(3),gazeVec(1),gazeVec(2),gazeVec(3),'r');
            nPtsPos(:,ptIdx)=mean(NptsOut.nPts{ptIdx},2);
        end
        view(3); grid on;

         
        scatter3(nPtsPos(1,:),nPtsPos(2,:),nPtsPos(3,:));
    end
 
    if VIEW
        figure; 
        for ptIdx=length(NptsOut.num):-1:1
            eyeVec=eye.coil_sync{eyeIdx}(:,NptsOut.fixTim{ptIdx});

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