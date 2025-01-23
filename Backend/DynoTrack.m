classdef DynoTrack < Dyno
    properties
        % Car Properties
        cross_section
        tyre_res
        coef_drag
        track_len
        
        % Objects
        track
    end

    methods
        function obj = DynoTrack(vars, track, smooth)
            % Inheriting Superclass
            obj@Dyno(vars, smooth)
            obj.track = track;
    
            obj.speed_array = [0];
            obj.speed_array_mean = [0];
            obj.speed_array_dirty = [0];

            % Assigning Properties
            obj.cross_section = vars.car_cross_section;
            obj.tyre_res = vars.tyre_res;
            obj.coef_drag = vars.coef_drag;
            obj.track_len = vars.track_length;
            
            % Populating Arrays
            obj.prev_drum_force = obj.get_resistiveForce() + obj.tyre_res;
            obj.curr_res_force = obj.get_resistiveForce() + obj.tyre_res;

            accel1 = ((obj.car_torque_array(end)/obj.f_car2car_mot_t)-obj.prev_drum_force)/obj.car_mass;
            accel2 = ((obj.car_torque_array(end)/obj.f_car2car_mot_t)-(vars.dyno_Max_torque / (1000*obj.f_drum2drum_mot_t))) * obj.resultant2accel;
            if accel2 > accel1
                obj.prev_drum_force = vars.dyno_Max_torque / (1000*obj.f_drum2drum_mot_t);
                obj.accel_array = accel2;
            else
                obj.accel_array = accel1;
            end
            obj.accel_array = max(accel1, accel2);
            obj.accel_array_mean = [obj.accel_array(end)];
            obj.accel_array_dirty = [obj.accel_array(end)];
        end

        function simulate_track(obj, new_time)
            obj.analyseEncoder(new_time)
            obj.curr_res_force = obj.get_resistiveForce();
            obj.apply_scaled_force()
        end

        function apply_scaled_force(obj)
            if ~isempty(obj.accel_array)
                f_plus = obj.accel_array(end)/obj.resultant2accel + obj.prev_drum_force;
            end
            f_drum = f_plus - (f_plus - obj.curr_res_force) * obj.massScaling;

            f_drum = apply_force(f_drum);
            obj.prev_drum_force = f_drum;

            if ~isempty(obj.accel_array)
                obj.car_torque_array(end+1) = obj.prev_drum_force * obj.f_car2car_mot_t;
            end
        end

        function resistive_force = get_resistiveForce(obj)
            resistive_force = 0.5 * obj.coef_drag * obj.cross_section * obj.speed_array(end)^2 * 1.293; % air resistance formula
            resistive_force = resistive_force + 2 * obj.tyre_res; % calculate rolling resistance using exponential formula
            resistive_force = resistive_force + obj.track.get_res_forces(obj.pos_array(end), obj.speed_array(end)); % gets resistive forces from track
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%% Getter's
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function track_arr = trackR_range(obj, array_range, no_pts)
            len = length(obj.res_force_array);
            [low_index, spacing] = obj.get_index_spacing(len, array_range, no_pts);
            track_arr = obj.res_force_array(low_index:spacing:end);
        end

        function pos = curr_track_ind(obj)
            pos = mod(obj.pos_array(end), obj.track_len);
        end
    end
end

