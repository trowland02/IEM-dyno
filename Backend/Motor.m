classdef Motor < handle
    properties
        data_len
        motor_torque
        motor_speed
    end

    methods
        function obj = Motor(step_size, NomV_V, NLS_RPM, NLI_mA, Kt, Max_I)
            Nom_voltage = NomV_V;
            NoLoad_speed = NLS_RPM * pi / 30; % RPM to rad/s
            NoLoad_current = NLI_mA / 1000; % mA to A
            Max_torque = Kt * Max_I;
            obj.get_motor_data(step_size, Nom_voltage, NoLoad_speed, NoLoad_current, Max_torque, Max_I);
        end

        function get_motor_data(obj, step_size, Nom_voltage, NoLoad_speed, NoLoad_current, Max_torque, Max_I)
            obj.motor_speed = 0:step_size:NoLoad_speed; 
            obj.motor_torque = (NoLoad_speed - obj.motor_speed) .* Max_torque / NoLoad_speed;
            % obj.motor_current = NoLoad_current + (Max_I - NoLoad_current) / Max_torque .* obj.motor_torque;
            % obj.motor_power = obj.motor_speed .* obj.motor_torque;
            % obj.motor_efficiency = obj.motor_power ./ (Nom_voltage .* obj.motor_current);
            obj.data_len = length(obj.motor_speed);
        end
    end
end
