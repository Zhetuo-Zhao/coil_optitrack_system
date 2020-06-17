function tagging_plot(t,inputData, inputName, tagData,legendName,tRange)
    legendi=1;
    figure('units','normalized','outerposition',[0 0 1 1])
    for hi=1:length(inputData)
        h(hi)=subplot(length(inputData),1,hi); hold on;
        
        for i=1:size(inputData{hi},1)
            l(i)=plot(t,inputData{hi}(i,:)); 
        end
        title(inputName{hi});

        yLimits=1.1*[min(inputData{hi}(:)) max(inputData{hi}(:))];

        for i=1:length(tagData.eyeProbe)
            xt=tagData.t_sync(tagData.eyeProbe(i));
            line([xt xt],yLimits,'color','b');
            text(xt,1.1*yLimits(2),num2str(tagData.eyeProbe(i)));
        end

        for i=1:length(tagData.calib)
            xt=tagData.t_sync(tagData.calib(i));
            line([xt xt],yLimits,'color','g');
            if i==1
                text(xt,1.1*yLimits(2),num2str(tagData.calib(i)));
            end
        end

        for i=1:length(tagData.trialStarts)
            xt=tagData.t_sync(tagData.trialStarts(i));
            line([xt xt],yLimits,'color','r');
            text(xt,1.1*yLimits(2),num2str(tagData.trialStarts(i)));
        end
        
        for i=1:length(tagData.trialEnds)
            xt=tagData.t_sync(tagData.trialEnds(i));
            line([xt xt],yLimits,'color','k');
            text(xt,1.1*yLimits(2),num2str(tagData.trialEnds(i)));
        end

        if isfield(tagData,'user1')
            for i=1:length(tagData.user1)
                xt=tagData.t_sync(tagData.user1(i));
                line([xt xt],yLimits,'color','m');
            end
        end

        if isfield(tagData,'user2')
            for i=1:length(tagData.user2)
                xt=tagData.t_sync(tagData.user2(i));
                line([xt xt],yLimits,'color','c');
            end
        end

        
        if exist('legendName','var')
            legend(l,legendName(legendi:legendi+length(l)-1));
            legendi=legendi+length(l);
        end
        
        ylim(1.1*yLimits);
        xlabel('time (sec)');
        if exist('tRange','var')
            xlim(tRange)
        end
    end
    linkaxes(h,'x')
end