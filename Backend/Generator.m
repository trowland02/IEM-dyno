classdef Generator < handle
    properties
        motor_torque
        motor_speed
    end

    methods
        function obj = Generator(step_size, NomV_V, NLS_RPM, Kt, Ra)
            Nom_voltage = NomV_V; % V
            NoLoad_speed = NLS_RPM * pi / 30; % RPM to rad/s
            Arm_Resistance = Ra; % Ohm
            obj.get_motor_data(step_size, Nom_voltage, NoLoad_speed, Kt, Arm_Resistance);
        end

        function get_motor_data(obj, step_size, Nom_voltage, NoLoad_speed, Kt, Arm_Resistance)
            Ke = Nom_voltage / NoLoad_speed;

            obj.motor_speed = 0:step_size:NoLoad_speed; 
            obj.motor_torque = -1 * Ke * Kt * obj.motor_speed / Arm_Resistance;
        end
    end
end
