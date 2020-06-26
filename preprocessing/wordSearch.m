function [out,idx]=wordSearch(inputNames,keyWords,noWords)
    if exist('keyWords')
        containV=ones(1,length(inputNames));
        for i=1:length(inputNames)
            for j=1:length(keyWords)
                containV(i)=containV(i)&contains(lower(inputNames{i}), lower(keyWords{j}));
            end
            
            if exist('noWords')
                for j=1:length(noWords)
                    containV(i)=containV(i)&~contains(lower(inputNames{i}), lower(noWords{j}));
                end
            end
        end
        if sum(containV)>1
            error('More than one items contain key words. Try other key words.')
        elseif sum(containV)==0
            error('No item contain key words. Try other key words.')
        else
            idx=find(containV);
            out=inputNames{idx};
        end
    else
        tryI=1;
        while (1)
            keyWords{tryI}=input('input keywords: ','s');

            if strcmp(keyWords{tryI},'STOP')
                idx=[];
                out=[];
                break;
            end
            containV=ones(1,length(inputNames));
            for i=1:length(inputNames)
                for j=1:length(keyWords)
                    containV(i)=containV(i)&contains(lower(inputNames{i}), lower(keyWords{j}));
                end
            end
            
            if sum(containV)>1
                inputNames{find(containV)}
            else
                idx=find(containV);
                out=inputNames{idx};
                break;
            end
            tryI=tryI+1;
        end
    end
end