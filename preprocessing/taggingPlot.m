function taggingPlot(t,inputData, inputName, tagData,tRange,legendName)
    legendi=1;
    figure('units','normalized','outerposition',[0 0 1 1]);
    if ~exist('tRange','var')
        tRange=[1 length(t)];
        tDur=1:length(t);  
    else
        tDur=tRange(1):tRange(2);
    end
    for hi=1:length(inputData)
        h(hi)=subplot(length(inputData),1,hi); hold on;
        
        for i=1:size(inputData{hi},1)
            l(i)=plot(t(tDur),inputData{hi}(i,tDur)); 
        end
        title(inputName{hi});

        tmp=inputData{hi}(:,tDur); yRange=max(tmp(:))-min(tmp(:));
        yLimits=[min(tmp(:))-0.1*yRange max(tmp(:))+0.1*yRange];

        for i=1:length(tagData.eyeProbe)
            if mean(diff(t))==1
                xt=tagData.eyeProbe(i);
            else
                xt=tagData.t_sync(tagData.eyeProbe(i));
            end
            line([xt xt],yLimits,'color','b');
            text(xt,1.1*yLimits(2),num2str(tagData.eyeProbe(i)));
        end

        for i=1:length(tagData.calib)
            if mean(diff(t))==1
                xt=tagData.calib(i);
            else
                xt=tagData.t_sync(tagData.calib(i));
            end
            
            line([xt xt],yLimits,'color','g');
            if i==1
                text(xt,1.1*yLimits(2),num2str(tagData.calib(i)));
            end
        end

        for i=1:length(tagData.trialStarts)
            if mean(diff(t))==1
                xt=tagData.trialStarts(i);
            else
                xt=tagData.t_sync(tagData.trialStarts(i));
            end
            line([xt xt],yLimits,'color','r');
            text(xt,1.1*yLimits(2),num2str(tagData.trialStarts(i)));
        end
        
        for i=1:length(tagData.trialEnds)
            if mean(diff(t))==1
                xt=tagData.trialEnds(i);
            else
                xt=tagData.t_sync(tagData.trialEnds(i));
            end
            line([xt xt],yLimits,'color','k');
            text(xt,1.1*yLimits(2),num2str(tagData.trialEnds(i)));
        end

        if isfield(tagData,'user1')
            for i=1:length(tagData.user1)
                if mean(diff(t))==1
                    xt=tagData.user1(i);
                else
                    xt=tagData.t_sync(tagData.user1(i));
                end
                line([xt xt],yLimits,'color','m');
                text(xt,1.1*yLimits(2),num2str(tagData.user1(i)));
            end
        end

        if isfield(tagData,'user2')
            for i=1:length(tagData.user2)
                if mean(diff(t))==1
                    xt=tagData.user2(i);
                else
                    xt=tagData.t_sync(tagData.user2(i));
                end
                line([xt xt],yLimits,'color','c');
                text(xt,1.1*yLimits(2),num2str(tagData.user2(i)));
            end
        end

        
%         if exist('legendName','var')
%             legend(l,legendName(legendi:legendi+length(l)-1));
%             legendi=legendi+length(l);
%         end
        if mean(diff(t))==1
            xlabel('frame');
        else
            xlabel('time (sec)');
        end
        ylim(yLimits);
        xlim(t(tRange));
      
    end
    linkaxes(h,'x')
end