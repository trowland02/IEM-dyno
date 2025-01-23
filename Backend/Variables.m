classdef Variables
    properties
        car_mass = 110;  % kg
        car_gear_ratio = (13/3) * (46/12);
        wheel_size = 460; % mm
        car_cog_height = 0.4; % meters
        wheelbase = 1.2; % meters
        car_cog_x = 0.4; % meters
        tyre_slip_coeff_deg = 10; % degrees
        
        dyno_gear_ratio = 1.106; % 1:1.106 ratio /3
        dyno_ppr = 12; % pulses per revolution
        drum_rad = 75; % mm 90 /80
        drum_mass_inertia = 0.5*7700*0.21*pi*((0.08^4)-(0.05685^4)); % kg m^2 0.5*7700*0.21*pi*((0.09^4)-(0.065^4)) = 0.1213 / 0.2099110109367458

        flywheel_mass_inertia = 0; % kg m^2
        flywheel_gear_ratio = 0; % (step down)

        Nom_voltage = 48; % V
        NoLoad_speed = 4900; % RPM
        NoLoad_current = 88.4; % mA
        Stall_torque = 7370; % mNm
        Stall_current = 78.9; % A

        Peak_torque = 7.37; %Nm

        coef_drag = 0.13; % drag coefficient
        car_cross_section = 0.6; % m^2
        tyre_res = 1.4; % N

        % % % % % % % % % % % % % % % % % % % % % % % % % best after mean
        track_length = 1600; % m
        straight_len = 40; % m (shortest straight)
        straight_tol = 5 % m (allowance for change
        track_tolerance = 0.285; % rad (tolerance of yaw)
        track_clockwise = true % is clockwise?
        starting_point = [680, 65]; % starting point on track
        overlay = 6; % convolution overlay of boundaries
        window_size = 7; % convultion window size (odd number)
        map_file_path = "track.png";
        elevation_file_path = "elevation_data.csv";
        
        res_force = 50; % N
        min_speed = 0; % m/s
        max_speed = 0; % m/s

        % dyno_Nom_voltage = 24; % V
        % dyno_NoLoad_speed = 1280; % RPM
        % dyno_NoLoad_current = 300; % mA
        % dyno_Kt = 0.171;
        % dyno_Max_current = 10; % A
        % dyno_Arm_resistance = 1.01; % Ohm
        % PWMUpper = 10; % A
        % PWMLower = -10; % A

        dyno_Nom_voltage = 64; % V
        dyno_NoLoad_speed = 3350; % RPM
        dyno_NoLoad_current = 300; % mA
        dyno_Kt = 0.171;
        dyno_Max_current = 16; % A
        dyno_Arm_resistance = 1.01; % Ohm
        PWMUpper = 16; % A
        PWMLower = -16; % A
        
        nano_port = []
        due_port = []

        PWMPin = 'D6';
        forwardPin = 'D26';
        enablePin = 'D36';
    end
end
