classdef App_TrackYaw < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        BACKButton                    matlab.ui.control.Button
        UIAxes1                       matlab.ui.control.UIAxes
        UIAxes2                       matlab.ui.control.UIAxes
        UIAxes3                       matlab.ui.control.UIAxes
        DiscritToleranceSlider        matlab.ui.control.Slider
        DiscritToleranceSliderLabel   matlab.ui.control.Label
        StraightToleranceSlider       matlab.ui.control.Slider
        StraightToleranceSliderLabel  matlab.ui.control.Label
        StraightLengthSlider          matlab.ui.control.Slider
        StraightLengthSliderLabel     matlab.ui.control.Label
        AverageWindowSlider           matlab.ui.control.Slider
        AverageWindowSliderLabel      matlab.ui.control.Label
        ClockwiseCheckBox             matlab.ui.control.CheckBox
        TrackLengthEditField          matlab.ui.control.NumericEditField
        TrackLengthEditFieldLabel     matlab.ui.control.Label
        StartxEditField               matlab.ui.control.NumericEditField
        StartxEditFieldLabel          matlab.ui.control.Label
        StartyEditField               matlab.ui.control.NumericEditField
        StartyEditFieldLabel          matlab.ui.control.Label
        DoneButton                    matlab.ui.control.Button
        VariablesInstance             Variables % Instance of Variables class
        TrackInstance                 Track % Instance of Track class
        x_map
        y_map
        dist1
        dist2
        distances
        radii
        yaw1
        yaw2
        yaw_angles
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 641 389];
            app.UIFigure.Name = 'MATLAB App';

            % Create BACKButton
            app.BACKButton = uibutton(app.UIFigure, 'push');
            app.BACKButton.ButtonPushedFcn = createCallbackFcn(app, @backButtonPushed, true);
            app.BACKButton.FontSize = 10;
            app.BACKButton.Position = [12 356 55 24];
            app.BACKButton.Text = 'BACK';

            % Create UIAxes2_2
            app.UIAxes1 = uiaxes(app.UIFigure);
            title(app.UIAxes1, 'Yaw Angle along Track')
            xlabel(app.UIAxes1, 'Distance along track (m)')
            ylabel(app.UIAxes1, 'Yaw Angle (rad)')
            zlabel(app.UIAxes1, '')
            app.UIAxes1.Position = [12 160 300 108];

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.UIFigure);
            title(app.UIAxes2, 'Track Map')
            xlabel(app.UIAxes2, 'X')
            ylabel(app.UIAxes2, 'Y')
            zlabel(app.UIAxes2, '')
            app.UIAxes2.Position = [331 160 300 197];

            % Create UIAxes3
            app.UIAxes3 = uiaxes(app.UIFigure);
            title(app.UIAxes3, 'Corner Radii')
            xlabel(app.UIAxes3, 'Distance along track (m)')
            ylabel(app.UIAxes3, 'Radius (m)')
            zlabel(app.UIAxes3, '')
            app.UIAxes3.Position = [21 267 300 108];
            
            %%%%%%%%
            % Create DiscritToleranceSliderLabel
            %%%%%%%%
            app.DiscritToleranceSliderLabel = uilabel(app.UIFigure);
            app.DiscritToleranceSliderLabel.HorizontalAlignment = 'right';
            app.DiscritToleranceSliderLabel.Position = [21 127 57 30];
            app.DiscritToleranceSliderLabel.Text = {'Discritise'; 'Tolerance'};
            % Create DiscritToleranceSlider
            app.DiscritToleranceSlider = uislider(app.UIFigure);
            app.DiscritToleranceSlider.Limits = [0.27 0.33];
            app.DiscritToleranceSlider.MajorTicks = [0.27 0.29 0.31 0.33];
            app.DiscritToleranceSlider.MajorTickLabels = {'0.27', '0.29', '0.31', '0.33'};
            app.DiscritToleranceSlider.ValueChangedFcn = createCallbackFcn(app, @DiscritSliderValueChanged, true);
            app.DiscritToleranceSlider.MinorTicks = [0.27 0.275 0.28 0.285 0.29 0.295 0.3 0.305 0.31 0.315 0.32 0.325 0.33];
            app.DiscritToleranceSlider.Position = [99 144 92 3];
            app.DiscritToleranceSlider.Value = 0.27;
            
            %%%%%%%%
            % Create StraightToleranceSliderLabel
            %%%%%%%%
            app.StraightToleranceSliderLabel = uilabel(app.UIFigure);
            app.StraightToleranceSliderLabel.HorizontalAlignment = 'right';
            app.StraightToleranceSliderLabel.Position = [228 127 57 30];
            app.StraightToleranceSliderLabel.Text = {'Straight'; 'Tolerance'};
            % Create StraightToleranceSlider
            app.StraightToleranceSlider = uislider(app.UIFigure);
            app.StraightToleranceSlider.Limits = [4 12];
            app.StraightToleranceSlider.MajorTicks = [4 6 8 10 12];
            app.StraightToleranceSlider.MajorTickLabels = {'4', '6', '8', '10', '12'};
            app.StraightToleranceSlider.ValueChangedFcn = createCallbackFcn(app, @StrightTolSliderValueChanged, true);
            app.StraightToleranceSlider.MinorTicks = [4 5 6 7 8 9 10 11 12];
            app.StraightToleranceSlider.Position = [306 144 99 3];
            app.StraightToleranceSlider.Value = 4;

            %%%%%%%%
            % Create StraightLengthSliderLabel
            %%%%%%%%
            app.StraightLengthSliderLabel = uilabel(app.UIFigure);
            app.StraightLengthSliderLabel.HorizontalAlignment = 'right';
            app.StraightLengthSliderLabel.Position = [460 127 47 30];
            app.StraightLengthSliderLabel.Text = {'Straight'; 'Length'};
            % Create StraightLengthSlider
            app.StraightLengthSlider = uislider(app.UIFigure);
            app.StraightLengthSlider.Limits = [40 90];
            app.StraightLengthSlider.MajorTicks = [40 50 60 70 80 90];
            app.StraightLengthSlider.MajorTickLabels = {'40', '50', '60', '70', '80', '90'};
            app.StraightLengthSlider.ValueChangedFcn = createCallbackFcn(app, @StrightLenSliderValueChanged, true);
            app.StraightLengthSlider.MinorTicks = [40 45 50 55 60 65 70 75 80 85 90];
            app.StraightLengthSlider.Position = [528 144 99 3];
            app.StraightLengthSlider.Value = 40;

            %%%%%%%%
            % Create AverageWindowSliderLabel
            %%%%%%%%
            app.AverageWindowSliderLabel = uilabel(app.UIFigure);
            app.AverageWindowSliderLabel.HorizontalAlignment = 'right';
            app.AverageWindowSliderLabel.Position = [495 64 49 30];
            app.AverageWindowSliderLabel.Text = {'Average'; 'Window'};
            % Create AverageWindowSlider
            app.AverageWindowSlider = uislider(app.UIFigure);
            app.AverageWindowSlider.Limits = [5 11];
            app.AverageWindowSlider.MajorTicks = [5 7 9 11];
            app.AverageWindowSlider.ValueChangedFcn = createCallbackFcn(app, @AvgWindowSliderValueChanged, true);
            app.AverageWindowSlider.MinorTicks = [5 7 9 11];
            app.AverageWindowSlider.Position = [565 81 60 3];
            app.AverageWindowSlider.Value = 5;
            
            %%%%%%%%
            % Create ClockwiseCheckBox
            %%%%%%%%
            app.ClockwiseCheckBox = uicheckbox(app.UIFigure);
            app.ClockwiseCheckBox.Text = 'Clockwise';
            app.ClockwiseCheckBox.ValueChangedFcn = createCallbackFcn(app, @ClockwiseCheckboxChanged, true);
            app.ClockwiseCheckBox.Position = [20 61 80 22];
            
            %%%%%%%%
            % Create TrackLengthEditFieldLabel
            %%%%%%%%
            app.TrackLengthEditFieldLabel = uilabel(app.UIFigure);
            app.TrackLengthEditFieldLabel.HorizontalAlignment = 'right';
            app.TrackLengthEditFieldLabel.Position = [109 61 74 22];
            app.TrackLengthEditFieldLabel.Text = 'Track Length';
            % Create TrackLengthEditField
            app.TrackLengthEditField = uieditfield(app.UIFigure, 'numeric');
            app.TrackLengthEditField.ValueChangedFcn = createCallbackFcn(app, @TrackLengthInputChanged, true);
            app.TrackLengthEditField.Position = [198 61 44 22];

            %%%%%%%%
            % Create StartxEditFieldLabel
            %%%%%%%%
            app.StartxEditFieldLabel = uilabel(app.UIFigure);
            app.StartxEditFieldLabel.HorizontalAlignment = 'right';
            app.StartxEditFieldLabel.Position = [263 61 40 22];
            app.StartxEditFieldLabel.Text = 'Start x';
            % Create StartxEditField
            app.StartxEditField = uieditfield(app.UIFigure, 'numeric');
            app.StartxEditField.ValueChangedFcn = createCallbackFcn(app, @StartXInputChanged, true);
            app.StartxEditField.Position = [318 61 44 22];
            
            %%%%%%%%
            % Create StartyEditFieldLabel
            %%%%%%%%
            app.StartyEditFieldLabel = uilabel(app.UIFigure);
            app.StartyEditFieldLabel.HorizontalAlignment = 'right';
            app.StartyEditFieldLabel.Position = [384 61 40 22];
            app.StartyEditFieldLabel.Text = 'Start y';
            % Create StartyEditField
            app.StartyEditField = uieditfield(app.UIFigure, 'numeric');
            app.StartyEditField.ValueChangedFcn = createCallbackFcn(app, @StartYInputChanged, true);
            app.StartyEditField.Position = [439 61 44 22];

            %%%%%%%%
            % Create DoneButton
            %%%%%%%%
            app.DoneButton = uibutton(app.UIFigure, 'push');
            app.DoneButton.ButtonPushedFcn = createCallbackFcn(app, @DoneButtonPushed, true);
            app.DoneButton.Position = [274 21 100 23];
            app.DoneButton.Text = 'Proceed to Test';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    
        % Code that executes after component creation
        function startupFcn(app) 
            % Initialize an instance of the Track class
            app.TrackInstance = Track;

            % Set the edit fields to the default values
            app.DiscritToleranceSlider.Value = app.VariablesInstance.track_tolerance;
            app.StraightToleranceSlider.Value = app.VariablesInstance.straight_tol;
            app.StraightLengthSlider.Value = app.VariablesInstance.straight_len;
            app.AverageWindowSlider.Value = app.VariablesInstance.window_size;
            app.ClockwiseCheckBox.Value = app.VariablesInstance.track_clockwise;
            app.TrackLengthEditField.Value = app.VariablesInstance.track_length;
            app.StartxEditField.Value = app.VariablesInstance.starting_point(1);
            app.StartyEditField.Value = app.VariablesInstance.starting_point(2);

            app.refreshPlot()
        end

        % Button pushed function: BACKButton
        function backButtonPushed(app, event)
            % Launch the Home Page app
            homePageApp = App_HomePage(app.VariablesInstance);
            homePageApp.UIFigure.Visible = 'on';

            % Close the current app
            delete(app)
        end

        % Button pushed function: TrackSimulationButton
        function DoneButtonPushed(app, event)
            % Launch the Track Simulation app
            trackSimApp = App_TrackSim(app.VariablesInstance, app.TrackInstance);
            trackSimApp.UIFigure.Visible = 'on';

            % Close the current app
            delete(app)
        end

        function refreshPlot(app)
            app.TrackInstance.analyseTrack(app.VariablesInstance);
            [app.x_map, app.y_map, app.dist1, app.dist2, app.distances, app.radii, app.yaw1, app.yaw2, app.yaw_angles] = app.TrackInstance.get_plot_parameters();
            % Clear current axes
            cla(app.UIAxes1);
            cla(app.UIAxes2);
            cla(app.UIAxes3);
            
            % Plot the Yaw Angle along Track on UIAxes1
            plot(app.UIAxes1, app.dist2, app.yaw2);
            hold(app.UIAxes1, 'on'); % Keep the plot for adding scatter
            scatter(app.UIAxes1, app.distances, app.yaw_angles, "filled");
            plot(app.UIAxes1, app.dist1, app.yaw1, 'Color', 'red');
            hold(app.UIAxes1, 'off'); % Release the plot for further updates
            xlim(app.UIAxes1, [0 app.VariablesInstance.track_length])
            grid(app.UIAxes1, 'on');

            % Plot the Track Map on UIAxes3
            plot(app.UIAxes3, app.distances, app.radii);
            grid(app.UIAxes3, 'on');
            
            % Plot the Track Map on UIAxes3
            plot(app.UIAxes2, app.x_map, app.y_map);
            hold(app.UIAxes2, 'on'); % Keep the plot for adding scatter
            scatter(app.UIAxes2, [app.VariablesInstance.starting_point(1)], [app.VariablesInstance.starting_point(2)], "filled");
            hold(app.UIAxes2, 'off'); % Release the plot for further updates
            grid(app.UIAxes2, 'on');
            axis(app.UIAxes2, 'equal');
            
            % Optionally, update other components or display messages
            disp('Plots updated.');
        end
    end

    % Callbacks that discretise sliders
    methods (Access = private)
        function DiscritSliderValueChanged(app, event)
            roundedValue = round(app.DiscritToleranceSlider.Value/0.005);
            roundedValue = min(max(50, roundedValue), 60);
            app.DiscritToleranceSlider.Value = roundedValue*0.005;
            app.VariablesInstance.track_tolerance = app.DiscritToleranceSlider.Value;
            app.refreshPlot()
        end

        function StrightTolSliderValueChanged(app, event)
            roundedValue = round(app.StraightToleranceSlider.Value);
            roundedValue = min(max(4, roundedValue), 12);
            app.StraightToleranceSlider.Value = roundedValue;
            app.VariablesInstance.straight_tol = app.StraightToleranceSlider.Value;
            app.refreshPlot()
        end

        function StrightLenSliderValueChanged(app, event)
            roundedValue = round(app.StraightLengthSlider.Value/5);
            roundedValue = min(max(8, roundedValue), 18);
            app.StraightLengthSlider.Value = roundedValue*5;
            app.VariablesInstance.straight_len = app.StraightLengthSlider.Value;
            app.refreshPlot()
        end

        function AvgWindowSliderValueChanged(app, event)
            roundedValue = round((app.AverageWindowSlider.Value+1)/2);
            roundedValue = min(max(3, roundedValue), 6);
            app.AverageWindowSlider.Value = ((roundedValue*2)-1);
            app.VariablesInstance.window_size = app.AverageWindowSlider.Value;
            app.refreshPlot()
        end
        
        function TrackLengthInputChanged(app, event)
            app.VariablesInstance.track_length = app.TrackLengthEditField.Value;
            app.refreshPlot()
        end

        function ClockwiseCheckboxChanged(app, event)
            app.VariablesInstance.track_clockwise = app.ClockwiseCheckBox.Value;
            app.refreshPlot()
        end

        function StartXInputChanged(app, event)
            app.VariablesInstance.starting_point(1) = app.StartxEditField.Value;
            app.refreshPlot()
        end

        function StartYInputChanged(app, event)
            app.VariablesInstance.starting_point(2) = app.StartyEditField.Value;
            app.refreshPlot()
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = App_TrackYaw(variablesObj)

            % Store the passed Variables object
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