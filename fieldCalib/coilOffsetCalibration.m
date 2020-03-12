clear; close all;
addpath('../tools/');
rng('shuffle');

direct='Z:\fieldCalibrate\data\24-Feb-2020\coilCalib';

R = [0 0 -1; -1 0 0; 0 1 0]'; % transform from room to optitrack 

load([direct, '/dataBackup.mat']);
coil=coilData.sig_syncR{2}(:,2:end); coil(1,:)=-coil(1,:);
qV=quaternion(optiData.data{1}.q(:,1:end-1));

sliderPos=R\optiData.data{1}.pos(:,1:end-1);
coilPos=sliderPos+R\qV.RotateVector(0.065*R*[0 0 1]');
% trimIdx=find(vecnorm(coilPos-mean(coilPos,2))<0.015);
trimIdx=1200:5.035E4;
coilPos=coilPos(:,trimIdx);
coil=coil(:,trimIdx);
qV=qV(trimIdx);

    
figure; plot(sliderPos(1,:),sliderPos(2,:))
hold on; plot(coilPos(1,:),coilPos(2,:))

alpha=45; theta=45;
coil2object=[ cosd(theta) * [cosd(alpha), sind(alpha)], sind(theta) ];
nc=R\qV.RotateVector(R*coil2object'); 

figure; 
for i=1:3
    subplot(3,1,i); hold on;
    plot(-coil(i,:));
    plot(nc(i,:));
end



for ApplyCoilAngPars = [1]
    fprintf( 'ApplyCoilAngPars: %d\n', ApplyCoilAngPars );


    for iTest = 10 : -1 : 1
        fprintf( '\tiTest: %d\n', iTest );
        trainIdx =sort( randsample( size(coil,2), round( size(coil,2) * 0.75 ) ) );
        trainData.coil = coil(:,trainIdx);
        trainData.qV = qV(trainIdx);
        testIdx = true( 1, size(coil,2) );
        testIdx(trainIdx) = false;
        testData.coil = coil(:,testIdx);
        testData.qV = qV(testIdx);
        % testData = trainData;


        %% fitting
        tic;
        for Bidx = 1 : 3 % three fields
            fprintf( '\tField: %d\n', Bidx );

            % local field least square fitting
            for i = 3 : -1 : 1 % Find N local minmum points and test to find out the best among them: 1. find out global minimum. 2. to aviod outliers
                fprintf( '\t\tItr: %d...\n', i );

                randIdx = randsample( size(trainData.coil,2), round( size(trainData.coil,2) * 0.75 ) );

                % pars = [Bx, By, Bz, alpha, theta]
                % Bn = [Bx, By, Bz]
                % testing coil angle in slider coordinate:
                %   alpha: atan(y/x)
                %   theta: atan(z/sqrt(x^2+y^2)) )
                if ApplyCoilAngPars
                    f = @( pars ) costFunc( pars(1:3), pars(4), pars(5), trainData.coil(Bidx,randIdx), trainData.qV(randIdx), R );
                    pars = fmincon( f, [ rand(1,3), (rand(1,2)*10-5)+45 ], [], [], [], [], [-2, -2, -2, -180, -180 ], [2, 2, 2, 180, 180 ], [], optimoptions( 'fmincon', 'Display', 'off' ) );
                else
                    f = @( pars ) costFunc( pars(1:3), 44.9, 44.3, trainData.coil(Bidx,randIdx), trainData.qV(randIdx), R );
%                        f = @( pars ) costFunc( pars(1:3), 45, 45, trainData.coil(Bidx,randIdx), trainData.qV(randIdx), R );
                    pars = fmincon( f, rand(1,3), [], [], [], [], [-2, -2, -2 ], [2, 2, 2 ], [], optimoptions( 'fmincon', 'Display', 'off' ) );
                    pars(4:5) = [44.9, 44.3];
                end

                B = norm( pars(1:3) );  BV(i) = B;
                nf = pars(1:3)'/B; nfV(:,i) = nf;
                alphaV(i) = pars(4);
                thetaV(i) = pars(5);

                % testing with dev data
                devIdx = true( 1, size(trainData.coil,2) );
                devIdx(randIdx) = false;
                % devIdx = randIdx;
                costV(i) = costFunc( pars(1:3), pars(4), pars(5), trainData.coil(Bidx,devIdx), trainData.qV(devIdx), R );
            end

            % find the solution achieves the lowest cost which is the
            % global minimum solution
            [tmp,minIdx]=min(costV);

            estField.BV{Bidx} = BV;
            estField.nfV{Bidx} = nfV;
            estField.B{Bidx} = BV(minIdx);
            estField.nf{Bidx} = nfV(:,minIdx);
            estField.coilAngle{Bidx} = [alphaV(minIdx), thetaV(minIdx)];
            estField.coilAngleV{Bidx} = [alphaV; thetaV];
            estField.costV{Bidx} = costV;
        end
        toc;

        %% testing
        for Bidx = 1 : 3
            fprintf( 'Bidx: %d\tCost on test data: %.8f\n', Bidx, costFunc( estField.nf{Bidx}' * estField.B{Bidx}, estField.coilAngle{Bidx}(1), estField.coilAngle{Bidx}(2), testData.coil(Bidx), testData.qV, R));
        end

        coilV = ( [estField.nf{:}]' .* repmat( [estField.B{:}]', 1, 3 ) )^(-1) * testData.coil;
        coilV = coilV ./ repmat( sqrt( sum( coilV.^2, 1 ) ), 3, 1 );
        for Bidx = 1 : 3
            % coil vector in space based on coil angle fitted with each field
            optiV{Bidx} = testData.qV.RotateVector( R * [ cosd(estField.coilAngle{Bidx}(2)) * [cosd(estField.coilAngle{Bidx}(1)), sind(estField.coilAngle{Bidx}(1))], sind(estField.coilAngle{Bidx}(2)) ]' );
        end

        hFig1 = figure( 'NumberTitle', 'off', 'name', sprintf( 'Calibration Considering Coil Angle on Slider | ApplyCoilAngPars: %d | Coil Orientation Prediction Error | Testing Data | iTest: %d', ApplyCoilAngPars, iTest ) );
        pause(0.1);
        jf = get(handle(gcf),'javaframe');
        jf.setMaximized(1);
        pause(0.5);
        hFig2 = figure( 'NumberTitle', 'off', 'name', sprintf( 'Calibration Considering Coil Angle on Slider | ApplyCoilAngPars : %d | Coil Orientation Prediction Error VS Orientation | Testing Data | iTest: %d', ApplyCoilAngPars, iTest ) );
        pause(0.1);
        jf = get(handle(gcf),'javaframe');
        jf.setMaximized(1);
        pause(0.5);
        clear h;
        for( Bidx = 1 : 3 )
            v1 = coilV;
            v2 = optiV{Bidx};

            figure(hFig1);
            subplot( 1, 3, Bidx ); hold on;
            ax = plotyy( 0, 0, 0, 0 );
            set( ax, 'NextPlot', 'add' );
            ax(1).Children.delete;
            ax(2).Children.delete;

            dAng = acosd( round( sum(  v1.*v2, 1 ) ./ sqrt( sum( v1.^2, 1 ) ) ./ sqrt( sum( v2.^2, 1 ) ) * 100000000 ) / 100000000 ) * 60;  % arcmin
            h(4) = plot( ax(1), dAng, 'color', 'k', 'LineWidth', 2, 'DisplayName', 'Angle Diff' );

            names = {'x', 'y', 'z'};
            colors = {'b', 'r', 'g'};
            for( k = 1 : 3 )
                h(k) = plot( ax(2), v2(k,:) - v1(k,:), 'color', colors{k}, 'LineWidth', 2, 'DisplayName', ['Vec ', names{k}, ' Diff'] );
            end

            title( sprintf( 'Coil Angle Fitted From Field %d', Bidx ), 'interpreter', 'none' );
            set( ax, 'XLim', [0 size(v1,2)], 'FontSize', 20, 'LineWidth', 2 );
            % Y = [min(dAng), max(dAng)]; Y = Y + [-0.2 0.2] * diff(Y);
            Y = mean(dAng) + [-4 4] * std(dAng);    Y(1) = max( 0, Y(1) );
            set( ax(1), 'YLim', Y, 'YTick', floor(Y(1)*100)/100 : round(diff(Y)/4*100)/100 : ceil(Y(2)*100)/100 );
            % Y = [min(v2(:)-v1(:)), max(v2(:)-v1(:))]; Y = Y + [-0.2 0.2] * diff(Y);
            Y = mean(v2(:)-v1(:)) + [-4 4] * std(v2(:)-v1(:));
            set( ax(2), 'YLim', Y, 'YTick', floor(Y(1)*1000)/1000 : round(diff(Y)/4*1000)/1000 : ceil(Y(2)*1000)/1000 );
            ax(1).YLabel.String = 'Angle difference (arcmin)';
            ax(2).YLabel.String = 'Vector difference';


            figure(hFig2);
            names = {'x', 'y', 'z'};
            for iV = 1 : 3
                subplot( 3, 3, (iV-1)*3+Bidx );
                plot( v2(iV,:), dAng, '.', 'MarkerSize', 5 );
                Y = mean(dAng) + [-4 4] * std(dAng);    Y(1) = max( 0, Y(1) );
                set( gca, 'YLim', Y, 'FontSize', 20, 'LineWidth', 2 );     Y(1) = max( 0, Y(1) );
                xlabel( ['Opti coil ' names{iV}] );
                ylabel( 'Angular error (arcmin)' );
                title( sprintf( 'Field %d', Bidx ) );
            end
            % quiver3( 1:size(v2,2), zeros(1,size(v2,2)), zeros(1,size(v2,2)), v2(1,:).*dAng, v2(2,:).*dAng, v2(3,:).*dAng, 'color', 'r', 'LineWidth', 2, 'MaxHeadSize', 0, 'AutoScale', 'off', 'AutoScaleFactor', 1 );

        end
        set( legend(h), 'location', 'NorthEast' );
        mkdir( fullfile( direct, sprintf( 'CoilAngCal%d_Figures', ApplyCoilAngPars ) ) );
        saveas( hFig1, fullfile( direct, sprintf( 'CoilAngCal%d_Figures', ApplyCoilAngPars ), sprintf( 'CoilAngCal%d_coil_orientation_prediction_error_TestData_iTest%d.fig', ApplyCoilAngPars, iTest ) ) );
        saveas( hFig1, fullfile( direct, sprintf( 'CoilAngCal%d_Figures', ApplyCoilAngPars ), sprintf( 'CoilAngCal%d_coil_orientation_prediction_error_TestData_iTest%d.png', ApplyCoilAngPars, iTest ) ) );
        saveas( hFig2, fullfile( direct, sprintf( 'CoilAngCal%d_Figures', ApplyCoilAngPars ), sprintf( 'CoilAngCal%d_coil_orientation_prediction_error_VS_orientation_TestData_iTest%d.fig', ApplyCoilAngPars, iTest ) ) );
        saveas( hFig2, fullfile( direct, sprintf( 'CoilAngCal%d_Figures', ApplyCoilAngPars ), sprintf( 'CoilAngCal%d_coil_orientation_prediction_error_VS_orientation_TestData_iTest%d.png', ApplyCoilAngPars, iTest ) ) );

        for Bidx = 1 : 3
            ncV0{Bidx} = qV.RotateVector( R * [0.5 0.5 sqrt(2)/2]' );
            ncV{Bidx} = qV.RotateVector( R * [ cosd(estField.coilAngle{Bidx}(2)) * [cosd(estField.coilAngle{Bidx}(1)), sind(estField.coilAngle{Bidx}(1))], sind(estField.coilAngle{Bidx}(2)) ]' );
        end
        set( figure, 'NumberTitle', 'off', 'name', sprintf( 'Calibration Considering Coil Angle on Slider | ApplyCoilAngPars: %d | Coil Output | All Data | iTest: %d', ApplyCoilAngPars, iTest ) );
        pause(0.1);
        jf = get(handle(gcf),'javaframe');
        jf.setMaximized(1);
        pause(0.5);
        clear h;
        for BI=1:3
            for offIdx=1:3
                subplot(3,3,(offIdx-1)*3+BI); hold on;
                h(2) = plot( estField.nf{BI}' * ncV0{offIdx}, coil(BI,:), 'b.', 'MarkerSize', 1, 'DisplayName', 'Assumed Coil Angle' );
                h(1) = plot( estField.nf{BI}' * ncV{offIdx}, coil(BI,:), 'r.', 'MarkerSize', 1, 'DisplayName', 'Fitted Coil Angle' );
                X = get( gca, 'XLim' ); Y = get( gca, 'YLim' );

                [r pVal] = corrcoef( estField.nf{BI}' * ncV0{offIdx}, coil(BI,:) );
                if( size(r,2) == 1 ) r(2) = r(1); end
                if( size(pVal,2) == 1) pVal(2) = pVal(1); end
                text( X(2)*0.999 + X(1)*0.001, Y(1)*0.95 + Y(2)*0.05, sprintf( '$\\mathbf{R^2=%.6f}$, $\\mathbf{p=%.6f}$', r(2)^2, pVal(2) ), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 18, 'color', 'b', 'Interpreter', 'LaTex' );

                [r pVal] = corrcoef( estField.nf{BI}' * ncV{offIdx}, coil(BI,:) );
                if( size(r,2) == 1 ) r(2) = r(1); end
                if( size(pVal,2) == 1) pVal(2) = pVal(1); end
                text( X(2)*0.995 + X(1)*0.005, Y(1)*0.8 + Y(2)*0.2, sprintf( '$\\mathbf{R^2=%.6f}$ $\\mathbf{p=%.6f}$', r(2)^2, pVal(2) ), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 18, 'color', 'r', 'Interpreter', 'LaTex' );

                xlabel( 'Measured coil output' );
                ylabel( 'Predicted coil output' );
                title( sprintf( 'Field %d, CoilAngle %d', BI, offIdx ) );
                set( gca, 'XLim', X, 'YLim', Y, 'FontSize', 20, 'LineWidth', 2 );
            end
        end
        set( legend(h), 'location', 'NorthEast' );
        saveas( gcf, fullfile( direct, sprintf( 'CoilAngCal%d_Figures', ApplyCoilAngPars ), sprintf( 'CoilAngCal%d_coil_output_prediction_error_AllData_iTest%d.fig', ApplyCoilAngPars, iTest ) ) );
        saveas( gcf, fullfile( direct, sprintf( 'CoilAngCal%d_Figures', ApplyCoilAngPars ), sprintf( 'CoilAngCal%d_coil_output_prediction_error_AllData_iTest%d.png', ApplyCoilAngPars, iTest ) ) );


        estField_itr(iTest) = estField;
    end

    close all;
    save( fullfile( direct, sprintf( 'estFieldCoilAng%d.mat', ApplyCoilAngPars ) ), 'estField_itr' );
end



%%
function cost = costFunc( Bn, alpha, theta, coil, qV,R )

    cost = mean( ( coil - Bn * qV.RotateVector( R * [ cosd(theta) * [cosd(alpha), sind(alpha)], sind(theta) ]'  ) ).^2 );
end