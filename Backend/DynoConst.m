classdef DynoConst < Dyno
    methods
        function obj = DynoConst(vars, smooth)
            % Inheriting Superclass
            obj@Dyno(vars, smooth)
            obj.prev_drum_force = 0;
            obj.curr_res_force = 0;

            obj.apply_force(0);
        end

        function apply_const_force(obj, f_drum)
            if ~isempty(obj.accel_array)
                f_plus = obj.accel_array(end)/obj.resultant2accel + obj.prev_drum_force;
            end
            f_drum = obj.apply_force(f_drum);
            obj.curr_res_force = f_drum;
            obj.prev_drum_force = f_drum;

            if ~isempty(obj.accel_array)
                obj.car_torque_array(end+1) = f_plus * obj.f_car2car_mot_t;
            end
        end
    end
end
