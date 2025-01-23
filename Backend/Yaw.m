classdef Yaw < handle
    properties
        boundaries
        yaw_angles
        radius
        distances
        dist_array1
        yaw_array1
        dist_array2
        yaw_array2
        track_length
    end
    
    methods
        function obj = Yaw(file_path)
            image = imread(file_path); % Read the image
            obj.boundaries = obj.track2boundaries(image); % Extract the track boundaries from the image
        end
        
        function track_contour = track2boundaries(obj, image)
            gray_image = rgb2gray(image); % Convert image to grayscale

            binary_image = imbinarize(gray_image, 200/255); % Binarize the image
            binary_image = ~binary_image; % Invert the binary image

            binary_image([1:5, end-4:end], :) = 0; % Remove top and bottom borders
            binary_image(:, [1:5, end-4:end]) = 0; % Remove left and right borders

            [B,~] = bwboundaries(binary_image, 'noholes'); % Find contours
            track_contour = B{1}; % Assuming the largest contour is the track
            
            track_contour = flip(track_contour);

            R = [0 1; -1 0];
            track_contour = track_contour * R; % Rotate 90 degrees clockwise
            
            track_contour(:, 2) = -1* track_contour(:, 2); % Flip the y values
            min_val = min(track_contour(:, 2));
            track_contour(:, 2) = track_contour(:, 2) - min_val; % Shift the y values so that the minimum is 0

            track_contour(:, 1) = -1* track_contour(:, 1); % Flip the x values
            min_val = min(track_contour(:, 1));
            track_contour(:, 1) = track_contour(:, 1) - min_val; % Shift the x values so that the minimum is 0
        end
        
        % Boundaries to yaw
        function [yaw_angle, cumulate_distances] = boundaries2yaw(obj, clockwise)
            % Calculate the yaw angle and distance between the first three points
            [yaw, dist] = obj.vector2yaw_distance(obj.boundaries(1,:), obj.boundaries(2,:), obj.boundaries(3,:));
            
            % Initialise arrays with first yaw angle and distance
            yaw_angle = [yaw];
            dists = [dist];
            % x = input("Enter to continue")
            
            % Iterate through the points
            for i = 3:size(obj.boundaries, 1)-1
                [yaw, dist] = obj.vector2yaw_distance(obj.boundaries(i-1,:), obj.boundaries(i,:), obj.boundaries(i+1,:));
                yaw_angle = [yaw_angle, yaw + yaw_angle(end)]; % Accumulate yaw angle
                dists = [dists, dist]; % Add distance
            end
            
            % Add the last yaw angle and distance to the arrays
            yaw_angle = real([yaw_angle, yaw_angle(end)]); % removes imag part errors seen in acos with float rounding errors
            dists = [dists, dists(end)];
            
            % Reverse arrays based on the direction and normalize yaw angles
            if yaw_angle(end) < 0 && clockwise
                yaw_angle = flip(yaw_angle);
                yaw_angle = yaw_angle - yaw_angle(1);
                dists = flip(dists);
                obj.boundaries = flip(obj.boundaries);
            elseif yaw_angle(end) > 0 && ~clockwise
                yaw_angle = flip(yaw_angle);
                yaw_angle = yaw_angle - yaw_angle(1);
                dists = flip(dists);
                obj.boundaries = flip(obj.boundaries);
            end
            
            % Calculate the cumulative distance along the boundary
            cumulate_distances = cumsum(dists);
        end

        
        % Vector to yaw distance calculation
        function [yaw, distance] = vector2yaw_distance(obj, last_point, current_point, next_point)
            current_vector = next_point - current_point;
            previous_vector = current_point - last_point;
            yaw = acos(dot(current_vector,previous_vector) / sqrt(sum(current_vector.^2)*sum(previous_vector.^2)));
            distance = norm(current_vector);
            cross_prod = cross([previous_vector, 0], [current_vector, 0]);
            if cross_prod(3) < 0
                yaw = -yaw;
            end
            yaw = -1 * yaw; % Making clockwise positive
        end
        
        % Normalize distances
        function normalized_distances = normalize_distances(obj, distances)
            multiplier = obj.track_length / distances(end);
            normalized_distances = distances * multiplier;
        end
        
        % Smooth points (moving average)
        function smoothed_points = smooth_points(obj, points, window_size, overlay)
            kernel = ones(1, window_size) / window_size;
            if size(points,2) > size(points,1)
                points = points.';
            end
            if overlay>0
                points = [points(end-(overlay-1):end); points; points(1:overlay)];
                smoothed_points = conv(points, kernel, 'valid');
                smoothed_points = smoothed_points(1+overlay-((window_size-1)/2):end-(overlay-((window_size-1)/2)));
            else
                smoothed_points = conv(points, kernel, 'valid');
                smoothed_points = [smoothed_points(1:((window_size-1)/2)); smoothed_points; smoothed_points(end-(((window_size-1)/2)-1):end)];
            end
        end
        
        function points = mean_filter(obj, points, window_size)
            N = length(points);
            filtered_points = zeros(1, N);  % Initialize with zeros
            for i = 1:N
                startIdx = max(1, i - floor((window_size-1)/2));
                endIdx = min(N, i + floor((window_size-1)/2));
                filtered_points(i) = mean(points(startIdx:endIdx));
            end
            points = filtered_points;
        end
        function [yaw, dist] = angles2radius(obj, yaw_angles, distances, tolerance, straight_len, straight_tol)
            yaw_angles = yaw_angles / tolerance;  % Scale the yaw angles
            yaw_angles = round(yaw_angles);  % Round the yaw angles to integers
            dist = [0];
            yaw = [0];
        
            % For plotting
            obj.dist_array2 = distances;
            obj.yaw_array2 = yaw_angles * tolerance;
            prev_dist = 0;
            prev_ind = 1;
            curr_dist = 0;
            curr_ind = 1;
            for i = 2:length(yaw_angles) % iterating through points
                if yaw_angles(i) == yaw_angles(i-1) % if last point = current point
                    curr_dist = curr_dist + distances(i) - distances(i-1); % add distance between points to current distance
                elseif curr_dist <= straight_tol && yaw(end) == yaw_angles(i)
                    curr_dist = prev_dist;
                    curr_ind = prev_ind;
                    yaw = yaw(1:end-2);
                    dist = dist(1:end-2);
                else % if points not equal
                    if curr_dist >= straight_len % if current distance > straight_len
                        yaw = [yaw, yaw_angles(curr_ind), yaw_angles(i-1)];  % Add first and last point of straight to array
                        dist = [dist, distances(curr_ind), distances(i-1)];  % Add first and last point of straight to array
                    end
                    prev_dist = curr_dist; 
                    curr_dist = 0; % set current distance to 0
                    prev_ind = curr_ind;
                    curr_ind = i;
                end
            end
            if curr_dist >= straight_len % if current distance > straight_len
                yaw = [yaw, yaw_angles(curr_ind), yaw_angles(end)];  % Add first and last point of straight to array
                dist = [dist, distances(curr_ind), distances(end)];  % Add first and last point of straight to array
            else
                yaw = [yaw, yaw_angles(end)];
                dist = [dist, obj.track_length];
            end

            yaw(2) = [];
            dist(2) = [];
            yaw = yaw * tolerance;  % Scale back the yaw angles
        end
        
        function radius = yaw_dist2radius(obj)
            diff_distances = diff(obj.distances);
            diff_yaw_angles = diff(obj.yaw_angles);
            radius = zeros(1, length(diff_yaw_angles));
        
            for i = 1:length(diff_yaw_angles)
                if diff_yaw_angles(i) == 0
                    radius(i) = 0;
                else
                    rad_calc = abs(diff_distances(i) / diff_yaw_angles(i));
                    if rad_calc <= 6
                        radius(i) = 0;
                    else
                        radius(i) = rad_calc;
                    end
                end
            end
            radius = [radius, radius(end)];
        end

        function analyze_track(obj, track_len, clockwise, starting_point, tolerance, straight_len, straight_tol, overlay, window_size)
            obj.track_length = track_len;

            dist = pdist2(starting_point, obj.boundaries, 'euclidean'); % Calculate the distance between the starting point and all the points
            [~, closest_index] = min(dist); % Find the index of the closest point
            obj.boundaries = circshift(obj.boundaries, -closest_index+1, 1); % Shift the array so that the closest point is at the beginning
            
            x = cumsum(obj.mean_filter([0; diff(obj.boundaries(:, 1))], window_size));
            y = cumsum(obj.mean_filter([0; diff(obj.boundaries(:, 2))], window_size));
            x = obj.smooth_points(x, window_size, overlay);
            y = obj.smooth_points(y, window_size, overlay);
            obj.boundaries = [x, y];

            [yaw_ang, dist] = obj.boundaries2yaw(clockwise); % Calculate the yaw angles and distances
            normalized_distances = obj.normalize_distances(dist); % Normalize the distances

            yaw_ang = obj.smooth_points(yaw_ang, window_size, 0).'; % Smooth the yaw angles
            yaw_ang = cumsum(obj.mean_filter([0, diff(yaw_ang)], window_size));
            
            obj.yaw_array1 = yaw_ang; % For plotting
            obj.dist_array1 = normalized_distances; % For plotting
            
            [obj.yaw_angles, obj.distances] = obj.angles2radius(yaw_ang, normalized_distances, tolerance, straight_len, straight_tol); % Calculate the yaw angles and distances
            obj.radius = obj.yaw_dist2radius(); % Calculate the radius of the corners
        end

        function [radius, distances] = get_radius_dist(obj)
            radius = obj.radius;
            distances = obj.distances;
        end


    end
end
