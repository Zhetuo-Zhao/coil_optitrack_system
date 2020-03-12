classdef CoilLoader
    properties
        data
        settings
    end

    methods
        function obj = CoilLoader(direct, data_filename,tags_filename,settings_filename)
            data_fid = fopen([direct data_filename],'r');
            tags_fid = fopen([direct tags_filename],'r');

            % read the first line of both csv files to get the headers
            disp('grabbing data headers...');
            data_names = strsplit( fgetl(data_fid), ',');
            disp('grabbing tag headers...');
            tag_names = strsplit( fgetl(tags_fid), ',');
            
            % fclose the files so we can use the csvread function
            fclose(data_fid);
            fclose(tags_fid);

            % read in our data, but skip the header
            disp(['reading in ', data_filename, '...']);
            raw_data = csvread([direct data_filename],1);
%             save([direct 'coil_backup.mat'],'raw_data','-v7.3')
            
            disp(['reading in ', tags_filename, '...']);
            raw_tags = csvread([direct tags_filename],1); 
%             save([direct 'tag_backup.mat'],'raw_tags','-v7.3')
            % check to make sure we have the same number of coil samples
            % and tag samples - if this isn't the case then we have a data
            % collection issue on our hands
            [n_samples,~] = size(raw_data);
            [n_tags,~] = size(raw_tags);
            if n_samples ~= n_tags
                sampleNum=min([n_samples n_tags]);
                raw_data=raw_data(1:sampleNum,:);
                raw_tags=raw_tags(1:sampleNum,:);
            end

            % save all the data into a struct for more resiliant loading of data
            obj.data = struct;

            % put the raw data in the data struct
            for i = 1:length(data_names)
                name = data_names{i};
                % add check for empty strings
                if name == ""
                    continue
                end
                obj.data.( name ) = raw_data(:,i);
            end
            % put the tags in the data struct
            for i = 1:length(tag_names)
                name = tag_names{i};
                % add check for empty strings
                if name == ""
                    continue
                end
                obj.data.( name ) = logical( raw_tags(:,i) );
            end
    
            % load in the capture parameters
            disp(['reading in ', settings_filename, '...']);
            obj.settings = load([direct settings_filename]);
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % functions that fetch raw data with no processing
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Raw Data
        function raw_data = getRaw(obj)
            %getRaw - fetches the raw data in the form of a struct
            %   Detailed explanation goes here
            raw_data = obj.data;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Settings
        function settings = getSettings(obj)
            settings = obj.settings;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % reference coils
        function [ref12,ref16,ref20] = getReferenceCoils(obj)
            ref12 = obj.data.ref12';
            ref16 = obj.data.ref16';
            ref20 = obj.data.ref20';
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % eye coils
        function [left_eye, right_eye] = getEyeCoils(obj)
            left_eye = obj.data.left_eye';
            right_eye = obj.data.right_eye';
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % helmet coils
        function [side_helmet, back_helmet] = getHelmetCoils(obj)
            side_helmet = obj.data.side_helmet_coil';
            back_helmet = obj.data.back_helmet_coil';
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % functions that must compute some value
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Rising edges
        function [rising_edges, timestamps] = computeFrameStarts(obj)
            rising_edges = findRisingEdges(obj.data.cam_exposure);
            % fetch the timestamps
            timestamps = obj.data.timestamps( rising_edges );

        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Falling edges
        function [falling_edges, timestamps] = computeFrameEnds(obj)
            falling_edges = findFallingEdges(obj.data.cam_exposure);
            % fetch the timestamps
            timestamps = obj.data.timestamps( falling_edges );
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % get time 
        function [timestamps] = getTimeStamps(obj)
            timestamps = obj.data.timestamps;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Frames where eyes were touched with eyeprobe
        function [left_eye_frame, right_eye_frame] = computeEyeprobeFrames(obj)
            eye_tags = findRisingEdges(obj.data.eyeprobe_tag);
            if numel(eye_tags) > 2
                warning('more than two eyeprobe tags detected!, only the last two will be used!');
            end
            disp('left eye is assumed to be the first detected tag');

            % fetch the first tag - by convention this will be the left eye
            left_eye_idx = eye_tags(end-1);
            % fetch the second tag - by convention this will be the right
            % eye
            right_eye_idx = eye_tags(end);

            % get the start indices of all frames
            [syncFrames, ~] = obj.computeFrameStarts();

            [~,left_eye_frame]=min(abs(syncFrames-left_eye_idx ));
            [~,right_eye_frame]=min(abs(syncFrames-right_eye_idx ));
        end
        
        function eyeFrames = computeEyeprobeFramesRaw(obj)
            eye_tags = findRisingEdges(obj.data.eyeprobe_tag);
            
            eyeFrames=[];
            % get the start indices of all frames
            [syncFrames, ~] = obj.computeFrameStarts();
            
            for i=length(eye_tags):-1:1
                [~,eyeFrames(i)]=min(abs(syncFrames-eye_tags(i) ));
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % find start and stop trial times
        function [start_frames, end_frames] = computeTrials(obj)
            % compute trial start and stop frames
            % returns a matrix containing
            % [trial1_start_frame, trial1_stop_frame;
            %  trial2_start_frame, trial2_stop_frame;
            %  trial3_start_frame, trial3_stop_frame;
            %  ...
            %  trialn_start_frame, trialn_stop_frame]
            trial_starts = findRisingEdges(obj.data.start_tag);
            trial_ends = findRisingEdges(obj.data.stop_tag);

            % get the start indices of all frames
            [syncFrames, ~] = obj.computeFrameStarts();

           for i=length(trial_starts):-1:1
                [~,start_frames(i)]=min(abs(syncFrames-trial_starts(i) ));
           end
            
           for i=length(trial_ends):-1:1
                [~,end_frames(i)]=min(abs(syncFrames-trial_ends(i) ));
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % find 9 point calibration frames
        function cal_frames = computeCalibrationFrames(obj)
            nine_point_indices = findRisingEdges(obj.data.cal_tag);

            [syncFrames, ~] = obj.computeFrameStarts();
             
            for i = length(nine_point_indices):-1:1
                [~,cal_frames(i)] = min(abs( syncFrames-nine_point_indices(i)));
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % find user tag frames
        function [user1,user2] = computeUserTagFrames(obj)
            % find rising edges
            user1_indices = findRisingEdges(obj.data.user_tag1);
            user2_indices = findRisingEdges(obj.data.user_tag2);
            
            [syncFrames, ~] = obj.computeFrameStarts();
            
            if isempty(user1_indices)
                user1=[];
            else
                for i = length(user1_indices):-1:1
                    [~,user1(i)] = min(abs( syncFrames - user1_indices(i)));
                end
            end
            
            if isempty(user2_indices)
                user2=[];
            else
                for i = length(user2_indices):-1:1
                    [~,user2(i)] = min(abs( syncFrames - user2_indices(i)));
                end
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % compute the number of optitrack frames in the coil data
        % collection
        function num_frames = computeNumFrames(obj)
            [frame_starts,~] = obj.computeFrameStarts();
            num_frames = length(frame_starts);
        end

    end
end
