classdef Dyno < handle
    properties
        % Car Properties
        dyno_gear_ratio
        pulse2m
        car_mass
        car_torque_array = []
        drum_radius

        % Plotting Values
        pos_array_plot = [0]
        time_array_plot = [0]
        speed_array_plot = [0]
        accel_array_plot = []
        motTor_array_plot = []
        energy_val_plot = 0
        power_val_plot = 0
        dist_trav_plot = 0
        dist_trav_plot_tol
        length_bool = false

        % Simulation Properties
        resid_time = 0

        pos_array = [0]
        time_array = [0]
        prev_time = 0

        speed_array = [0]
        speed_array_mean = [0]
        speed_array_dirty = [0]

        accel_array = []
        accel_array_mean = []
        accel_array_dirty = []

        power_array = []
        energy_array = [0]

        res_force_array = []

        curr_res_force = 0
        prev_drum_force = 0

        smoothing = [1,1,1,1, 1,1,1,1]
        sim_started = false

        arduino_torque
        
        % Conversions
        eff_mass_inertia
        massScaling
        f_car2car_mot_t
        f_drum2drum_mot_t
        resultant2accel
    end

    methods
        function obj = Dyno(vars, smooth)
            obj.arduino_torque = ArduinoTorque(vars);
            % Assigning Properties
            obj.drum_radius = vars.drum_rad/1000.0; % mm to m
            obj.dyno_gear_ratio = vars.dyno_gear_ratio;
            obj.car_mass = vars.car_mass;
            obj.smoothing = smooth;
            obj.car_torque_array = [vars.Stall_torque/1000.0];
            
            % Assigning Conversions
            rad_pulse = (2.0*pi/vars.dyno_ppr); % changes per revolution
            obj.pulse2m = rad_pulse * (obj.drum_radius) / vars.dyno_gear_ratio; % encoder pulse to distance in m
            obj.eff_mass_inertia = vars.drum_mass_inertia + (vars.flywheel_mass_inertia^2 * vars.flywheel_mass_inertia);
            obj.massScaling = (obj.eff_mass_inertia/(obj.car_mass*(obj.drum_radius^2)));
            obj.f_car2car_mot_t = (vars.wheel_size/2000.0)/vars.car_gear_ratio;
            obj.f_drum2drum_mot_t = obj.drum_radius/obj.dyno_gear_ratio;
            obj.resultant2accel = (obj.drum_radius^2)/obj.eff_mass_inertia;
            
            % Plotting Values
            obj.dist_trav_plot_tol = (pi * 2 * obj.drum_radius);
        end

        function analyseEncoder(obj, new_time)
            obj.res_force_array(end+1) = obj.curr_res_force;
            if new_time >= 2960
                new_time = double(new_time + obj.resid_time);
                %%%%%%%%%%%%%%%%%%%%
                %%%% Position & Time
                %%%%%%%%%%%%%%%%%%%%
                obj.dist_trav_plot = obj.dist_trav_plot + obj.pulse2m;
                obj.pos_array(end+1) = obj.pos_array(end) + obj.pulse2m; % Absolute position in m
                obj.time_array(end+1) = obj.time_array(end) + (new_time / 1000000.0); % Absolute time in s
                %%%%%%%%%%%%%%%%%%%%
                %%%% Speed
                %%%%%%%%%%%%%%%%%%%%
                % if new_time > obj.prev_time + 1 || new_time < obj.prev_time - 1 % If time hasn't changed much
                % if ~isempty(obj.speed_array)
                %     speed_value = (2000000.0*obj.pulse2m/new_time)-obj.speed_array(end);
                % else
                %     speed_value = 2000000.0*obj.pulse2m/new_time;
                % end
                speed_value = 1000000.0*obj.pulse2m/new_time;
    
                obj.cleanSpeed(speed_value);
                obj.speed_array_dirty(end+1) = speed_value;
                
                % if length(obj.speed_array) == 2
                %     obj.convergeSpeeds(0.000001);
                % end
                if length(obj.speed_array) == 1
                    rot_ke = 0.5*obj.eff_mass_inertia*((obj.speed_array(end)/obj.drum_radius)^2);
                    obj.power_array(end+1) = (obj.curr_res_force*obj.speed_array(end)) + (rot_ke*1000000/new_time);
                    obj.energy_array(end+1) = obj.energy_array(end) + ((obj.curr_res_force*obj.pulse2m) + rot_ke)/1000;
                end
                %%%%%%%%%%%%%%%%%%%%
                %%%% Acceleration
                %%%%%%%%%%%%%%%%%%%%
                if length(obj.speed_array) >= 2
                    accel_value = (1000000 * (obj.speed_array(end) - obj.speed_array(end-1))) / new_time;
                    obj.cleanAccel(accel_value);
                    obj.accel_array_dirty(end+1) = accel_value;
    
                    rot_ke = max(0.5*obj.eff_mass_inertia*(((obj.speed_array(end)/obj.drum_radius)^2) - ((obj.speed_array(end-1)/obj.drum_radius)^2)), 0);
                    obj.power_array(end+1) = (obj.curr_res_force*obj.speed_array(end)) + (rot_ke*1000000.0/new_time);
                    obj.energy_array(end+1) = obj.energy_array(end) + ((obj.curr_res_force*obj.pulse2m) + rot_ke)/1000;
                    
                    % new_time = new_time
                    % curr_res = obj.curr_res_force
                    % speed_value = speed_value
                    % speed_change = (2000000.0*obj.pulse2m/double(new_time))
                    % old_speed = obj.speed_array(end-1)
                    % curr_speed = obj.speed_array(end)
                    % curr_power = obj.power_array(end)
                    % curr_energy = obj.energy_array(end)
                    % "------------------------------"
                end
    
                if obj.dist_trav_plot >= obj.dist_trav_plot_tol
                    if obj.length_bool
                        obj.pos_array_plot = [obj.pos_array_plot(2:end), obj.pos_array(end)];
                        obj.time_array_plot = [obj.time_array_plot(2:end), obj.time_array(end)];
                        delta_s = obj.pos_array_plot(end) - obj.pos_array_plot(end - 1);
                        delta_t = obj.time_array_plot(end) - obj.time_array_plot(end-1);
                        % obj.speed_array_plot = [obj.speed_array_plot(2:end), (2.0*delta_s/delta_t)-obj.speed_array_plot(end)];
                        obj.speed_array_plot = [obj.speed_array_plot(2:end), (delta_s/delta_t)];
                        obj.accel_array_plot = [obj.accel_array_plot(2:end), ((obj.speed_array_plot(end) - obj.speed_array_plot(end-1)) / delta_t)];
                        obj.motTor_array_plot = [obj.motTor_array_plot(2:end), ((obj.accel_array_plot(end)/obj.resultant2accel) + obj.curr_res_force) * obj.f_car2car_mot_t];
                        
                    else
                        obj.pos_array_plot(end+1) = obj.pos_array(end);
                        obj.time_array_plot(end+1) = obj.time_array(end);
                        delta_s = obj.pos_array_plot(end) - obj.pos_array_plot(end - 1);
                        delta_t = obj.time_array_plot(end) - obj.time_array_plot(end-1);
                        % obj.speed_array_plot(end+1) = (2.0*delta_s/delta_t)-obj.speed_array_plot(end);
                        obj.speed_array_plot(end+1) = (delta_s/delta_t);
                        obj.accel_array_plot(end+1) = ((obj.speed_array_plot(end) - obj.speed_array_plot(end-1)) / delta_t);
                        obj.motTor_array_plot(end+1) = ((obj.accel_array_plot(end)/obj.resultant2accel) + obj.curr_res_force) * obj.f_car2car_mot_t;
                        if length(obj.pos_array_plot) >=20
                            obj.length_bool = true;
                        end
                    end
                    rot_ke = max(0.5*obj.eff_mass_inertia*(((obj.speed_array_plot(end)/obj.drum_radius)^2) - ((obj.speed_array_plot(end-1)/obj.drum_radius)^2)), 0);
                    obj.power_val_plot = (obj.curr_res_force*obj.speed_array_plot(end)) + (rot_ke*delta_t);
                    obj.energy_val_plot = obj.energy_val_plot + ((obj.curr_res_force*obj.pulse2m) + rot_ke)/1000;
                    obj.dist_trav_plot = obj.dist_trav_plot - obj.dist_trav_plot_tol;
                end
                obj.resid_time = 0;
            else
                obj.resid_time = obj.resid_time + new_time;
            end
        end

        function convergeSpeeds(obj, step_size)
            u0 = 2*obj.speed_array(1) - obj.speed_array(2);
            t1 = (2*obj.pulse2m)/(u0+obj.speed_array(1));
            obj.speed_array(2) = ((2*obj.pulse2m)/(obj.time_array(3) - obj.time_array(2)))-obj.speed_array(1);

            condition = true;
            condition = condition && t1 < obj.time_array(2)+0.000000001 && t1 > obj.time_array(2)-0.000000001;

            while ~condition
                if t1 > obj.time_array(1)
                    obj.speed_array(1) = obj.speed_array(1) + step_size;
                else
                    obj.speed_array(1) = obj.speed_array(1) - step_size;
                end

                u0 = 2*obj.speed_array(1) - obj.speed_array(2);
                t1 = (2*obj.pulse2m)/(u0+obj.speed_array(1));
                obj.speed_array(2) = ((2*obj.pulse2m)/(obj.time_array(3) - obj.time_array(2)))-obj.speed_array(1);
                condition = true;
                condition = condition && t1 < obj.time_array(2)+0.000000001 && t1 > obj.time_array(2)-0.000000001;
            end
            obj.speed_array_dirty = obj.speed_array;
            obj.speed_array_mean = obj.speed_array;
        end

        function cleanSpeed(obj, new_speed)
            data = [obj.speed_array_dirty(max(end-(obj.smoothing(1)-obj.smoothing(3)-1),1):end), repmat(new_speed, 1, obj.smoothing(3))];
            if length(data) < obj.smoothing(1)
                data = [data, repmat(new_speed, 1, obj.smoothing(1)-length(data))];
            end
            new_mean_speed = mean(data);
            % discrete linear convolution of two one-dimensional sequences
            % each output point is calculated as a weighted sum of the corresponding elements from the original data
            % clean_data[i] = Σ_a data[a] * weights[i-a]
            data = [obj.speed_array_mean(max(end-(obj.smoothing(2)-obj.smoothing(4)-1),1):end), repmat(new_mean_speed, 1, obj.smoothing(4))];
            if length(data) < obj.smoothing(2)
                data = [data, repmat(new_mean_speed, 1, obj.smoothing(2)-length(data))];
            end
            weights = ones(size(data)) / numel(data);
            cleaned_speed = conv(data, weights, 'valid');
            obj.speed_array_mean(end+1) = new_mean_speed;
            obj.speed_array(end+1) = cleaned_speed(end);
        end

        function cleanAccel(obj, new_accel)
            data = [obj.accel_array_dirty(max(end-(obj.smoothing(5)-obj.smoothing(7)-1),1):end), repmat(new_accel, 1, obj.smoothing(7))];
            if length(data) < obj.smoothing(5)
                data = [data, repmat(new_accel, 1, obj.smoothing(5)-length(data))];
            end
            new_mean_accel = mean(data);
            % discrete linear convolution of two one-dimensional sequences
            % each output point is calculated as a weighted sum of the corresponding elements from the original data
            % clean_data[i] = Σ_a data[a] * weights[i-a]
            data = [obj.accel_array_mean(max(end-(obj.smoothing(6)-obj.smoothing(8)-1),1):end), repmat(new_mean_accel, 1, obj.smoothing(8))];
            if length(data) < obj.smoothing(6)
                data = [data, repmat(new_mean_accel, 1, obj.smoothing(6)-length(data))];
            end
            weights = ones(size(data)) / numel(data);
            cleaned_accel = conv(data, weights, 'valid');
            obj.accel_array_mean(end+1) = new_mean_accel;
            obj.accel_array(end+1) = cleaned_accel(end);
        end

        function f_drum = apply_force(obj, f_drum)
            [f_drum, forwards] = obj.arduino_torque.applyTorque(obj.speed_array(end), f_drum);
            multiplier = (forwards*2) - 1;
            f_drum = f_drum * multiplier;
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%% Getter's
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function speed = curr_speed(obj)
            speed = obj.speed_array_plot(end);
        end

        function time = curr_time(obj)
            time = obj.time_array_plot(end);
        end

        function pos = curr_pos(obj)
            pos = obj.pos_array_plot(end);
        end

        function energy = curr_energy(obj)
            energy = obj.energy_val_plot;
        end

        function power = curr_power(obj)
            power = obj.power_val_plot;
        end

        function pos_arr = pos_range(obj, array_range, no_pts)
            pos_arr = obj.pos_array_plot;
        end
        
        function time_arr = time_range(obj, array_range, no_pts)
            time_arr = obj.time_array_plot;
        end

        function speed_arr = speed_range(obj, array_range, no_pts)
            speed_arr = obj.speed_array_plot;
        end

        function accel_arr = accel_range(obj, array_range, no_pts)
            accel_arr = obj.accel_array_plot;
        end

        function mot_arr = motT_range(obj, array_range, no_pts)
            mot_arr = obj.motTor_array_plot;
        end

        function export_base_data(obj)
            writematrix(obj.pos_array', "position_data.csv");
            writematrix(obj.time_array', "time_data.csv");
            writematrix(obj.speed_array', "speed_data.csv");
            writematrix(obj.accel_array', "accel_data.csv");
            writematrix(obj.energy_array', "energy_data.csv");
            writematrix(obj.power_array', "power_data.csv");
            writematrix(obj.car_torque_array', "car_torque.csv")
            writematrix(obj.res_force_array', "resistive_force.csv")
        end
    end
end

