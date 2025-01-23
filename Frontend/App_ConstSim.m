classdef App_ConstSim < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                 matlab.ui.Figure
        BACKButton               matlab.ui.control.Button
        ForceLabel               matlab.ui.control.Label
        ForceNEditField          matlab.ui.control.NumericEditField
        ForceNEditFieldLabel     matlab.ui.control.Label
        PositionmEditField       matlab.ui.control.NumericEditField
        PositionmEditFieldLabel  matlab.ui.control.Label
        TimesEditField           matlab.ui.control.NumericEditField
        TimesEditFieldLabel      matlab.ui.control.Label
        SpeedmsEditField         matlab.ui.control.NumericEditField
        SpeedmsEditFieldLabel    matlab.ui.control.Label
        PowerWEditField          matlab.ui.control.NumericEditField
        PowerWEditFieldLabel     matlab.ui.control.Label
        EnergykJEditField        matlab.ui.control.NumericEditField
        EnergykJEditFieldLabel   matlab.ui.control.Label
        ENDButton                matlab.ui.control.Button
        APPLYButton              matlab.ui.control.Button
        EXPORTDATAButton         matlab.ui.control.Button
        CarAccelerationLabel     matlab.ui.control.Label
        CheckBox_Accel           matlab.ui.control.CheckBox
        MotorTorqueLabel         matlab.ui.control.Label
        CheckBox_MotTorq         matlab.ui.control.CheckBox
        CarSpeedLabel            matlab.ui.control.Label
        CheckBox_Speed           matlab.ui.control.CheckBox
        Header                   matlab.ui.control.Label
        UIAxes_Data              matlab.ui.control.UIAxes
        VariablesInstance        Variables % Instance of Variables class
        DynoInstance             DynoConst
        CommsInstance            Comms
        RunningFlag              logical = false; % Flag to control the loop
        PlotHandles              struct = struct();
        UpdateFigures
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)
            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxes_Data
            app.UIAxes_Data = uiaxes(app.UIFigure);
            title(app.UIAxes_Data, 'Title')
            xlabel(app.UIAxes_Data, 'X')
            ylabel(app.UIAxes_Data, 'Y')
            zlabel(app.UIAxes_Data, 'Z')
            app.UIAxes_Data.Position = [217 179 423 244];

            % Create Header
            app.Header = uilabel(app.UIFigure);
            app.Header.HorizontalAlignment = 'center';
            app.Header.FontSize = 18;
            app.Header.Position = [181 444 280 24];
            app.Header.Text = 'CONSTANT FORCE SIMULATION';

            % Create BACKButton
            app.BACKButton = uibutton(app.UIFigure, 'push');
            app.BACKButton.ButtonPushedFcn = createCallbackFcn(app, @backButtonPushed, true);
            app.BACKButton.FontSize = 10;
            app.BACKButton.Position = [16 445 63 23];
            app.BACKButton.Text = 'BACK';

            % Create CheckBox_Speed
            app.CheckBox_Speed = uicheckbox(app.UIFigure);
            app.CheckBox_Speed.Text = '';
            app.CheckBox_Speed.Position = [76 378 25 22];

            % Create CarSpeedLabel
            app.CarSpeedLabel = uilabel(app.UIFigure);
            app.CarSpeedLabel.HorizontalAlignment = 'center';
            app.CarSpeedLabel.Position = [99 378 62 22];
            app.CarSpeedLabel.Text = 'Car Speed';

            % Create CheckBox_MotTorq
            app.CheckBox_MotTorq = uicheckbox(app.UIFigure);
            app.CheckBox_MotTorq.Text = '';
            app.CheckBox_MotTorq.Position = [75 300 25 22];

            % Create MotorTorqueLabel
            app.MotorTorqueLabel = uilabel(app.UIFigure);
            app.MotorTorqueLabel.HorizontalAlignment = 'center';
            app.MotorTorqueLabel.Position = [99 300 77 22];
            app.MotorTorqueLabel.Text = 'Motor Torque';

            % Create CheckBox_Accel
            app.CheckBox_Accel = uicheckbox(app.UIFigure);
            app.CheckBox_Accel.Text = '';
            app.CheckBox_Accel.Position = [76 340 25 22];

            % Create CarAccelerationLabel
            app.CarAccelerationLabel = uilabel(app.UIFigure);
            app.CarAccelerationLabel.HorizontalAlignment = 'center';
            app.CarAccelerationLabel.Position = [99 340 94 22];
            app.CarAccelerationLabel.Text = 'Car Acceleration';

            % Create APPLYButton
            app.APPLYButton = uibutton(app.UIFigure, 'push');
            app.APPLYButton.ButtonPushedFcn = createCallbackFcn(app, @applyButtonPushed, true);
            app.APPLYButton.BackgroundColor = [0.3922 0.8314 0.0745];
            app.APPLYButton.FontSize = 14;
            app.APPLYButton.Position = [488 114 100 25];
            app.APPLYButton.Text = 'APPLY';

            % Create ENDButton
            app.ENDButton = uibutton(app.UIFigure, 'push');
            app.ENDButton.ButtonPushedFcn = createCallbackFcn(app, @endButtonPushed, true);
            app.ENDButton.BackgroundColor = [1 0 0];
            app.ENDButton.FontSize = 14;
            app.ENDButton.Position = [488 75 100 25];
            app.ENDButton.Text = 'END';

            % Create SpeedmsEditFieldLabel
            app.SpeedmsEditFieldLabel = uilabel(app.UIFigure);
            app.SpeedmsEditFieldLabel.HorizontalAlignment = 'right';
            app.SpeedmsEditFieldLabel.Position = [14 265 70 22];
            app.SpeedmsEditFieldLabel.Text = 'Speed (m/s)';

            % Create SpeedmsEditField
            app.SpeedmsEditField = uieditfield(app.UIFigure, 'numeric');
            app.SpeedmsEditField.Position = [99 265 90 22];

            % Create TimesEditFieldLabel
            app.TimesEditFieldLabel = uilabel(app.UIFigure);
            app.TimesEditFieldLabel.HorizontalAlignment = 'right';
            app.TimesEditFieldLabel.Position = [37 186 47 22];
            app.TimesEditFieldLabel.Text = 'Time (s)';

            % Create TimesEditField
            app.TimesEditField = uieditfield(app.UIFigure, 'numeric');
            app.TimesEditField.Position = [99 186 90 22];

            % Create PositionmEditFieldLabel
            app.PositionmEditFieldLabel = uilabel(app.UIFigure);
            app.PositionmEditFieldLabel.HorizontalAlignment = 'right';
            app.PositionmEditFieldLabel.Position = [16 225 68 22];
            app.PositionmEditFieldLabel.Text = 'Position (m)';

            % Create PositionmEditField
            app.PositionmEditField = uieditfield(app.UIFigure, 'numeric');
            app.PositionmEditField.Position = [99 225 90 22];

            % Create ForceNEditFieldLabel
            app.ForceNEditFieldLabel = uilabel(app.UIFigure);
            app.ForceNEditFieldLabel.HorizontalAlignment = 'right';
            app.ForceNEditFieldLabel.Position = [241 60 54 22];
            app.ForceNEditFieldLabel.Text = 'Force (N)';

            % Create ForceNEditField
            app.ForceNEditField = uieditfield(app.UIFigure, 'numeric');
            app.ForceNEditField.Position = [310 60 90 22];

            % Create ForceLabel
            app.ForceLabel = uilabel(app.UIFigure);
            app.ForceLabel.FontSize = 14;
            app.ForceLabel.Position = [198 93 246 22];
            app.ForceLabel.Text = 'Choose between -83.4 - 83.4 N';

            % Create EXPORTDATAButton
            app.EXPORTDATAButton = uibutton(app.UIFigure, 'push');
            app.EXPORTDATAButton.ButtonPushedFcn = createCallbackFcn(app, @exportButtonPushed, true);
            app.EXPORTDATAButton.Position = [488 39 100 23];
            app.EXPORTDATAButton.Text = 'EXPORT DATA';

            % Create EnergykJEditFieldLabel
            app.EnergykJEditFieldLabel = uilabel(app.UIFigure);
            app.EnergykJEditFieldLabel.HorizontalAlignment = 'right';
            app.EnergykJEditFieldLabel.Position = [20 145 64 22];
            app.EnergykJEditFieldLabel.Text = 'Energy (kJ)';

            % Create EnergykJEditField
            app.EnergykJEditField = uieditfield(app.UIFigure, 'numeric');
            app.EnergykJEditField.Position = [99 145 90 22];

            % Create PowerWEditFieldLabel
            app.PowerWEditFieldLabel = uilabel(app.UIFigure);
            app.PowerWEditFieldLabel.HorizontalAlignment = 'right';
            app.PowerWEditFieldLabel.Position = [24 104 60 22];
            app.PowerWEditFieldLabel.Text = 'Power (W)';

            % Create PowerWEditField
            app.PowerWEditField = uieditfield(app.UIFigure, 'numeric');
            app.PowerWEditField.Position = [99 104 90 22];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % Callbacks that handle component events
    methods (Access = private)
        function initialisePlots(app, event)
            hold(app.UIAxes_Data, 'on');
            app.PlotHandles.Accel = plot(app.UIAxes_Data, NaN, NaN, 'DisplayName', 'Accel (m/s)');
            app.PlotHandles.Speed = plot(app.UIAxes_Data, NaN, NaN, 'DisplayName', 'Speed (m)');
            app.PlotHandles.Torque = plot(app.UIAxes_Data, NaN, NaN, 'DisplayName', 'Motor Torque (Nm)');
            hold(app.UIAxes_Data, 'off');
            legend(app.UIAxes_Data, 'show');
            grid(app.UIAxes_Data, 'on');
        end

        % Button pushed function: BACKButton
        function backButtonPushed(app, event)
            app.RunningFlag = false;
            % Launch the Home Page app
            homePageApp = App_HomePage(app.VariablesInstance);
            homePageApp.UIFigure.Visible = 'on';

            % Close the current app
            delete(app)
        end

        % Button pushed function: ENDButton
        function endButtonPushed(app, event)
            app.RunningFlag = false; % should be removed
            app.DynoInstance.apply_const_force(0);
            app.ForceNEditField.Value = app.DynoInstance.curr_res_force;
        end

        % Button pushed function: APPLYButton
        function applyButtonPushed(app, event)
            app.DynoInstance.apply_const_force(app.ForceNEditField.Value);
            app.ForceNEditField.Value = app.DynoInstance.curr_res_force;
            app.RunningFlag = true;
        end

        % Button pushed function: EXPORTDATAButton
        function exportButtonPushed(app, event)
            app.DynoInstance.export_base_data();
        end

        function handleNewTime(app)
            app.RunningFlag = true;
            warning('off', 'all');
            read = false;
            % while ~read
            %     first_time = app.CommsInstance.readData() + 1;
            %     if first_time >=2
            %         read = true;
            %     end
            % end
            while app.RunningFlag
                new_time = app.CommsInstance.readData();
                app.DynoInstance.analyseEncoder(new_time)
                drawnow limitrate; % Process callbacks and update UI
            end
            warning('on', 'all');
        end

        function updateData(app)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Top Plot
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            pos_array = app.DynoInstance.pos_range(1000, 20);
            min_val = inf;
            max_val = -1*inf;
            points = 0;
            if app.CheckBox_Accel.Value
                data_range = app.DynoInstance.accel_range(1000, 20);
                set(app.PlotHandles.Accel, 'XData', pos_array, 'YData', data_range);
                min_val = min(min_val, min(data_range));
                max_val = max(max_val, max(data_range));
                points = points + 1;
            end
            if app.CheckBox_Speed.Value
                data_range = app.DynoInstance.speed_range(1000, 20);
                set(app.PlotHandles.Speed, 'XData', pos_array, 'YData', data_range);
                min_val = min(min_val, min(data_range));
                max_val = max(max_val, max(data_range));
                points = points + 1;
            end
            if app.CheckBox_MotTorq.Value
                data_range = app.DynoInstance.motT_range(1000, 20);
                set(app.PlotHandles.Torque, 'XData', pos_array, 'YData', data_range);
                min_val = min(min_val, min(data_range));
                max_val = max(max_val, max(data_range));
                points = points + 1;
            end
            if points == 0
                min_val = 0;
                max_val = 7;
            else
                min_val = min(floor(min_val), -0.25)-0.25;
                min_val = min_val*1.2;
                max_val = max(ceil(max_val), 0.25)+0.25;
                max_val = max_val*1.2;
            end
            xlim(app.UIAxes_Data, [pos_array(1) max(pos_array(1) + 1, pos_array(end))])
            ylim(app.UIAxes_Data, [min_val max_val])

            app.SpeedmsEditField.Value = app.DynoInstance.curr_speed();
            app.TimesEditField.Value = app.DynoInstance.curr_time();
            app.PositionmEditField.Value = app.DynoInstance.curr_pos();
            app.PowerWEditField.Value = app.DynoInstance.curr_power();
            app.EnergykJEditField.Value = app.DynoInstance.curr_energy();
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = App_ConstSim(variablesObj)
            
            app.VariablesInstance = variablesObj;
            app.DynoInstance = DynoConst(app.VariablesInstance, [3,7,3,3, 5,5,3,3]);
            app.CommsInstance = Comms(app.VariablesInstance.nano_port);
            [torque_UB, torque_LB] = app.DynoInstance.arduino_torque.get_forceBounds();

            % Create UIFigure and components
            createComponents(app)
            
            app.ForceLabel.Text = sprintf('Choose between %.2f to %.2f N', torque_UB, torque_LB);

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end

            app.initialisePlots();
            
            % Inside the constructor or a dedicated initialization method
            app.UpdateFigures = timer('ExecutionMode', 'fixedRate', ...
                        'Period', 0.3, ... % Adjust the period as needed
                        'TimerFcn', @(src, event)updateData(app));

            app.UpdateFigures.start()

            % Update plots
            app.updateData();

            app.handleNewTime();
        end

        % Code that executes before app deletion
        function delete(app)
            if isvalid(app.UpdateFigures)
                stop(app.UpdateFigures);
                delete(app.UpdateFigures);
            end
            app.CommsInstance.close()
            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end