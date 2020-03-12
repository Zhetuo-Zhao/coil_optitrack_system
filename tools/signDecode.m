function sig=signDecode(amp, phDiff,outputFolder,VIEW, axisIdx)
   minThreld=3E-4;
   edges=[1 find(abs(diff(phDiff>pi/2))>0) length(phDiff)];
   sig=[]; debug=[];
   if length(edges)>2 % if coil passes the parallel surface, coil min value should be zero
       amp=amp-min(amp);
   end
   for j=1:length(edges)-1
       section_phaseDiff=phDiff(edges(j):edges(j+1));
       if mean(section_phaseDiff)<pi/2 && min(section_phaseDiff)<1 % testing coil has the same phase with the reference coil
           sig(edges(j):edges(j+1))=amp(edges(j):edges(j+1));
           debug(edges(j):edges(j+1))=ones(1,edges(j+1)-edges(j)+1);
       else
           if mean(section_phaseDiff)>pi/2 && max(section_phaseDiff)>pi-1 % testing coil has the opposite phase with the reference coil
                sig(edges(j):edges(j+1))=-amp(edges(j):edges(j+1));
                debug(edges(j):edges(j+1))=zeros(1,edges(j+1)-edges(j)+1);
                
           else  % testing coil has phase ambiguity due to the unstable carrier frequency
               if amp(edges(j))>minThreld && amp(edges(j+1))>minThreld
                   if j>1
                       sig(edges(j):edges(j+1))=sign(mean(sig(edges(j-1):edges(j))))*amp(edges(j):edges(j+1));
                   else
                       if j==length(edges)-1
                           sig(edges(j):edges(j+1))=sign(mean(sig(edges(j+1):edges(j+2))))*amp(edges(j):edges(j+1));
                       else
                           if amp(edges(j))>amp(edges(j+1))
                               sig(edges(j):edges(j+1))=sign(mean(sig(edges(j-1):edges(j))))*amp(edges(j):edges(j+1));
                           else
                               sig(edges(j):edges(j+1))=sign(mean(sig(edges(j+1):edges(j+2))))*amp(edges(j):edges(j+1));
                           end
                       end
                   end
               else         
                    sig(edges(j):edges(j+1))=((mean(section_phaseDiff)<pi/2)-0.5)*2*amp(edges(j):edges(j+1));
               end
               
               debug(edges(j):edges(j+1))=0.5*ones(1,edges(j+1)-edges(j)+1);
           end
       end
   end

   axis3={'x','y','z'};
   if VIEW
       figure; 
       h1=subplot(3,1,1); hold on; plot(amp); plot(((phDiff<pi/2)-0.5)*2.*amp);
       h2=subplot(3,1,2); hold on; plot(phDiff); plot(phDiff<pi/2); plot(debug);
       h3=subplot(3,1,3); hold on; plot(amp); plot(sig);
       linkaxes([h1 h2 h3],'x');

       saveas(gcf,[outputFolder 'coil_debug_' axis3{axisIdx} '.png'])
       saveas(gcf,[outputFolder 'coil_debug_' axis3{axisIdx}], 'epsc')
       saveas(gcf,[outputFolder 'coil_debug_' axis3{axisIdx}, '.fig'])
   end
end