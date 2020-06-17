% use eye coil velocity to segment long fixations 

function NptsOut=nFixExtract2(eye,trialTim,nPts,thre,eyeIdx,VIEW)

% trialTim: 
% nPts: {N}(3xN)

    margin=20;
    
    NptsOut.nPts=nPts;
    trans=[0 find(diff(eye.coil_vel{eyeIdx}(trialTim)>thre)) length(trialTim)]; 
    transIdx=find(diff(trans)>500);
    
    
        figure; 
        subplot(2,1,1); plot(eye.coil_sync{1}(:,trialTim)');
        subplot(2,1,2); hold on;
        plot(eye.coil_vel{eyeIdx}(trialTim))
        for i=length(transIdx):-1:1
            line([trans(transIdx(i)) trans(transIdx(i))],[0 max(eye.coil_vel{eyeIdx}(trialTim))],'color','r');
            line([trans(transIdx(i)+1) trans(transIdx(i)+1)],[0 max(eye.coil_vel{eyeIdx}(trialTim))],'color','b');
        end
    if length(transIdx)~=9
        transIdx(end)=[];
    end
    
    NptsOut.nTim=trans(transIdx);

    if VIEW
        figure;
    end
    for ptIdx=length(nPts):-1:1
        % find out the fixation with longest duration
        fixTim=[trans(transIdx(ptIdx))+margin+100: trans(transIdx(ptIdx)+1)-margin]+trialTim(1);
        NptsOut.fixTim{ptIdx}=fixTim;
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

        eyePos=mean(eye.pos{eyeIdx}(:,trialTim(1):trialTim(end)),2);
        for ptIdx=length(nPts):-1:1
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