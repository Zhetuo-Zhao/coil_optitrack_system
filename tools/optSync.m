function objects=optSync(optiData,optIdx)
    
    for i=1:length(optiData.data)
        objects{i}.name=optiData.data{i}.name;
        objects{i}.q=optiData.data{i}.q(:,optIdx);
        objects{i}.pos=optiData.data{i}.pos(:,optIdx);
        objects{i}.error=optiData.data{i}.error(:,optIdx);
        
        for j=1:length(optiData.data{i}.markers)
            objects{i}.marker{j}.pos=optiData.data{i}.markers{j}.pos;
            objects{i}.marker{j}.err=optiData.data{i}.markers{j}.err;
            
        end
    end
end