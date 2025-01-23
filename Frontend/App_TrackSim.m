classdef App_TrackSim < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                 matlab.ui.Figure
        BACKButton               matlab.ui.control.Button
        PositionmEditField       matlab.ui.control.NumericEditField
        PositionmEditFieldLabel  matlab.ui.control.Label
        TimesEditField           matlab.ui.control.NumericEditField
        TimesEditFieldLabel      matlab.ui.control.Label
        SpeedmsEditField         matlab.ui.control.NumericEditField
        SpeedmsEditFieldLabel    matlab.ui.control.Label
        ENDButton                matlab.ui.control.Button
        STARTButton              matlab.ui.control.Button
        EXPORTDATAButton         matlab.ui.control.Button
        CarAccelerationLabel     matlab.ui.control.Label
        CheckBox_Accel           matlab.ui.control.CheckBox
        MotorTorqueLabel         matlab.ui.control.Label
        CheckBox_MotTorq         matlab.ui.control.CheckBox
        ResitiveForceLabel       matlab.ui.control.Label
        CheckBox_ResForce        matlab.ui.control.CheckBox
        CarSpeedLabel            matlab.ui.control.Label
        CheckBox_Speed           matlab.ui.control.CheckBox
        TRACKSIMULATIONLabel     matlab.ui.control.Label
        UIAxes_Data              matlab.ui.control.UIAxes
        UIAxes_Map               matlab.ui.control.UIAxes
        DynoInstance             DynoTrack % Instance of DynoTrack class';
        VariablesInstance        Variables % Instance of Variables class
        TrackInstance            Track % Instance of Track class
        RunningFlag              logical = false; % Flag to control the loop
        PlotHandles              struct = struct();
        CommsInstance            Comms
        UpdateFigures
        x_map
        y_map
        distances
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'MATLAB App';

            % Create BACKButton
            app.BACKButton = uibutton(app.UIFigure, 'push');
            app.BACKButton.ButtonPushedFcn = createCallbackFcn(app, @backButtonPushed, true);
            app.BACKButton.FontSize = 10;
            app.BACKButton.Position = [14 444 62 23];
            app.BACKButton.Text = 'BACK';


            % Create UIAxes_Map
            app.UIAxes_Map = uiaxes(app.UIFigure);
            title(app.UIAxes_Map, 'Track Map')
            xlabel(app.UIAxes_Map, '')
            ylabel(app.UIAxes_Map, '')
            zlabel(app.UIAxes_Map, '')
            app.UIAxes_Map.Position = [211 8 423 215];

            % Create UIAxes_Data
            app.UIAxes_Data = uiaxes(app.UIFigure);
            title(app.UIAxes_Data, 'Plot Against Distance')
            xlabel(app.UIAxes_Data, 'Distance (m)')
            ylabel(app.UIAxes_Data, '')
            zlabel(app.UIAxes_Data, '')
            app.UIAxes_Data.Position = [211 230 423 215];

            % Create TRACKSIMULATIONLabel
            app.TRACKSIMULATIONLabel = uilabel(app.UIFigure);
            app.TRACKSIMULATIONLabel.HorizontalAlignment = 'center';
            app.TRACKSIMULATIONLabel.FontSize = 18;
            app.TRACKSIMULATIONLabel.Position = [233 444 176 24];
            app.TRACKSIMULATIONLabel.Text = 'TRACK SIMULATION';

            % Create CheckBox_Speed
            app.CheckBox_Speed = uicheckbox(app.UIFigure);
            app.CheckBox_Speed.Text = '';
            app.CheckBox_Speed.Position = [52 391 25 22];

            % Create CarSpeedLabel
            app.CarSpeedLabel = uilabel(app.UIFigure);
            app.CarSpeedLabel.HorizontalAlignment = 'center';
            app.CarSpeedLabel.Position = [75 391 62 22];
            app.CarSpeedLabel.Text = 'Car Speed';

            % Create CheckBox_ResForce
            app.CheckBox_ResForce = uicheckbox(app.UIFigure);
            app.CheckBox_ResForce.Text = '';
            app.CheckBox_ResForce.Position = [52 349 25 22];

            % Create ResitiveForceLabel
            app.ResitiveForceLabel = uilabel(app.UIFigure);
            app.ResitiveForceLabel.HorizontalAlignment = 'center';
            app.ResitiveForceLabel.Position = [75 349 81 22];
            app.ResitiveForceLabel.Text = 'Resitive Force';

            % Create CheckBox_CheckBox_MotTorq
            app.CheckBox_CheckBox_MotTorq = uicheckbox(app.UIFigure);
            app.CheckBox_CheckBox_MotTorq.Text = '';
            app.CheckBox_CheckBox_MotTorq.Position = [52 323 25 22];

            % Create MotorTorqueLabel
            app.MotorTorqueLabel = uilabel(app.UIFigure);
            app.MotorTorqueLabel.HorizontalAlignment = 'center';
            app.MotorTorqueLabel.Position = [76 323 77 22];
            app.MotorTorqueLabel.Text = 'Motor Torque';

            % Create CheckBox_Accel
            app.CheckBox_Accel = uicheckbox(app.UIFigure);
            app.CheckBox_Accel.Text = '';
            app.CheckBox_Accel.Position = [52 374 25 22];

            % Create CarAccelerationLabel
            app.CarAccelerationLabel = uilabel(app.UIFigure);
            app.CarAccelerationLabel.HorizontalAlignment = 'center';
            app.CarAccelerationLabel.Position = [75 374 94 22];
            app.CarAccelerationLabel.Text = 'Car Acceleration';

            % Create STARTButton
            app.STARTButton = uibutton(app.UIFigure, 'push');
            app.STARTButton.ButtonPushedFcn = createCallbackFcn(app, @startButtonPushed, true);
            app.STARTButton.BackgroundColor = [0.3922 0.8314 0.0745];
            app.STARTButton.FontSize = 14;
            app.STARTButton.Position = [67 89 100 25];
            app.STARTButton.Text = 'START';

            % Create ENDButton
            app.ENDButton = uibutton(app.UIFigure, 'push');
            app.ENDButton.ButtonPushedFcn = createCallbackFcn(app, @endButtonPushed, true);
            app.ENDButton.BackgroundColor = [1 0 0];
            app.ENDButton.FontSize = 14;
            app.ENDButton.Position = [67 44 100 25];
            app.ENDButton.Text = 'END';

            % Create EXPORTDATAButton
            app.EXPORTDATAButton = uibutton(app.UIFigure, 'push');
            app.EXPORTDATAButton.ButtonPushedFcn = createCallbackFcn(app, @exportButtonPushed, true);
            app.EXPORTDATAButton.Position = [67 8 100 23];
            app.EXPORTDATAButton.Text = 'EXPORT DATA';

            % Create SpeedmsEditFieldLabel
            app.SpeedmsEditFieldLabel = uilabel(app.UIFigure);
            app.SpeedmsEditFieldLabel.HorizontalAlignment = 'right';
            app.SpeedmsEditFieldLabel.Position = [14 289 70 22];
            app.SpeedmsEditFieldLabel.Text = 'Speed (m/s)';

            % Create SpeedmsEditField
            app.SpeedmsEditField = uieditfield(app.UIFigure, 'numeric');
            app.SpeedmsEditField.Position = [99 289 90 22];

            % Create TimesEditFieldLabel
            app.TimesEditFieldLabel = uilabel(app.UIFigure);
            app.TimesEditFieldLabel.HorizontalAlignment = 'right';
            app.TimesEditFieldLabel.Position = [37 210 47 22];
            app.TimesEditFieldLabel.Text = 'Time (s)';

            % Create TimesEditField
            app.TimesEditField = uieditfield(app.UIFigure, 'numeric');
            app.TimesEditField.Position = [99 210 90 22];

            % Create PositionmEditFieldLabel
            app.PositionmEditFieldLabel = uilabel(app.UIFigure);
            app.PositionmEditFieldLabel.HorizontalAlignment = 'right';
            app.PositionmEditFieldLabel.Position = [16 249 68 22];
            app.PositionmEditFieldLabel.Text = 'Position (m)';

            % Create PositionmEditField
            app.PositionmEditField = uieditfield(app.UIFigure, 'numeric');
            app.PositionmEditField.Position = [99 249 90 22];

            % Create PowerWEditFieldLabel
            app.PowerWEditFieldLabel = uilabel(app.UIFigure);
            app.PowerWEditFieldLabel.HorizontalAlignment = 'right';
            app.PowerWEditFieldLabel.Position = [24 130 60 22];
            app.PowerWEditFieldLabel.Text = 'Power (W)';

            % Create PowerWEditField
            app.PowerWEditField = uieditfield(app.UIFigure, 'numeric');
            app.PowerWEditField.Position = [99 130 90 22];

            % Create EnergykJEditFieldLabel
            app.EnergykJEditFieldLabel = uilabel(app.UIFigure);
            app.EnergykJEditFieldLabel.HorizontalAlignment = 'right';
            app.EnergykJEditFieldLabel.Position = [20 169 64 22];
            app.EnergykJEditFieldLabel.Text = 'Energy (kJ)';

            % Create EnergykJEditField
            app.EnergykJEditField = uieditfield(app.UIFigure, 'numeric');
            app.EnergykJEditField.Position = [99 169 90 22];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: BACKButton
        function backButtonPushed(app, event)
            app.RunningFlag = false;
            % Launch the Home Page app
            trackYawApp = App_TrackYaw(app.VariablesInstance);
            trackYawApp.UIFigure.Visible = 'on';

            % Close the current app
            delete(app)
        end

        function initialisePlots(app, event)
            hold(app.UIAxes_Data, 'on');
            app.PlotHandles.Accel = plot(app.UIAxes_Data, NaN, NaN, 'DisplayName', 'Accel (m/s)');
            app.PlotHandles.Speed = plot(app.UIAxes_Data, NaN, NaN, 'DisplayName', 'Speed (m)');
            app.PlotHandles.Torque = plot(app.UIAxes_Data, NaN, NaN, 'DisplayName', 'Motor Torque (Nm)');
            app.PlotHandles.Res = plot(app.UIAxes_Data, NaN, NaN, 'DisplayName', 'Resistive Force (N)');
            hold(app.UIAxes_Data, 'off');
            legend(app.UIAxes_Data, 'show');
            grid(app.UIAxes_Data, 'on');

            hold(app.UIAxes_Map, 'on');
            app.PlotHandles.Map = plot(app.UIAxes_Map, app.x_map, app.y_map);
            app.PlotHandles.Point = scatter(app.UIAxes_Map, NaN, NaN,  'filled');
            hold(app.UIAxes_Map, 'off');
            grid(app.UIAxes_Map, 'on');
            axis(app.UIAxes_Map, 'equal');
        end

        function startButtonPushed(app, event)
            app.RunningFlag = true;
            start(app.UpdateFigures);
            while app.RunningFlag
                new_time = app.CommsInstance.readData();
                app.DynoInstance.simulate_track(new_time)
                
                drawnow limitrate; % Process callbacks and update UI
            end
        end

        % Button pushed function: ENDButton
        function endButtonPushed(app, event)
            app.RunningFlag = false;
            stop(app.UpdateFigures);
        end

        % Button pushed function: EXPORTDATAButton
        function exportButtonPushed(app, event)
            app.DynoInstance.export_base_data();
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
            if app.CheckBox_ResForce.Value
                data_range = app.DynoInstance.trackR_range(1000, 20);
                set(app.PlotHandles.Res, 'XData', pos_array, 'YData', data_range);
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

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Bottom Plot
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            differences = abs(app.distances - app.DynoInstance.curr_track_ind());
            [~, closestIndex] = min(differences);
            
            set(app.PlotHandles.Point, 'XData', [app.x_map(closestIndex)], 'YData', [app.y_map(closestIndex)])

            app.SpeedmsEditField.Value = app.DynoInstance.curr_speed();
            app.TimesEditField.Value = app.DynoInstance.curr_time();
            app.PositionmEditField.Value = app.DynoInstance.curr_pos();
            app.PowerWEditField.Value = app.DynoInstance.curr_power();
            app.EnergykJEditField.Value = app.DynoInstance.curr_energy();

            if app.DynoInstance.curr_pos() >= 16000
                app.RunningFlag = false;
                stop(app.UpdateFigures);
            end
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = App_TrackSim(variablesObj, trackObj)
            app.VariablesInstance = variablesObj;
            app.TrackInstance = trackObj;

            app.distances = [[0], trackObj.yawObj.dist_array1];
            [app.x_map, app.y_map] = trackObj.get_track_bounds();

            app.TrackInstance.clear_object()
            app.DynoInstance = DynoTrack(app.VariablesInstance, app.TrackInstance, [3,7,3,3, 5,5,3,3]);
            app.CommsInstance = Comms(app.VariablesInstance.nano_port);

            % Create UIFigure and components
            createComponents(app)

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

            % Update plots
            app.updateData();

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