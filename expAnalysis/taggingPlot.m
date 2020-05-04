function taggingPlot(t,inputData, inputName, tagData,tRange,legendName)
    legendi=1;
    figure('units','normalized','outerposition',[0 0 1 1])
    for hi=1:length(inputData)
        h(hi)=subplot(length(inputData),1,hi); hold on;
        
        for i=1:size(inputData{hi},1)
            l(i)=plot(t,inputData{hi}(i,:)); 
        end
        title(inputName{hi});

        if exist('tRange','var')
            tmp=inputData{hi}(:,[tRange(1):tRange(2)]);
            yRange=max(tmp(:))-min(tmp(:));
            yLimits=[min(tmp(:))-0.1*yRange max(tmp(:))+0.1*yRange];
        else
            yLimits=[min(inputData{hi}(:))-0.1*abs(min(inputData{hi}(:))) max(inputData{hi}(:))+0.1*abs(max(inputData{hi}(:)))];
        end
        

        for i=1:length(tagData.eyeProbe)
            xt=t(tagData.eyeProbe(i));
            line([xt xt],yLimits,'color','b');
            text(xt,1.1*yLimits(2),num2str(tagData.eyeProbe(i)));
        end

        for i=1:length(tagData.calib)
            xt=t(tagData.calib(i));
            line([xt xt],yLimits,'color','g');
            if i==1
                text(xt,1.1*yLimits(2),num2str(tagData.calib(i)));
            end
        end

        for i=1:length(tagData.trialStarts)
            xt=t(tagData.trialStarts(i));
            line([xt xt],yLimits,'color','r');
            text(xt,1.1*yLimits(2),num2str(tagData.trialStarts(i)));
        end
        
        for i=1:length(tagData.trialEnds)
            xt=t(tagData.trialEnds(i));
            line([xt xt],yLimits,'color','k');
            text(xt,1.1*yLimits(2),num2str(tagData.trialEnds(i)));
        end

        if isfield(tagData,'user1')
            for i=1:length(tagData.user1)
                xt=t(tagData.user1(i));
                line([xt xt],yLimits,'color','m');
            end
        end

        if isfield(tagData,'user2')
            for i=1:length(tagData.user2)
                xt=t(tagData.user2(i));
                line([xt xt],yLimits,'color','c');
            end
        end

        
        if exist('legendName','var')
            legend(l,legendName(legendi:legendi+length(l)-1));
            legendi=legendi+length(l);
        end
        
        ylim(yLimits);
        xlabel('time (sec)');
        if exist('tRange','var')
            xlim(t(tRange))
        end
    end
    linkaxes(h,'x')
end