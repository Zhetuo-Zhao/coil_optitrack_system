%x,y are eye trace arcmin at ms
function EM=trace_segment(trace2T)
    velMin=1.8;  % arcmin/ms       minimum velocity of eye movements
    velMaxMin=1.8;  % arcmin/ms    minimum velocity of saccade and blink
    minGap=20;  % ms               combine near eye movements
    saccMinAmp=30; % arcmin        saccade minimum amplitude
    msaccMinAmp=10; % arcmin       microsaccade minimum amplitude
    msaccMaxAmp=60; % arcmin       microsaccade maximum amplitude
    
    drifts=[];
    events=[];
    blinks=[];
    saccs=[];
    mSaccs=[];
    
    x=trace2T(1,:);
    y=trace2T(2,:);
    vx=sgfilt(x,3,21,1);
    vy=sgfilt(y,3,21,1);

    vel=sqrt(vx.^2+vy.^2);


    velFlag=vel>velMin;
    velDelta=velFlag(2:end)-velFlag(1:end-1);


    ps=find(velDelta==1)+1;
    et=1;
    for i=1:length(ps)
        st=ps(i);

        if st<=et
            continue
        end

     
        if st>et+minGap
            tmpDrift.startTime=et;
            tmpDrift.endTime=st;
            tmpDrift.duration=st-et;
            tmpDrift.x=x(et:st);
            tmpDrift.y=y(et:st);
            drifts=[drifts tmpDrift];
        end

        dur=find(velDelta(st:end)==-1,1);
        if isempty(dur)
            continue;
        else
            et=dur+st;
        end
        
        dur=find(velDelta(et:end)==1,1);
        if ~isempty(dur)
            st2=dur+et;
            while (abs(st2-et)<minGap)
                et2=find(velDelta(st2:end)==-1,1)+st2;
                et=et2;
                st2=find(velDelta(et:end)==1,1)+et;
            end
        end
        
        tmpEvent.startTime=st;
        tmpEvent.endTime=et;
        events=[events tmpEvent];
        
        if isempty(et)
            continue;
        end

        vxMax=max(vx(st:et)); vxMin=min(vx(st:et));
        vyMax=max(vy(st:et)); vyMin=min(vy(st:et));
        
        if vxMax>velMaxMin && vxMin<-velMaxMin && vyMax>velMaxMin && vyMin<-velMaxMin  %blink
            tmpBlink.startTime=st;
            tmpBlink.endTime=et;

            blinks=[blinks tmpBlink];

        else
            deltaX=x(et)-x(st);
            deltaY=y(et)-y(st);
            dist=sqrt(deltaX^2+deltaY^2);

            if (dist>30) % saccade 
                tmpSacc.startTime=st;
                tmpSacc.endTime=et;
                tmpSacc.duration=et-st;
                tmpSacc.size=dist;
                tmpSacc.x=x(st:et);
                tmpSacc.y=y(st:et);
                saccs=[saccs tmpSacc];

            else   
                if (dist>10) && (dist<60) % microsaccade
                    tmpMsacc.startTime=st;
                    tmpMsacc.endTime=et;
                    tmpMsacc.duration=et-st;
                    tmpMsacc.size=dist;
                    tmpMsacc.x=x(st:et);
                    tmpMsacc.y=y(st:et);
                    mSaccs=[mSaccs tmpMsacc];
                end
            end
        end
    end

    di2=1;
    for di=1:length(drifts)
        if drifts(di).duration<100
            if di>1 && (drifts(di).startTime-drifts2(di2-1).endTime<10)
                drifts2(di2-1).endTime=drifts(di).endTime;
                drifts2(di2-1).duration=drifts2(di2-1).duration+drifts(di).duration;
                drifts2(di2-1).x=[drifts2(di2-1).x drifts(di).x];
                drifts2(di2-1).y=[drifts2(di2-1).y drifts(di).y];
            else
            
            if di<length(drifts) && (drifts(di+1).startTime-drifts(di).endTime<10)
                drifts(di+1).startTime=drifts(di).startTime;
                drifts(di+1).duration=drifts(di).duration+drifts(di+1).duration;
                drifts(di+1).x=[drifts(di).x drifts(di+1).x];
                drifts(di+1).y=[drifts(di).y drifts(di+1).y];
            else
                drifts2(di2)=drifts(di);
                di2=di2+1;
            end
            end
        else
            drifts2(di2)=drifts(di);
            di2=di2+1;
        end
    end
    
    EM.events=events;
    EM.drifts=drifts2;
    EM.blinks=blinks;
    EM.saccs=saccs;
    EM.mSaccs=mSaccs;
end