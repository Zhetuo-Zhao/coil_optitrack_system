clear; close all; 
direct='.\200306_run3\';
for partIdx=2:4
    load([direct sprintf('handData%d.mat',partIdx)]);
    R_opti2room=[0 0 -1;-1 0 0 ; 0 1 0];
    DEMO=0;

    %% plot hand gesture at initial position
    figure; hold on;
    for i=1:22
        p=R_opti2room*valSkel.joints(i).position;
        v=R_opti2room*valSkel.joints(i).axis;
        quiver3(p(1),p(2),p(3),v(1),v(2),v(3),5);
        text(p(1),p(2),p(3),num2str(i));

        pos=valSkel.joints(i).position; pos(1)=-pos(1); 
        ax=valSkel.joints(i).axis; ax(2)=-ax(2);   ax(3)=-ax(3);
        p2=R_opti2room*pos;
        v2=R_opti2room*ax;
        quiver3(p2(1),p2(2),p2(3),v2(1),v2(2),v2(3),5);
        text(p2(1),p2(2),p2(3),num2str(i));
    end
    grid on; view(3);

    %% reformat the initial joint axis and position
    handRef{1}.wrist{1}=valSkel.joints(21); handRef{2}.wrist{1}=handConvert(handRef{1}.wrist{1});
    handRef{1}.wrist{2}=valSkel.joints(22); handRef{2}.wrist{2}=handConvert(handRef{1}.wrist{2});
    for fi=1:5
        for ji=1:4
            handRef{1}.fingers{fi}{ji}=valSkel.joints(4*(fi-1)+ji);
            handRef{1}.fingers{fi}{ji}.idx=4*(fi-1)+ji;

            handRef{2}.fingers{fi}{ji}=handConvert(handRef{1}.fingers{fi}{ji});
        end
    end


    %% reformat joint angles at each frame into a vector
    frameIdx=0;
    prev{1}=valposes.x0.x0;
    prev{2}=valposes.x0.x1;
    while (1)
        frameIdx
        if isfield(valposes,sprintf('x%d',frameIdx))
            for handIdx=1:2
                tmp=eval(sprintf('valposes.x%d.x%d',frameIdx,handIdx-1));

                if norm(tmp.JointAngles)==0
                    tmp=prev{handIdx};
                end

                handT{handIdx}.wristQ(:,frameIdx+1)=tmp.WristRotation;
                handT{handIdx}.wristP(:,frameIdx+1)=tmp.WristTranslation;
                handT{handIdx}.JointAngles(:,frameIdx+1)=tmp.JointAngles;

                prev{handIdx}=tmp;

            end
            frameIdx=frameIdx+1;
        else
            break;
        end
    end


    %% calculate hand gesture for each frame
    T=size(handT{1}.JointAngles,2);

    for t=1:T
        t
        for handIdx=1:2

            wristR=Q2R(handT{handIdx}.wristQ(:,t));
            wristP=handT{handIdx}.wristP(:,t);

            for fi=1:5
                handT{handIdx}.out{fi,t}=zeros(3,6); 
                handT{handIdx}.out{fi,t}(:,1)=wristP; % for each finger, the first joint is wrist

                RP_prev=eye(4);
                for ji=1:5

                    if ji==1
                        pt=handRef{handIdx}.fingers{fi}{ji}.position;
                        Rt=wristR;
                        RP=R4(Rt,Rt*pt+wristP);
                        RP0=RP;
                    else
                        if ji==5
                            pt=0.5*(handRef{handIdx}.fingers{fi}{4}.position-handRef{handIdx}.fingers{fi}{3}.position);
                        else
                            pt=handRef{handIdx}.fingers{fi}{ji}.position-handRef{handIdx}.fingers{fi}{ji-1}.position;
                        end
                        Rt=axisAngle2R(handRef{handIdx}.fingers{fi}{ji-1}.axis,handT{handIdx}.JointAngles(handRef{handIdx}.fingers{fi}{ji-1}.idx,t));
                        RP=R4(Rt,Rt*pt);
                        RP0=RP_prev*RP;
                    end

                    tmp=RP0*[0;0;0;1];
                    handT{handIdx}.out{fi,t}(:,ji+1)=tmp(1:3);

                    RP_prev=RP0;
                end
            end

        end
    end

    save([direct sprintf('processed_hand%d.mat',partIdx)],'handT');
end
%% hand visualization, save video
if DEMO
    clear tmp;

    myVideo = VideoWriter(['..\' 'handVideo']); %open video file
    myVideo.FrameRate = 24; 
    open(myVideo)

    figure('position',[30 30 550 650]);  cols=get(gca,'colorOrder');
    for t=1:T
        t
        hold on;
        for hi=1:2
            for fi=1:5
                tmp=R_opti2room*handT{hi}.out{fi,t};
                scatter3(tmp(1,:),tmp(2,:),tmp(3,:),'MarkerEdgeColor','k',...
                'MarkerFaceColor',cols(fi,:));

                for ji=2:6
                   plot3([tmp(1,ji-1) tmp(1,ji)],[tmp(2,ji-1) tmp(2,ji)],[tmp(3,ji-1) tmp(3,ji)],'color',cols(fi,:)) 
                end
            end
        end
        view(3); view([146 30]); grid on;
        xlabel('x'); ylabel('y'); zlabel('z');
        xlim([-100 800]); ylim([-1400 -400]); zlim([450 1150]);
        title(sprintf('frame=%d',t))
        pause(0.01) %Pause and grab frame
        frame = getframe(gcf); %get frame
        writeVideo(myVideo, frame);
        hold off;
        clf;
    end
    close(myVideo)
end