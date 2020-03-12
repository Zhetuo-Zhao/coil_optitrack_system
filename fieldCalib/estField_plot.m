clear; close all;

session='20-dec-2019';
folder='calibrate1';
% direct=['/media/aplab/fieldCalibrate/data/' session '/' folder '/results/'];
direct=['\\opus.cvs.rochester.edu\aplab/fieldCalibrate/data/' session '/' folder '/results/'];

fields=1:3;

    % outputFolder=[direct 'Figures2\' sessionNames{i} '\'];
    outputFolder=[direct 'FiguresR13_syncDebug/'];
    if ~exist(outputFolder)
       mkdir(outputFolder); 
    end

    % load([direct 'estField_' sessionNames{i} '.mat']);
    load([direct 'estFieldR13_syncDebug.mat']);
    close all;


minX=-0.2; maxX=0.8; minY=-1.5; maxY=-0.5;
%     minX=0.5; maxX=1.2; minY=0.5; maxY=1.2;
    N=60; bw=min(maxX-minX, maxY-minY)/N; % determine the bin size

    binX=(1:N-1)*bw+minX;
    binY=(1:N-1)*bw+minY;

    % %% quiver plot
    fieldName={'fieldX','fieldY','fieldZ'};
%     for Bidx=fields
%         figure1=figure; hold on;
%         for x=1:size(estField,1)
%             for y=1:size(estField,2)
%                 if isfield(estField{x,y},'nf')
%                     h2=quiver3(estField{x,y}.centerXY(1),estField{x,y}.centerXY(2),0,...
%                                estField{x,y}.nf{Bidx}(1),estField{x,y}.nf{Bidx}(2),estField{x,y}.nf{Bidx}(3));
%                     set(h2,'AutoScale','on', 'AutoScaleFactor', estField{x,y}.B{Bidx}/30);
%                 end
%             end
%         end
%         grid on;
%         view(3)
%         xlabel('coil x (m)'); ylabel('coil y (m)'); zlabel('coil z (m)');
%         saveas(figure1, [outputFolder fieldName{Bidx} '_quiver.fig'])
%         saveas(figure1, [outputFolder fieldName{Bidx} '_quiver.png'])
%         saveas(figure1, [outputFolder fieldName{Bidx} '_quiver'], 'epsc')
%     end


    %% 2D field plot

    % field amplitude
    for Bidx=fields
        BM{Bidx}=zeros(size(estField,1),size(estField,2));

        for x=1:size(estField,1)
            for y=1:size(estField,2)
                if isfield(estField{x,y},'B')
                    BM{Bidx}(x,y)=estField{x,y}.B{Bidx};
                else
                    BM{Bidx}(x,y)=NaN;
                end
            end
        end
       
        figure; imagesc(binX,binY,BM{Bidx}'); title('field amplitude: B(x,y)');
        xlabel('coil x (m)'); ylabel('coil y (m)'); 
        colormap( [0 0 0; parula(256)] )
        %caxis( [1.1 1.134] )
        colorbar
        saveas(gcf, [outputFolder fieldName{Bidx} '_B.png'])
        saveas(gcf, [outputFolder fieldName{Bidx} '_B'], 'epsc')
        saveas(gcf, [outputFolder fieldName{Bidx} '_B.fig'])
    end

    % field direction angle 1
    for Bidx=fields
        nfM1{Bidx}=zeros(size(estField,1),size(estField,2));

        for x=1:size(estField,1)
            for y=1:size(estField,2)
                if isfield(estField{x,y},'nf')
                    nf=estField{x,y}.nf{Bidx}; nf=nf/norm(nf);
                    nfM1{Bidx}(x,y)=atan(nf(2)/nf(1))/pi*180;
                else
                    nfM1{Bidx}(x,y)=NaN;
                end
                
            end
        end
       
        figure; imagesc(binX,binY,nfM1{Bidx}');
        xlabel('coil x (m)'); ylabel('coil y (m)'); 
        colormap( [0 0 0; parula(256)] )
        colorbar
        c=colorbar;
        c.Label.String='degree';
        c.Label.FontSize=12;
        saveas(gcf, [outputFolder fieldName{Bidx} '_nfM1.png'])
        saveas(gcf, [outputFolder fieldName{Bidx} '_nfM1'], 'epsc')
        saveas(gcf, [outputFolder fieldName{Bidx} '_nfM1.fig'])
    end

    % field direction angle 2
    for Bidx=fields
        nfM2{Bidx}=zeros(size(estField,1),size(estField,2));
        for x=1:size(estField,1)
            for y=1:size(estField,2)
                if isfield(estField{x,y},'nf')
                    nf=estField{x,y}.nf{Bidx}; nf=nf/norm(nf);
                    nfM2{Bidx}(x,y)=atan(nf(3)/sqrt(nf(1)^2+nf(2)^2))/pi*180;
                else
                    nfM2{Bidx}(x,y)=NaN;
                end
            end
        end
       
        figure; imagesc(binX,binY,nfM2{Bidx}');
        xlabel('coil x (m)'); ylabel('coil y (m)'); 
        colormap( [0 0 0; parula(256)] );
    %     caxis( [-0.12 0.6] );
        c=colorbar;
        c.Label.String='degree';
        c.Label.FontSize=12;
        
        saveas(gcf, [outputFolder fieldName{Bidx} '_nfM2.png'])
        saveas(gcf, [outputFolder fieldName{Bidx} '_nfM2'], 'epsc')
        saveas(gcf, [outputFolder fieldName{Bidx} '_nfM2.fig'])
    end



    for Bidx=fields
        nfX{Bidx}=zeros(size(estField,1),size(estField,2));
        nfY{Bidx}=zeros(size(estField,1),size(estField,2));
        nfZ{Bidx}=zeros(size(estField,1),size(estField,2));
        
        for x=1:size(estField,1)
            for y=1:size(estField,2)
                if isfield(estField{x,y},'nf')
                    nfX{Bidx}(x,y)=estField{x,y}.nf{Bidx}(1);
                    nfY{Bidx}(x,y)=estField{x,y}.nf{Bidx}(2);
                    nfZ{Bidx}(x,y)=estField{x,y}.nf{Bidx}(3);  
                else
                    nfX{Bidx}(x,y)=NaN;
                    nfY{Bidx}(x,y)=NaN;
                    nfZ{Bidx}(x,y)=NaN;
                end
            end
        end
       
        figure; imagesc(binX,binY,nfX{Bidx}');
        xlabel('coil x (m)'); ylabel('coil y (m)'); 
        colormap( [0 0 0; parula(256)] );
    %     caxis( [-0.12 0.6] );
        colorbar
        
        saveas(gcf, [outputFolder fieldName{Bidx} '_nfX.png'])
        saveas(gcf, [outputFolder fieldName{Bidx} '_nfX'], 'epsc')
        saveas(gcf, [outputFolder fieldName{Bidx} '_nfX.fig'])
        
        
        figure; imagesc(binX,binY,nfY{Bidx}');
        xlabel('coil x (m)'); ylabel('coil y (m)'); 
        colormap( [0 0 0; parula(256)] );
    %     caxis( [-0.12 0.6] );
        colorbar
        saveas(gcf, [outputFolder fieldName{Bidx} '_nfY.png'])
        saveas(gcf, [outputFolder fieldName{Bidx} '_nfY'], 'epsc')
        saveas(gcf, [outputFolder fieldName{Bidx} '_nfY.fig'])
        
        
        figure; imagesc(binX,binY,nfZ{Bidx}');
        xlabel('coil x (m)'); ylabel('coil y (m)'); 
        colormap( [0 0 0; parula(256)] );
    %     caxis( [-0.12 0.6] );
        colorbar
        saveas(gcf, [outputFolder fieldName{Bidx} '_nfZ.png'])
        saveas(gcf, [outputFolder fieldName{Bidx} '_nfZ'], 'epsc')
        saveas(gcf, [outputFolder fieldName{Bidx} '_nfZ.fig'])
    end


    HM=zeros(size(estField,1),size(estField,2));
    for x=1:size(estField,1)
        for y=1:size(estField,2)
            if isfield(estField{x,y},'nf')
                HM(x,y)=estField{x,y}.center(3);
            else
                HM(x,y)=NaN;
            end
        end
    end

    figure; imagesc(binX,binY,HM');
    xlabel('coil x (m)'); ylabel('coil y (m)'); 
    colormap( [0 0 0; parula(256)] );
    %     caxis( [-0.12 0.6] );
    c=colorbar;
    c.Label.String='height (m)';
    c.Label.FontSize=12;
    saveas(gcf, [outputFolder 'height.png'])
    saveas(gcf, [outputFolder 'height'], 'epsc')  
    saveas(gcf, [outputFolder 'height.fig'])


    %save([direct 'estField_' sessionNames{i} '.mat'],'estField','BM','nfM1','nfM2','nfX','nfY','nfZ')
