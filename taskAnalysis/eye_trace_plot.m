function eye_trace_plot(trace2, eyeEvents)  

    % eye in room in arcmin and ms
    figure; hold on; cols=get(gca, 'colorOrder'); 
    hx=plot(trace2(1,:),'DisplayName','horizontal angle');
    hy=plot(trace2(2,:),'DisplayName','vertical angle');
    
    xlabel('time (sec)')
    ylabel('angle (arcmin)')
    title('eye angles in reference of the room (coil system)');
    grid on 
    
    yl=ylim;
    
    for i=1:length(eyeEvents.blinks)
        st=eyeEvents.blinks(i).startTime;
        et=eyeEvents.blinks(i).endTime;
        rectangle('position',[st yl(1) et-st  yl(2)-yl(1)],'EdgeColor','none','FaceColor',[cols(3,:) 0.5]);
    end
    
    for i=1:length(eyeEvents.saccs)
        st=eyeEvents.saccs(i).startTime;
        et=eyeEvents.saccs(i).endTime;
        rectangle('position',[st yl(1) et-st  yl(2)-yl(1)],'EdgeColor','none','FaceColor',[cols(4,:) 0.5]);
    end
    
    for i=1:length(eyeEvents.mSaccs)
        st=eyeEvents.mSaccs(i).startTime;
        et=eyeEvents.mSaccs(i).endTime;
        rectangle('position',[st yl(1) et-st  yl(2)-yl(1)],'EdgeColor','none','FaceColor',[cols(5,:) 0.5]);
    end

%     for i=1:length(eyeEvents.events)
%         st=eyeEvents.events(i).startTime;
%         et=eyeEvents.events(i).endTime;
%         rectangle('position',[st yl(1) et-st  yl(2)-yl(1)],'EdgeColor','none','FaceColor',[cols(6,:) 0.5]);
%     end

    

    hSacc = plot(NaN,NaN,'color',cols(3,:),'linewidth',2,'DisplayName','blinks');
    hMsacc = plot(NaN,NaN,'color',cols(4,:),'linewidth',2,'DisplayName','saccades');
    hBlink = plot(NaN,NaN,'color',cols(5,:),'LineWidth',2,'DisplayName','microsaccades');
%    events = plot(NaN,NaN,'color',cols(5,:),'LineWidth',2,'DisplayName','microsaccades');
    legend([hx hy hSacc hMsacc hBlink])
end