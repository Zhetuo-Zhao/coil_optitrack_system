clear; close all;
session='05-Feb-2020';
folder='fieldCalibration_high';
% direct=['Z:/fieldCalibrate/data/' session '/' folder '/'];
direct=['\\opus.cvs.rochester.edu\aplab\fieldCalibrate\data\' session '/' folder '/'];
% direct=['/media/aplab/fieldCalibrate/data/' session '/' folder '/'];
debugIdx=1:3;


load([direct 'syncData_lite.mat']);
outputFolder=[direct 'results/' 'Figures/'];
VIEW=1;
if ~exist(outputFolder)
   mkdir(outputFolder); 
end

% x in coil data need to be reversed
for i=1:4
    coil{i}(1,:)=-coil{i}(1,:);
end
% sync debug
for i=1:4
    coil{i}=-coil{i}(:,2:end);
    nc{i}=nc{i}(:,1:end-1);
    pos{i}=pos{i}(:,1:end-1);
end

% match the sign of optitrack data with coil readings
for i=1:4
    %nc{i}=-nc{i};
    coil{i}(:,find(vecnorm(nc{i}-nc{i}(:,1))>0.5))=[];
    pos{i}(:,find(vecnorm(nc{i}-nc{i}(:,1))>0.5))=[];
    nc{i}(:,find(vecnorm(nc{i}-nc{i}(:,1))>0.5))=[];  
end


if VIEW
    figure; 
    for i=1:4
       subplot(2,2,i); hold on; plot(coil{i}'); plot(nc{i}')  
    end
end

figure; hold on;
for i=1:4
   quiver3(0,0,0,mean(coil{i}(1,:)),mean(coil{i}(2,:)),mean(coil{i}(3,:)),'r'); 
   quiver3(0,0,0,mean(nc{i}(1,:)),mean(nc{i}(2,:)),mean(nc{i}(3,:)),'b'); 
end
view(3); grid on;
xlabel('x'); ylabel('y'); zlabel('z');
% plot the trajectory of the slider in three sections: x, y, z
axisName={'ppp','npn','nnp','pnn'};
if VIEW
figure; hold on;
for i=1:4
   plot(pos{i}(1,:),pos{i}(2,:),'displayName',axisName{i}) 
end
xlabel('x (m)'); ylabel('y (m)');
legend show;
saveas(gcf,[outputFolder 'pos2D' '.png']);
saveas(gcf,[outputFolder 'pos2D'], 'epsc');
saveas(gcf,[outputFolder 'pos2D.png']);
end

%% Bin data points in space
% find range of the coil motion
% minX=0.5; maxX=1.2; minY=0.5; maxY=1.2;
% N=60; bw=min(maxX-minX, maxY-minY)/N; % determine the bin size

minX=-0.2; maxX=0.8; minY=-1.5; maxY=-0.5;
N=50; bw=min(maxX-minX, maxY-minY)/N; % determine the bin size

% bin data points: BinM-2D map of three coils, MxNx3 cells. Each cell
% contains indexes of samples belong to this block 
M=round((maxX-minX)/bw)+1;
N=round((maxY-minY)/bw)+1;
BinM=cell(M, N, 4);

for coilIdx=1:4
    coil_pos_bin=round((pos{coilIdx}-[minX; minY; 0])/bw)+1;

    numM{coilIdx}=zeros(M,N);
    
    for t=1:size(pos{coilIdx},2)
        binIdx=coil_pos_bin(:,t);
        if binIdx(1)>0 && binIdx(2)>0 && binIdx(1)<=M && binIdx(2)<=N
            BinM{binIdx(1),binIdx(2),coilIdx}=[BinM{binIdx(1),binIdx(2),coilIdx} t];
            numM{coilIdx}(binIdx(1),binIdx(2))=numM{coilIdx}(binIdx(1),binIdx(2))+1;
        end
    end
end

% a figure shows that how many blocks contain data points 
if VIEW
figure; 
for i=1:4
    subplot(1,5,i); 
    imshow(numM{i}'>1,[]);
    title(axisName{i});
end
subplot(1,5,5); 
% imshow(numM{1}'>1 & numM{2}'>1 & numM{3}'>1 & numM{4}'>1,[]);
imshow(numM{1}'>1 & numM{2}'>1 & numM{3}'>1 & numM{4}'>1,[]);
title('coverage');
saveas(gcf,[outputFolder 'dataCover' '.png']);
saveas(gcf,[outputFolder 'dataCover'], 'epsc');
saveas(gcf,[outputFolder 'dataCover.png']);
end


%% fit local field in each block
tic;
% axisM=eye(3);
for Bidx=1:3 % three fields
    for x=N:-1:1
        disp(['session ', session, ', Field ', num2str(Bidx), ', (', num2str(x), ',', num2str(1), ')']);
        for y=N:-1:1
            estField{x,y}.centerXY=([x y]-1)*bw+[minX minY]; % center of each block
            estField{x,y}.center=[estField{x,y}.centerXY mean(pos{1}(3,BinM{x,y,1}))];
            if numM{1}(x,y)>0 && numM{2}(x,y)>0 && numM{3}(x,y)>0 && numM{4}(x,y)>0
                % estField{x,y}.reading3=[];
                % estField{x,y}.orient3=[];
                % estField{x,y}.pos3=[];
                % estField{x,y}.num3=0;
                for coilIdx=4:-1:1
                    % store data for debugging
                    estField{x,y}.reading{coilIdx}=coil{coilIdx}(:,BinM{x,y,coilIdx});
                    estField{x,y}.orient{coilIdx}=nc{coilIdx}(:,BinM{x,y,coilIdx});
                    estField{x,y}.pos{coilIdx}=pos{coilIdx}(:,BinM{x,y,coilIdx});
                    estField{x,y}.num{coilIdx}=length(BinM{x,y,coilIdx});
                end
                
                estField{x,y}.reading4=[]; estField{x,y}.orient4=[]; estField{x,y}.pos4=[]; 
                for coilIdx=debugIdx
                    estField{x,y}.reading4=[estField{x,y}.reading4 coil{coilIdx}(:,BinM{x,y,coilIdx})];
                    estField{x,y}.orient4=[estField{x,y}.orient4 nc{coilIdx}(:,BinM{x,y,coilIdx})];
                    estField{x,y}.pos4=[estField{x,y}.pos4 pos{coilIdx}(:,BinM{x,y,coilIdx})];
                end
                estField{x,y}.num4=length([BinM{x,y,debugIdx}]);
                % local field least square fitting
                for i=20:-1:1 % Find N local minmum points and test to find out the best among them: 1. find out global minimum. 2. to aviod outliers
                                    
                    % extract data falling in each block
                    coil_reading_input=[];
                    coil_orient_input=[];
                    coil_pos_input=[];
                    for coilIdx=debugIdx
                        sampleIdx=BinM{x,y,coilIdx};
                        % for each iteration, randomly choose half the data to
                        % serve as the input for fitting. THis is an approach
                        % to aviod outliers to bias the final estimation.
                        randIdx=randsample(length(sampleIdx),round(length(sampleIdx)/2));
                        
                        coil_reading_input=[coil_reading_input coil{coilIdx}(Bidx,sampleIdx(randIdx))]; 
                        coil_orient_input=[coil_orient_input nc{coilIdx}(:,sampleIdx(randIdx))]; 
                        coil_pos_input=[coil_pos_input pos{coilIdx}(:,sampleIdx(randIdx))];
                    end
                    
                    % square error between coil reading and calculated coil reading:
                    % (c-B*cos(<nc,nf>))^2 
                    % ==> c: coil_reading_input 
                    % ==> B: field magnitude
                    % ==> nf: field direction
                    % ==> nc: coil_orient_input 
                    % Bn=[B nf] 1x4 vector
                    f = @(Bn)localCost(Bn,estField{x,y}.centerXY',coil_reading_input,coil_pos_input,coil_orient_input);
                 

                    % constrained optimization
                    % f -- cost function, g -- constrain function
                    % B within [0.3, 2], nf within [-1, 1]
                    Bn = fmincon(f,rand(1,3),[],[],[],[],[-2,-2,-2],[2,2,2],[],optimoptions('fmincon','Display','off'));
                    B=norm(Bn);  BV(i)=B;
                    nf=Bn'/B; nfV(:,i)=Bn'/B;
                    
                    % testing with all data in this block
                    costV(i)=localCost(Bn,estField{x,y}.centerXY',estField{x,y}.reading4(Bidx,:),estField{x,y}.pos4,estField{x,y}.orient4);
                end
                
                % find the solution achieves the lowest cost which is the
                % global minimum solution
                [tmp,minIdx]=min(costV);
                
                estField{x,y}.BV{Bidx}=BV;
                estField{x,y}.nfV{Bidx}=nfV;
                estField{x,y}.B{Bidx}=BV(minIdx);
                estField{x,y}.nf{Bidx}=nfV(:,minIdx);
                
                % plots for debugging
                %[estField{x,y}.B{Bidx}  estField{x,y}.nf{Bidx}']
                
                %figure;
                %subplot(3,1,1); plot(costV); title('cost');
                %subplot(3,1,2); plot(BV); title('B');
                %subplot(3,1,3); plot(nfV'); title('nf');
                
                %plotOutlier(estField{x,y},[x y 0 Bidx],outputFolder);
                
            end  
        end
    end    
end
toc;

save([direct '/results/estFieldR13_syncDebug.mat'],'estField')
