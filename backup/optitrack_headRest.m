function out=optitrack_headRest(obj,calibFrame,markerIdx)
    out=obj;
    for i=1:length(obj.marker)
       markerPos{i}= mean(obj.marker{i}.pos(:,calibFrame),2);
    end

    if length(markerIdx)==5
        for i=1:4
            idxes=markerIdx;
            idxes(i)=[];
            v1{i}=cross(markerPos{idxes(1)}-markerPos{idxes(2)}, markerPos{idxes(3)}-markerPos{idxes(2)}); 
            v1{i}=normc(v1{i});

            headrestPos=mean(obj.pos(:,calibFrame),2);
            if norm(headrestPos+v1{i}-markerPos{idxes(end)}) < norm(headrestPos-v1{i}-markerPos{idxes(end)})
                v1{i}=-v1{i};
            end
        end
        out.vector{1}=(v1{1}+v1{2}+v1{3}+v1{4})/4;
    else
        v1=cross(markerPos{markerIdx(1)}-markerPos{markerIdx(2)}, markerPos{markerIdx(3)}-markerPos{markerIdx(2)}); 
        v1=normc(v1);

        headrestPos=mean(obj.pos(:,calibFrame),2);
        if norm(headrestPos+v1-markerPos{markerIdx(4)}) < norm(headrestPos-v1-markerPos{markerIdx(4)})
                v1=-v1;
        end
        out.vector{1}=v1;
    end
end