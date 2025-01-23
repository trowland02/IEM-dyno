classdef App_HomePage < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                               matlab.ui.Figure
        HOMEPAGELabel                          matlab.ui.control.Label
        CarMassKgEditField                     matlab.ui.control.NumericEditField
        CarMassKgEditFieldLabel                matlab.ui.control.Label
        CarWheelbasemEditField                 matlab.ui.control.NumericEditField
        CarWheelbasemEditFieldLabel            matlab.ui.control.Label
        CarGearRatioEditField                  matlab.ui.control.NumericEditField
        CarGearRatioEditFieldLabel             matlab.ui.control.Label
        WheelDiammmEditField                   matlab.ui.control.NumericEditField
        WheelDiammmEditFieldLabel              matlab.ui.control.Label
        CarCoGHeightmEditField                 matlab.ui.control.NumericEditField
        CarCoGHeightmEditFieldLabel            matlab.ui.control.Label
        PeakTorqueNmEditField                  matlab.ui.control.NumericEditField
        PeakTorqueNmEditFieldLabel             matlab.ui.control.Label
        CoefDragEditField                      matlab.ui.control.NumericEditField
        CoefDragEditFieldLabel                 matlab.ui.control.Label
        CarCrossSecmEditField                  matlab.ui.control.NumericEditField
        CarCrossSecmEditFieldLabel             matlab.ui.control.Label
        TyreSlipCoeffdegkNEditField            matlab.ui.control.NumericEditField
        TyreSlipCoeffdegkNEditFieldLabel       matlab.ui.control.Label
        TyreFrictionNEditField                 matlab.ui.control.NumericEditField
        TyreFrictionNEditFieldLabel            matlab.ui.control.Label
        CarCoGLongRatiofromrearEditField       matlab.ui.control.NumericEditField
        CarCoGLongRatiofromrearEditFieldLabel  matlab.ui.control.Label
        TrackSimulationButton                  matlab.ui.control.Button
        ConstantTorqueButton                   matlab.ui.control.Button
        SetPropertiesButton                    matlab.ui.control.Button
        VariablesInstance                      Variables
    end

    % Component initialization
    methods (Access = private)
        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 778 484];
            app.UIFigure.Name = 'MATLAB App';

            % Create HOMEPAGELabel
            app.HOMEPAGELabel = uilabel(app.UIFigure);
            app.HOMEPAGELabel.HorizontalAlignment = 'center';
            app.HOMEPAGELabel.FontSize = 24;
            app.HOMEPAGELabel.Position = [301 435 176 32];
            app.HOMEPAGELabel.Text = 'HOME PAGE';

            % Create CarMassKgEditFieldLabel
            app.CarMassKgEditFieldLabel = uilabel(app.UIFigure);
            app.CarMassKgEditFieldLabel.HorizontalAlignment = 'right';
            app.CarMassKgEditFieldLabel.Position = [52 339 81 22];
            app.CarMassKgEditFieldLabel.Text = 'Car Mass (Kg)';

            % Create CarMassKgEditField
            app.CarMassKgEditField = uieditfield(app.UIFigure, 'numeric');
            app.CarMassKgEditField.Position = [148 339 100 22];

            % Create CarGearRatioEditFieldLabel
            app.CarGearRatioEditFieldLabel = uilabel(app.UIFigure);
            app.CarGearRatioEditFieldLabel.HorizontalAlignment = 'right';
            app.CarGearRatioEditFieldLabel.Position = [48 292 85 22];
            app.CarGearRatioEditFieldLabel.Text = 'Car Gear Ratio';

            % Create CarGearRatioEditField
            app.CarGearRatioEditField = uieditfield(app.UIFigure, 'numeric');
            app.CarGearRatioEditField.Position = [148 292 100 22];

            % Create WheelDiammmEditFieldLabel
            app.WheelDiammmEditFieldLabel = uilabel(app.UIFigure);
            app.WheelDiammmEditFieldLabel.HorizontalAlignment = 'right';
            app.WheelDiammmEditFieldLabel.Position = [33 240 100 22];
            app.WheelDiammmEditFieldLabel.Text = 'Wheel Diam (mm)';

            % Create WheelDiammmEditField
            app.WheelDiammmEditField = uieditfield(app.UIFigure, 'numeric');
            app.WheelDiammmEditField.Position = [148 240 100 22];

            % Create CarCoGHeightmEditFieldLabel
            app.CarCoGHeightmEditFieldLabel = uilabel(app.UIFigure);
            app.CarCoGHeightmEditFieldLabel.HorizontalAlignment = 'right';
            app.CarCoGHeightmEditFieldLabel.Position = [23 194 110 22];
            app.CarCoGHeightmEditFieldLabel.Text = 'Car CoG Height (m)';

            % Create CarCoGHeightmEditField
            app.CarCoGHeightmEditField = uieditfield(app.UIFigure, 'numeric');
            app.CarCoGHeightmEditField.Position = [148 194 100 22];

            % Create TyreSlipCoeffdegkNEditFieldLabel
            app.TyreSlipCoeffdegkNEditFieldLabel = uilabel(app.UIFigure);
            app.TyreSlipCoeffdegkNEditFieldLabel.HorizontalAlignment = 'right';
            app.TyreSlipCoeffdegkNEditFieldLabel.Position = [265 194 131 22];
            app.TyreSlipCoeffdegkNEditFieldLabel.Text = 'Tyre Slip Coeff (N/deg)';

            % Create TyreSlipCoeffdegkNEditField
            app.TyreSlipCoeffdegkNEditField = uieditfield(app.UIFigure, 'numeric');
            app.TyreSlipCoeffdegkNEditField.Position = [411 194 100 22];

            % Create PeakTorqueNmEditFieldLabel
            app.PeakTorqueNmEditFieldLabel = uilabel(app.UIFigure);
            app.PeakTorqueNmEditFieldLabel.HorizontalAlignment = 'right';
            app.PeakTorqueNmEditFieldLabel.Position = [296 339 100 22];
            app.PeakTorqueNmEditFieldLabel.Text = 'Peak Torque (Nm)';

            % Create PeakTorqueNmEditField
            app.PeakTorqueNmEditField = uieditfield(app.UIFigure, 'numeric');
            app.PeakTorqueNmEditField.Position = [411 339 100 22];

            % Create CoefDragEditFieldLabel
            app.CoefDragEditFieldLabel = uilabel(app.UIFigure);
            app.CoefDragEditFieldLabel.HorizontalAlignment = 'right';
            app.CoefDragEditFieldLabel.Position = [333 292 63 22];
            app.CoefDragEditFieldLabel.Text = 'Coef Drag ';

            % Create CoefDragEditField
            app.CoefDragEditField = uieditfield(app.UIFigure, 'numeric');
            app.CoefDragEditField.Position = [411 292 100 22];

            % Create CarCrossSecmEditFieldLabel
            app.CarCrossSecmEditFieldLabel = uilabel(app.UIFigure);
            app.CarCrossSecmEditFieldLabel.HorizontalAlignment = 'right';
            app.CarCrossSecmEditFieldLabel.Position = [293 240 103 22];
            app.CarCrossSecmEditFieldLabel.Text = 'Car Cross Sec (m)';

            % Create CarCrossSecmEditField
            app.CarCrossSecmEditField = uieditfield(app.UIFigure, 'numeric');
            app.CarCrossSecmEditField.Position = [411 240 100 22];

            % Create TyreLabel
            app.TyreFrictionNEditFieldLabel = uilabel(app.UIFigure);
            app.TyreFrictionNEditFieldLabel.HorizontalAlignment = 'right';
            app.TyreFrictionNEditFieldLabel.Position = [308 147 88 22];
            app.TyreFrictionNEditFieldLabel.Text = 'Tyre Friction (N)';

            % Create TyreFrictionNEditField
            app.TyreFrictionNEditField = uieditfield(app.UIFigure, 'numeric');
            app.TyreFrictionNEditField.Position = [411 147 100 22];

            % Create CarWheelbasemEditFieldLabel
            app.CarWheelbasemEditFieldLabel = uilabel(app.UIFigure);
            app.CarWheelbasemEditFieldLabel.HorizontalAlignment = 'right';
            app.CarWheelbasemEditFieldLabel.Position = [25 147 107 22];
            app.CarWheelbasemEditFieldLabel.Text = 'Car Wheelbase (m)';

            % Create CarWheelbasemEditField
            app.CarWheelbasemEditField = uieditfield(app.UIFigure, 'numeric');
            app.CarWheelbasemEditField.Position = [147 147 100 22];

            % Create CarCoGLongRatiofromrearEditFieldLabel
            app.CarCoGLongRatiofromrearEditFieldLabel = uilabel(app.UIFigure);
            app.CarCoGLongRatiofromrearEditFieldLabel.HorizontalAlignment = 'right';
            app.CarCoGLongRatiofromrearEditFieldLabel.Position = [23 194 110 22];
            app.CarCoGLongRatiofromrearEditFieldLabel.Text = 'Car CoG Height (m)';

            % Create CarCoGLongRatiofromrearEditField
            app.CarCoGLongRatiofromrearEditField = uieditfield(app.UIFigure, 'numeric');
            app.CarCoGLongRatiofromrearEditField.Position = [148 194 100 22];
            
            %%%%%%%%
            % ConstantTorqueButton
            %%%%%%%%
            app.ConstantTorqueButton = uibutton(app.UIFigure, 'push');
            app.ConstantTorqueButton.ButtonPushedFcn = createCallbackFcn(app, @ConstantTorqueButtonPushed, true);
            app.ConstantTorqueButton.FontSize = 18;
            app.ConstantTorqueButton.Position = [579 276 148 53];
            app.ConstantTorqueButton.Text = 'Constant Torque';

            %%%%%%%%
            % TrackSimulationButton
            %%%%%%%%
            app.TrackSimulationButton = uibutton(app.UIFigure, 'push');
            app.TrackSimulationButton.ButtonPushedFcn = createCallbackFcn(app, @TrackSimulationButtonPushed, true);
            app.TrackSimulationButton.FontSize = 18;
            app.TrackSimulationButton.Position = [579 182 148 58];
            app.TrackSimulationButton.Text = 'Track Simulation';

            %%%%%%%%
            % Create SetButton
            %%%%%%%%
            app.SetPropertiesButton = uibutton(app.UIFigure, 'push');
            app.SetPropertiesButton.ButtonPushedFcn = createCallbackFcn(app, @SetButtonPushed, true);
            app.SetPropertiesButton.FontSize = 14;
            app.SetPropertiesButton.Position = [191 69 164 37];
            app.SetPropertiesButton.Text = 'Set Properties';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end

        % Code that executes after component creation
        function startupFcn(app)
            % Set the edit fields to the default values
            app.CarWheelbasemEditField.Value = app.VariablesInstance.wheelbase;
            app.TyreFrictionNEditField.Value = app.VariablesInstance.tyre_res;
            app.CarCrossSecmEditField.Value = app.VariablesInstance.car_cross_section;
            app.CoefDragEditField.Value = app.VariablesInstance.coef_drag;
            app.PeakTorqueNmEditField.Value = app.VariablesInstance.Peak_torque;
            app.TyreSlipCoeffdegkNEditField.Value = app.VariablesInstance.tyre_slip_coeff_deg;
            app.CarCoGHeightmEditField.Value = app.VariablesInstance.car_cog_height;
            app.CarCoGLongRatiofromrearEditField.Value = app.VariablesInstance.car_cog_x;
            app.WheelDiammmEditField.Value = app.VariablesInstance.wheel_size;
            app.CarGearRatioEditField.Value = app.VariablesInstance.car_gear_ratio;
            app.CarMassKgEditField.Value = app.VariablesInstance.car_mass;
        end

        % Button pushed function: TrackSimulationButton
        function TrackSimulationButtonPushed(app, event)
            % Launch the Track Simulation app
            trackYawApp = App_TrackYaw(app.VariablesInstance);
            trackYawApp.UIFigure.Visible = 'on';

            % Close the current app
            delete(app)
        end

        % Button pushed function: TrackSimulationButton
        function ConstantTorqueButtonPushed(app, event)
            % Launch the Track Simulation app
            constSimApp = App_ConstSim(app.VariablesInstance);
            constSimApp.UIFigure.Visible = 'on';

            % Close the current app
            delete(app)
        end

        % Button pushed function: SetButton
        function SetButtonPushed(app, event)
            % Validate and update the properties of VariablesInstance with the values from the edit fields
            app.VariablesInstance.wheelbase = app.CarWheelbasemEditField.Value;
            app.VariablesInstance.tyre_res = app.TyreFrictionNEditField.Value;
            app.VariablesInstance.car_cross_section = app.CarCrossSecmEditField.Value;
            app.VariablesInstance.coef_drag = app.CoefDragEditField.Value;
            app.VariablesInstance.Peak_torque = app.PeakTorqueNmEditField.Value;
            app.VariablesInstance.tyre_slip_coeff_deg = app.TyreSlipCoeffdegkNEditField.Value;
            app.VariablesInstance.car_cog_height = app.CarCoGHeightmEditField.Value;
            app.VariablesInstance.car_cog_x = app.CarCoGLongRatiofromrearEditField.Value;
            app.VariablesInstance.wheel_size = app.WheelDiammmEditField.Value;
            app.VariablesInstance.car_gear_ratio = app.CarGearRatioEditField.Value;
            app.VariablesInstance.car_mass = app.CarMassKgEditField.Value;
            
            % Optionally display a message or update the UI to reflect the values have been set
            disp('Variables have been set.');
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = App_HomePage(variablesObj)
            
            app.VariablesInstance = variablesObj;
            
            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn);

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end