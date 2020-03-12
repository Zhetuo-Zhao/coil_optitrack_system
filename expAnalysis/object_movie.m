function object_movie( objs, head, eyes, tagData, R, init_idx )
    for( iObj = 1 : length(objs) )
        if( isfield( objs{iObj}, 'offsetLoc' ) )
            objs{iObj} = rmfield( objs{iObj}, 'offsetLoc' );
        end
        if( isfield( objs{iObj}, 'vector' ) )
            objs{iObj} = rmfield( objs{iObj}, 'vector' );
        end
    end



    NFrames = length(objs{1}.error);
    for iObj = 1 : length(objs) 
        objs{iObj}.pos = R * objs{iObj}.pos(:,1:NFrames);
        objs{iObj}.q = objs{iObj}.q(:,1:NFrames);
        objs{iObj}.error = objs{iObj}.error(1:NFrames);

        for( iMarker = 1 : length(objs{iObj}.marker) )
            objs{iObj}.markerPos{iMarker} = R * objs{iObj}.marker{iMarker}.pos(:,1:NFrames);
            objs{iObj}.markerErr{iMarker} = objs{iObj}.marker{iMarker}.err(1:NFrames);
        end
        objs{iObj}.markerPos = reshape( [objs{iObj}.markerPos{:}], 3, NFrames, [] );
        objs{iObj}.markerErr = cat( 1, objs{iObj}.markerErr{:} );

        if( isfield( objs{iObj}, 'offsetLoc' ) )
            for( i = 1 : length(objs{iObj}.offsetLoc) )
                objs{iObj}.offsetLoc{i} = R * objs{iObj}.offsetLoc{i}(:,1:NFrames);
            end
            objs{iObj}.offsetLoc = reshape( [objs{iObj}.offsetLoc{:}], 3, NFrames, [] );
        end
        
        if( isfield( objs{iObj}, 'vector' ) )
            for( i = 1 : length(objs{iObj}.vector) )
                objs{iObj}.vector{i} = R * objs{iObj}.vector{i}(:,1:NFrames);
            end
            objs{iObj}.vector = reshape( [objs{iObj}.vector{:}], 3, NFrames, [] );
        end
    end
    fields = fieldnames(tagData);
    for( iField = 1 : length(fields) )
        tagData.(fields{iField})( tagData.(fields{iField}) > NFrames ) = [];
    end

    frameRate = 240;
    NFrames = length(objs{1}.pos);
    startFrame = 1;
    endFrame = NFrames;
    iFrame = mod( init_idx-1, NFrames ) + 1;

    set( figure, 'color', 'w', 'WindowKeyPressFcn', @WindowKeyPressFcn,...
                               'WindowKeyReleaseFcn', @WindowKeyReleaseFcn,...
                               'WindowButtonDownFcn', @WindowButtonDownFcn,...
                               'WindowButtonMotionFcn', @WindowButtonMotionFcn,...
                               'WindowButtonUpFcn', @WindowButtonUpFcn );
    pause(0.1);
    jf = get(handle(gcf),'javaframe');
    jf.setMaximized(1);
    pause(0.5);
    ButtonDown = false;
    FontSize = 16;

    %% objects panel   
    % backgroud
    set( axes( 'position', [0, 0, 0.55, 0.9] ), 'color', 'k', 'XColor', 'k', 'XTick', [], 'YColor', 'k', 'YTick', [], 'ZColor', 'k', 'XTick', [], 'NextPlot', 'add', 'XLim', [1-NFrames*0.05, NFrames*1.05], 'YLim', [0 1] );

    % time bar
    set( axes( 'position', [0, 0.9, 0.55, 0.1] ), 'color', 'k', 'XColor', 'k', 'XTick', [], 'YColor', 'k', 'YTick', [], 'ZColor', 'k', 'XTick', [], 'NextPlot', 'add', 'XLim', [1-NFrames*0.05, NFrames*1.05], 'YLim', [0 1] );
    hAxis.timeBar = gca;
    yOffset = 0.5; yHeight = 0.2;
    hAxis.offTimeBars(2) = plot( [1,1] * NFrames, [1,1]*yOffset, 'color', [0 0.3 0], 'LineWidth', 5 );
    hAxis.offTimeBars(1) = plot( [1,1], [1,1]*yOffset, 'color', [0 0.3 0], 'LineWidth', 5 );
    hAxis.onTimeBar = plot( [1 NFrames], [1,1]*yOffset, 'g', 'LineWidth', 5 );
    
    hAxis.timeRanges(4) = text( endFrame, 1, sprintf( '%.1fs', (endFrame-1)/frameRate ), 'color', 'r', 'LineWidth', 2, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top', 'FontSize', FontSize );
    hAxis.timeRanges(3) = plot( [1,1]*endFrame, yOffset + [-1,1]*yHeight, '-r', 'LineWidth', 2 );
    hAxis.timeRanges(2) = text( startFrame, 1, sprintf( '%.1fs', (startFrame-1)/frameRate ), 'color', 'r', 'LineWidth', 2, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'FontSize', FontSize );
    hAxis.timeRanges(1) = plot( [1,1]*startFrame, yOffset + [-1,1]*yHeight, '-r', 'LineWidth', 2 );
    
    hAxis.iFrames = text( iFrame, yOffset-yHeight, sprintf( '%.2fs', (iFrame-1)/frameRate ), 'color', 'w', 'LineWidth', 2, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'FontSize', FontSize );
    hAxis.iFrames(2) = plot( [1,1]*iFrame, yOffset + [-1,1]*yHeight, '-w', 'LineWidth', 2 );

    selectMargin = 0.004;
    hAxis.selector = plot( -NFrames + [-1, 1, 1, -1, -1]*selectMargin*NFrames, yOffset + [-1, -1, 1, 1, -1] * yHeight*1.1, '-.', 'color', [0.7, 0.7, 0.7], 'LineWidth', 1 );
    selectedLine = 'iFrame';
    keyPressed = 'none';

    % objects
    hAxis.objs = axes( 'position', [0.045, 0.0735, 0.47, 0.832] );
    set( gca, 'NextPlot', 'add', 'FontSize', FontSize, 'LineWidth', 2, 'color', 'k', 'XColor', 'w', 'YColor', 'w', 'ZColor', 'w' );
    grid on; view(3);
    xlabel('x(m)'); ylabel('y(m)'); zlabel('z(m)');
    DisplayObjects();
    DisplayEyes();

    %% tagging plots
    nPanels = 4;
    for iPanel = nPanels : -1 : 1
        hAxis.curves(iPanel) = axes( 'position', [0.59, (1-iPanel/nPanels)*0.95 + 0.07, 0.405, 0.95/nPanels-0.03 ] );
    end
    set( hAxis.curves, 'FontSize', FontSize, 'LineWidth', 2, 'NextPlot', 'add' );
    hAxis.curves(end).XLabel.String = 'Time (s)';
    linkaxes( hAxis.curves, 'x' );

    if( ~isempty(head) )
        axes(hAxis.curves(1)); cla;
        PlotTagging( (0:NFrames-1)/frameRate, head.relativePos, {'x', 'y', 'z'}, 'Head Position', 'Position (m)', tagData );
        axes(hAxis.curves(2)); cla;
        PlotTagging( (0:NFrames-1)/frameRate, head.Euler_head, {'yaw', 'pitch', 'roll'}, 'Head Rotation', 'Angle (deg)', tagData );
    end
    
    

    UpdateFrame();
    UpdateTimeRange();
    
    

    function WindowKeyPressFcn( h, evnt )

        needUpdate = false;

        switch evnt.Key
            case 'leftarrow'
                step = -1;
                needUpdate = true;

            case 'rightarrow'
                step = 1;
                needUpdate = true;

            case 'downarrow'
                step = -10;
                needUpdate = true;

            case 'uparrow'
                step = 10;
                needUpdate = true;

            case 'hyphen'
                step = -100;
                needUpdate = true;

            case 'equal'
                step = 100;
                needUpdate = true;

            case 'leftbracket'
                step = -1000;
                needUpdate = true;

            case 'rightbracket'
                step = 1000;
                needUpdate = true;
            
            otherwise
                step = 0;
                keyPressed = evnt.Key;

        end

        if( ~strcmp( selectedLine, 'startFrame' ) && ~strcmp( selectedLine, 'iFrame' ) && ~strcmp( selectedLine, 'endFrame' ) )
            return;
        end

        if(needUpdate)
            if( step < 0 )
                eval( sprintf( '%s = max( %s + %d, 1 );', selectedLine, selectedLine, step ) );
            elseif( step > 0 )
                eval( sprintf( '%s = min( %s + %d, NFrames );', selectedLine, selectedLine, step ) );
            end

            if( strcmp( selectedLine, 'iFrame' ) )
                if( iFrame < startFrame ) iFrame = startFrame; end
                if( iFrame > endFrame ) iFrame = endFrame; end
                UpdateFrame();
            else
                if( startFrame + selectMargin*NFrames >= endFrame )
                    if( strcmp( selectedLine, 'startFrame' ) )
                        startFrame = endFrame - round( 2 * selectMargin * NFrames ) - 1;
                    else
                        endFrame = startFrame + round( 2 * selectMargin * NFrames ) + 1;
                    end
                end
                if( iFrame > endFrame )
                    iFrame = endFrame;
                    UpdateFrame();
                end
                if( iFrame < startFrame )
                    iFrame = startFrame;
                    UpdateFrame();
                end
                UpdateTimeRange();
            end

            if( step )
                eval( sprintf( 'hAxis.selector.XData = hAxis.selector.XData - mean(hAxis.selector.XData) + %s;', selectedLine ) );
            end
        end

    end

    function WindowKeyReleaseFcn( hFig, evnt )
        keyPressed = 'none';
    end


    function WindowButtonDownFcn( hFig, evnt )
        if( ~exist('hAxis') || ~isfield( hAxis, 'timeRanges' ) || ~isfield( hAxis, 'timeBar' ) )
            return;
        end

        if( strcmp( hFig.SelectionType, 'normal' ) )    % left button down
            selectedLine = HoveredLine();
            switch(selectedLine)
                case 'startFrame'
                    hAxis.selector.XData = hAxis.selector.XData - mean(hAxis.selector.XData) + startFrame;
                case 'iFrame'
                    hAxis.selector.XData = hAxis.selector.XData - mean(hAxis.selector.XData) + iFrame;
                case 'endFrame'
                    hAxis.selector.XData = hAxis.selector.XData - mean(hAxis.selector.XData) + endFrame;
                otherwise
                    hAxis.selector.XData(:) = hAxis.selector.XData - mean(hAxis.selector.XData) - NFrames;
            end

            ButtonDown = true;
        end
    end


    function WindowButtonMotionFcn( hFig, evnt )
        if( ~exist('hAxis') || ~isfield( hAxis, 'timeRanges' ) || ~isfield( hAxis, 'timeBar' ) )
            return;
        end

        if(ButtonDown)
            if( strcmp( selectedLine, 'iFrame' ) )
                hFig.Pointer = 'left';
                iFrame = round( hAxis.timeBar.CurrentPoint(1) );
                if( iFrame < startFrame ) iFrame = startFrame; end
                if( iFrame > endFrame ) iFrame = endFrame; end
                hAxis.selector.XData = hAxis.selector.XData - mean(hAxis.selector.XData) + iFrame;
                UpdateFrame();
            
            elseif( strcmp( selectedLine, 'startFrame' ) || strcmp( selectedLine, 'endFrame' ) )
                hFig.Pointer = 'left';
                eval( sprintf( '%s = round( hAxis.timeBar.CurrentPoint(1) );', selectedLine ) );
                eval( sprintf( 'if( %s < 1 ) %s = 1; end', selectedLine, selectedLine ) );
                eval( sprintf( 'if( %s > NFrames ) %s = NFrames; end', selectedLine, selectedLine ) );
                if( startFrame + selectMargin*NFrames >= endFrame )
                    if( strcmp( selectedLine, 'startFrame' ) )
                        startFrame = endFrame - round( 2 * selectMargin * NFrames ) - 1;
                    else
                        endFrame = startFrame + round( 2 * selectMargin * NFrames ) + 1;
                    end
                end
                if( iFrame > endFrame )
                    iFrame = endFrame;
                    UpdateFrame();
                end
                if( iFrame < startFrame )
                    iFrame = startFrame;
                    UpdateFrame();
                end
                hAxis.selector.XData = hAxis.selector.XData - mean(hAxis.selector.XData) + eval(selectedLine);
                UpdateTimeRange();
            
            else
                hFig.Pointer = 'arrow';
            end
        else
            if( ~strcmp( HoveredLine(), 'none' ) )
                hFig.Pointer = 'left';
            else
                hFig.Pointer = 'arrow';
            end
        end
    end

    function WindowButtonUpFcn( hFig, evnt )
        if( ~exist('hAxis') || ~isfield( hAxis, 'timeRanges' ) || ~isfield( hAxis, 'timeBar' ) )
            return;
        end

        if( strcmp( hFig.SelectionType, 'normal' ) )
            ButtonDown = false;
        end

    end

    function hovered = HoveredLine()
        hovered = 'none';
        hovereds = false(1,3);
        
        if( abs( hAxis.timeBar.CurrentPoint(1,1) - startFrame ) / NFrames < selectMargin && abs( hAxis.timeBar.CurrentPoint(1,2) - yOffset ) < yHeight*(1+selectMargin) )
            hovereds(1) = true;
            hovered = 'startFrame';
        end
        if( abs( hAxis.timeBar.CurrentPoint(1,1) - iFrame ) / NFrames < selectMargin && abs( hAxis.timeBar.CurrentPoint(1,2) - yOffset ) < yHeight*(1+selectMargin) )
            hovereds(2) = true;
            hovered = 'iFrame';
        end
        if( abs( hAxis.timeBar.CurrentPoint(1,1) - endFrame ) / NFrames < selectMargin && abs( hAxis.timeBar.CurrentPoint(1,2) - yOffset ) < yHeight*(1+selectMargin) )
            hovereds(3) = true;
            hovered = 'endFrame';
        end

        if( all(hovereds) )
            if( startFrame-1 > NFrames - endFrame )
                hovered = 'startFrame';
            else
                hovered = 'endFrame';
            end

        elseif( sum(hovereds) == 2 )
            hovered = 'iFrame';
        end

        if( strcmp( keyPressed, 'a' ) && hovereds(1) )
            hovered = 'startFrame';
        elseif( strcmp( keyPressed, 's' ) && hovereds(2) )
            hovered = 'iFrame';
        elseif( strcmp( keyPressed, 'd' ) && hovereds(3) )
            hovered = 'endFrame';
        end
    end


    function DisplayObjects()
        colors = { 'r',         'g',            'y',        'm',        'c',        'b';
                   [1 0.5 0.5], [0.5 1 0.5],    [1 1 0.5],  [1 0.5 1],  [0.5 1 1],  [0.5 0.5 1] };
        for iObj = 1 : length(objs)
            %% display pivot (position of object)
            pivot = objs{iObj}.pos(:,iFrame);
            hAxis.pivots(iObj) = scatter3( hAxis.objs, pivot(1), pivot(2), pivot(3), 'LineWidth', 2, 'MarkerEdgeColor', colors{ 1, mod( iObj-1, length(objs) ) + 1 } );

            %% display markers
            markersM = reshape( objs{iObj}.markerPos(:,iFrame,:), 3, [] );
            hAxis.markers(iObj) = scatter3( hAxis.objs, markersM(1,:), markersM(2,:), markersM(3,:), 'LineWidth', 2, 'MarkerEdgeColor', colors{ 2, mod( iObj-1, length(objs) ) + 1 } );
            for( iMarker = 1 : size(markersM,2) )
                hAxis.markersTxt{iObj}(iMarker) = text( hAxis.objs, markersM(1,iMarker), markersM(2,iMarker), markersM(3,iMarker), sprintf( 'p%d', iMarker ), 'FontSize', 14, 'color', [0.7 0.7 0.7] );
            end
            for( iMarker = 1 : size(markersM,2)-1 )
                for( jMarker = iMarker+1 : size(markersM,2) )
                    hAxis.marker2marker{iObj}(iMarker,jMarker) = plot3( hAxis.objs, markersM(1, [iMarker,jMarker]), markersM(2, [iMarker,jMarker]), markersM(3, [iMarker,jMarker]), 'LineWidth', 1, 'color', colors{ 2, mod( iObj-1, length(objs) ) + 1 } );
                end
            end
            % connect to pivot
            for( iMarker = 1 : size(markersM,2) )
                hAxis.pivot2marker{iObj}(iMarker) = plot3( hAxis.objs, [pivot(1), markersM(1,iMarker)], [pivot(2), markersM(2,iMarker)], [pivot(3), markersM(3,iMarker)], '--', 'LineWidth', 1, 'color', colors{ 1, mod( iObj-1, length(objs) ) + 1 } );
            end
            hAxis.names(iObj) = text( hAxis.objs, pivot(1), pivot(2), max(markersM(3,:)), objs{iObj}.name, 'FontSize', FontSize, 'color', colors{ 1, mod( iObj-1, length(objs) ) + 1 }, 'VerticalAlignment', 'bottom' );
            
            %% display offsets
            if( isfield( objs{iObj}, 'offsetLoc' ) )
                offsetM = reshape( objs{iObj}.offsetLoc(:,iFrame,:), 3, [] );
                hAxis.offsets(iObj) = scatter3( hAxis.objs, offsetM(1,:), offsetM(2,:), offsetM(3,:), 'LineWidth', 2, 'MarkerEdgeColor', colors{ 2, mod( iObj-1, length(objs) ) + 1 } );
                for( i = 1 : size(offsetM,2) )
                    hAxis.offsetsTxt{iObj}(i) = text( hAxis.objs, offsetM(1,i), offsetM(2,i), offsetM(3,i), sprintf( 'o%d', i ), 'FontSize', 14, 'color', [0.7 0.7 0.7] );
                end
            end
            
            %% display vectors
            if isfield( objs{iObj}, 'vector' )
                vec = reshape( [objs{iObj}.vector(:,iFrame,:)], 3, [] );
                hAxis.vectors(iObj) = quiver3( hAxis.objs, repmat( pivot(1), 1, N ), repmat( pivot(2), 1, N ), repmat( pivot(3), 1, N ), vec(1,:), vec(2,:), vec(3,:), 'color', colors{ 2, mod( iObj-1, length(objs) ) + 1 } );
            end
        end
    end


    function DisplayEyes()
        for( iEye = 1 : length(eyes.pos) )
            hAxis.eyePos(iEye,1) = plot3( hAxis.objs, eyes.pos{iEye}(1,iFrame), eyes.pos{iEye}(2,iFrame), eyes.pos{iEye}(3,iFrame), 'ow', 'MarkerSize', 5, 'LineWidth', 4 );
            hAxis.eyePos(iEye,2) = plot3( hAxis.objs, eyes.pos{iEye}(1,iFrame), eyes.pos{iEye}(2,iFrame), eyes.pos{iEye}(3,iFrame), 'ow', 'MarkerSize', 15, 'LineWidth', 4 );
        
            if( isfield( eyes, 'sightVec' ) )
                sightVec = eyes.sightVec{iEye}(:,iFrame) * 3;
                hAxis.eyeVec(iEye) = quiver3( hAxis.objs, eyes.pos{iEye}(1,iFrame), eyes.pos{iEye}(2,iFrame), eyes.pos{iEye}(3,iFrame), sightVec(1), sightVec(2), sightVec(3), '--w', 'LineWidth', 2 );
            end
        end
    end


    function PlotTagging( t, inputData, dataLegends, inputName, yLabel, tagData )

        h = plot( t, inputData', 'LineWidth', 2 );
        [h.DisplayName] = dataLegends{:};

        yLimits = [min(inputData(:)) max(inputData(:))] * [ 1.1, -0.1; -0.1, 1.1 ]';
        yLim1 = mean(inputData(:)) + std(inputData(:)) * [-4 4];
        yLim2 = [min(inputData(:)), max(inputData(:))];
        yLim = [ max( yLim1(:,1), yLim2(:,1) ), min( yLim1(:,2), yLim2(:,2) ) ];
        if( yLim(1) == yLim(2) )
            yLim = [yLim(1)-1, yLim(2)+1];
        end
        yLimits = yLim;

        for i = 1 : length(tagData.eyeProbe)
            xt = t(tagData.eyeProbe(i));
            h(4) = line( [xt xt], yLimits, 'color', 'b', 'DisplayName', 'iProbe' );
        end

        for i = 1 : length(tagData.calib)
            xt = t(tagData.calib(i));
            h(5) = line( [xt xt], yLimits, 'color', 'y', 'DisplayName', 'calib' );
        end

        for i = 1 : length(tagData.trialStarts)
            xt = t(tagData.trialStarts(i));
            h(6) = line( [xt xt], yLimits, 'color', 'g', 'DisplayName', 'start' );
        end
        
        for i = 1 : length(tagData.trialEnds)
            xt = t(tagData.trialEnds(i));
            h(7) = line( [xt xt], yLimits, 'color', 'r', 'DisplayName', 'end' );
        end
           
        if isfield(tagData,'user1')
            for i=1:length(tagData.user1)
                xt = t(tagData.user1(i));
                h(8) = line( [xt xt], yLimits, 'color', 'm', 'DisplayName', 'user1' );
            end
        end

        if isfield(tagData,'user2')
            for i=1:length(tagData.user2)
                xt = t(tagData.user2(i));
                h(9) = line( [xt xt], yLimits, 'color', 'c', 'DisplayName', 'user2' );
            end
        end
        flag = true(size(h));
        for( iH = 1 : size(h,2) )
            if( strcmp( class(h(iH)), 'matlab.graphics.GraphicsPlaceholder' ) )
                flag(iH) = false;
            end
        end
        h = h(flag);

        hAxis.iFrames(end+1) = plot( [1, 1] * (iFrame-1)/frameRate, yLimits * [ 1.05, -0.05; -0.05, 1.05 ]', '-.k', 'LineWidth', 2 );

        xlim(t([1,end]));
        ylim( yLimits * [ 1.2, -0.2; -0.2, 1.2 ]' );
        ylabel(yLabel);
        title( inputName, 'FontSize', 14, 'VerticalAlignment', 'top' );
        set( legend(h), 'location', 'EastOutside', 'FontSize', 12 );
    end


    function UpdateTimeRange()
        % called when time range changed

        set( hAxis.timeRanges(1), 'XData', [1, 1] * startFrame );
        hAxis.timeRanges(2).Position(1) = startFrame;
        hAxis.timeRanges(2).String = sprintf( '%.1fs', (startFrame-1)/frameRate );
        set( hAxis.timeRanges(3), 'XData', [1, 1] * endFrame );
        hAxis.timeRanges(4).Position(1) = endFrame;
        hAxis.timeRanges(4).String = sprintf( '%.1fs', (endFrame-1)/frameRate );
        set( hAxis.offTimeBars(1), 'XData', [1,startFrame] );
        set( hAxis.offTimeBars(2), 'XData', [endFrame,NFrames] );
        set( hAxis.onTimeBar, 'XData', [startFrame,endFrame] );

        pos=[];
        for i=1:length(objs)
            pos = [ pos objs{i}.pos, reshape( cat(3,objs{i}.markerPos), 3, [] )];
        end
        index = ( (startFrame:endFrame) + NFrames * ( 0 : length(pos)/NFrames-1)' )';
        pos = pos(:,index(:));
        lims1 = mean(pos,2) + ( std(pos,0,2) + 0.002 ) * [-4 4];
        mins = min(pos,[],2)-0.002; maxs = max(pos,[],2)+0.002;
        lims2 = [mins*1.1 - maxs*0.1, -mins*0.1 + maxs*1.1];
        lims = [ max( lims1(:,1), lims2(:,1) ), min( lims1(:,2), lims2(:,2) ) ];
        set( hAxis.objs, 'XLim', lims(1,:), 'YLim', lims(2,:), 'ZLim', lims(3,:) );

        set( hAxis.curves, 'XLim', ([startFrame, endFrame] - 1) / frameRate );
        for( iAxes = 1 : size(hAxis.curves,2) )
            h = get( hAxis.curves(iAxes), 'children' );
            if( size(h,1) >= 3 )
                y = [h(end-2:end).YData];
                yLim1 = mean(y) + std(y) * [-4 4];
                yLim2 = [min(y), max(y)];
                yLim = [ max( yLim1(:,1), yLim2(:,1) ), min( yLim1(:,2), yLim2(:,2) ) ];
                if( yLim(1) == yLim(2) )
                    yLim = [yLim(1)-1, yLim(2)+1];
                end
                set( hAxis.iFrames(3:end), 'YData', yLim * [ 1.05, -0.05; -0.05, 1.05 ]' );
                set( hAxis.curves(iAxes), 'YLim', yLim * [ 1.2, -0.2; -0.2, 1.2 ]' );
            end
        end
    end


    function UpdateFrame()
        % update objects
        for iObj = 1 : length(objs)
            %% display pivot (position of object)
            pivot = objs{iObj}.pos(:,iFrame);
            hAxis.pivots(iObj).XData = pivot(1);
            hAxis.pivots(iObj).YData = pivot(2);
            hAxis.pivots(iObj).ZData = pivot(3);

            %% display markers
            markersM = reshape( objs{iObj}.markerPos(:,iFrame,:), 3, [] );
            hAxis.markers(iObj).XData = markersM(1,:);
            hAxis.markers(iObj).YData = markersM(2,:);
            hAxis.markers(iObj).ZData = markersM(3,:);
            for( iMarker = 1 : size(markersM,2) )
                hAxis.markersTxt{iObj}(iMarker).Position = markersM(:,iMarker);
            end
            for( iMarker = 1 : size(markersM,2)-1 )
                for( jMarker = iMarker+1 : size(markersM,2) )
                    hAxis.marker2marker{iObj}(iMarker,jMarker).XData = markersM(1, [iMarker,jMarker]);
                    hAxis.marker2marker{iObj}(iMarker,jMarker).YData = markersM(2, [iMarker,jMarker]);
                    hAxis.marker2marker{iObj}(iMarker,jMarker).ZData = markersM(3, [iMarker,jMarker]);
                end
            end
            % connect to pivot
            for( iMarker = 1 : size(markersM,2) )
                hAxis.pivot2marker{iObj}(iMarker).XData = [pivot(1), markersM(1,iMarker)];
                hAxis.pivot2marker{iObj}(iMarker).YData = [pivot(2), markersM(2,iMarker)];
                hAxis.pivot2marker{iObj}(iMarker).ZData = [pivot(3), markersM(3,iMarker)];
            end
            hAxis.names(iObj).Position = [pivot(1), pivot(2), max(markersM(3,:))];
            hAxis.names(iObj).String = objs{iObj}.name;
            
            %% display offsets
            if( isfield( objs{iObj}, 'offsetLoc' ) )
                offsetM = reshape( objs{iObj}.offsetLoc(:,iFrame,:), 3, [] );
                hAxis.offsets(iObj).XData = offsetM(1,:);
                hAxis.offsets(iObj).YData = offsetM(2,:);
                hAxis.offsets(iObj).ZData = offsetM(3,:);
                for( i = 1 : size(offsetM,2) )
                    hAxis.offsetsTxt{iObj}(i).Position = offsetM(:,i);
                    hAxis.offsetsTxt{iObj}(i).String = sprintf( 'o%d', i );
                end
            end
            
            %% display vectors
            if isfield( objs{iObj}, 'vector' )
                vec = reshape( [objs{iObj}.vector(:,iFrame,:)], 3, [] );
                hAxis.vectors(iObj).XData = repmat( pivot(1), 1, N );
                hAxis.vectors(iObj).YData = repmat( pivot(2), 1, N );
                hAxis.vectors(iObj).ZData = repmat( pivot(3), 1, N );
                hAxis.vectors(iObj).UData = vec(1,:);
                hAxis.vectors(iObj).VData = vec(2,:);
                hAxis.vectors(iObj).WData = vec(3,:);
            end
        end

        % update eyes
        for( iEye = 1 : length(eyes) )
            set( hAxis.eyePos(iEye,:), 'XData', eyes.pos{iEye}(1,iFrame), 'YData', eyes.pos{iEye}(2,iFrame), 'ZData', eyes.pos{iEye}(3,iFrame) );
            if( isfield( eyes, 'sightVec' ) )
                set( hAxis.eyeVec(iEye), 'XData', eyes.pos{iEye}(1,iFrame), 'YData', eyes.pos{iEye}(2,iFrame), 'ZData', eyes.pos{iEye}(3,iFrame),...
                    'UData', eyes.sightVec{iEye}(1,iFrame), 'VData', eyes.sightVec{iEye}(2,iFrame), 'WData', eyes.sightVec{iEye}(3,iFrame) );
            end
        end

        hAxis.iFrames(1).Position(1) = iFrame;
        hAxis.iFrames(1).String = sprintf( '%.2fs', (iFrame-1)/frameRate );
        set( hAxis.iFrames(2), 'XData', [1, 1] * iFrame );
        set( hAxis.iFrames(3:end), 'XData', [1, 1] * (iFrame-1)/frameRate );
    end


end