classdef Track < handle
    properties
        track_length
        mass
        cog_height
        wheelbase
        cog_x
        tyre_slip_coeff
        radius
        rad_dist
        incline
        inc_dist
        yawObj
    end
    
    methods
        function analyseTrack(obj, vars)
            obj.track_length = vars.track_length;
            obj.mass = vars.car_mass;
            obj.cog_height = vars.car_cog_height;
            obj.wheelbase = vars.wheelbase;
            obj.cog_x = vars.car_cog_x;
            obj.tyre_slip_coeff = vars.tyre_slip_coeff_deg;

            % Yaw analysis
            obj.yawObj = Yaw(vars.map_file_path);
            obj.yawObj.analyze_track(vars.track_length, vars.track_clockwise, vars.starting_point, vars.track_tolerance, vars.straight_len, vars.straight_tol, vars.overlay, vars.window_size);
            pitchObj = Pitch(vars.elevation_file_path);
            [obj.radius, obj.rad_dist] = obj.yawObj.get_radius_dist();
            [obj.incline, obj.inc_dist] = pitchObj.get_incline_dist();
        end

        function [x_map, y_map, dist1, dist2, distances, radii, yaw1, yaw2, yaw_angles] = get_plot_parameters(obj)
            bounds = obj.yawObj.boundaries;

            x_map = bounds(:,1);
            x_map = x_map - min(x_map); % Shift x values

            y_map = bounds(:,2);
            y_map = y_map - min(y_map); % Shift y values

            dist1 = obj.yawObj.dist_array1;
            dist2 = obj.yawObj.dist_array2;
            distances = obj.yawObj.distances;
            radii = obj.yawObj.radius;
            
            yaw1 = obj.yawObj.yaw_array1;
            yaw2 = obj.yawObj.yaw_array2;
            yaw_angles = obj.yawObj.yaw_angles;
        end

        function [x_map, y_map] = get_track_bounds(obj)
            bounds = obj.yawObj.boundaries;

            x_map = bounds(:,1);
            x_map = x_map - min(x_map); % Shift x values

            y_map = bounds(:,2);
            y_map = y_map - min(y_map); % Shift y values
        end

        function clear_object(obj)
            obj.yawObj = [];
        end    
        
        % Calculate the resistive forces
        function total_force = get_res_forces(obj, pos, speed)
            [incline_force, incline_val] = obj.incline2long_force(pos);
            corner_force = obj.corner2long_force(pos, speed, incline_val);
            total_force = corner_force + incline_force;
        end

        % Internal methods for force calculations
        function [Mf, Mr] = get_mass_transfer(obj, incline)
            dist_rear = (obj.wheelbase * obj.cog_x) + (obj.cog_height * tan(incline));
            Mf = dist_rear * obj.mass / obj.wheelbase;
            Mr = obj.mass - Mf;
        end
        
        function force = corner2long_force(obj, position, speed, incline)
            [Mf, Mr] = obj.get_mass_transfer(incline);
            position = mod(position, obj.track_length);
            [~, idx] = min(abs(obj.rad_dist - position));
            corner_radius = obj.radius(idx);

            if corner_radius == 0 || corner_radius <= 6
                force = 0;
                return;
            end
            
            slip_ang_front = (Mf * speed^2) / (corner_radius * obj.tyre_slip_coeff);
            slip_ang_rear = (Mr * speed^2) / (corner_radius * obj.tyre_slip_coeff);
            force_front = obj.tyre_slip_coeff * slip_ang_front * sin(slip_ang_front * (pi/180));
            force_rear = obj.tyre_slip_coeff * slip_ang_rear * sin(slip_ang_rear * (pi/180));
            force = abs(force_front + force_rear);
        end
        
        function [force, inc] = incline2long_force(obj, position)
            position = mod(position, obj.track_length);
            [~, idx] = min(abs(obj.inc_dist - position));
            inc = obj.incline(idx);
            force = obj.mass * 9.81 * sin(inc);
        end
    end
end
