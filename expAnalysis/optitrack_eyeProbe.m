function eyeProbe=optitrack_eyeProbe(eyeProbe,calibFrame,offsetL,markerIdx)

    % INPUT:
    %   offsetL: the distance in m between the center of three back markers
    %            and the end point of the probe.
    
    % OUPUT: all outputs are in optitrack coordinate
    %   eyeProbe.offsetLoc{1}: position of end of the probe
   
    for ii=1:length(calibFrame)
        for i=1:4
            pos4{i}=mean(eyeProbe.marker{markerIdx(i)}.pos(:,calibFrame{ii}),2);
        end
        center3=(pos4{1}+pos4{2}+pos4{3})/3; 
        vec=pos4{4}-center3; vec=vec/norm(vec);
        eyeProbe.offsetLoc{ii}=pos4{4}+offsetL*vec;    
    end
%     figure; hold on;
%     for i=1:4
%         scatter3(pos4{i}(1),pos4{i}(2),pos4{i}(3));
%     end
%     scatter3(eyeProbe.offsetLoc{1}(1),eyeProbe.offsetLoc{1}(2),eyeProbe.offsetLoc{1}(3));
%     view(3);
end