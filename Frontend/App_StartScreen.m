classdef App_StartScreen < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure        matlab.ui.Figure
        CONTINUEButton  matlab.ui.control.Button
        Heading         matlab.ui.control.Label
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: CONTINUEButton
        function continueButtonPushed(app, event)
            % Launch the arduino init app
            arduinoInitApp = App_ArduinoInit();
            arduinoInitApp.UIFigure.Visible = 'on';

            % Close the current app
            delete(app)
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'MATLAB App';

            % Create Heading
            app.Heading = uilabel(app.UIFigure);
            app.Heading.HorizontalAlignment = 'center';
            app.Heading.FontSize = 14;
            app.Heading.Position = [52 214 538 138];
            app.Heading.Text = {'This Software is for use with the Imperial Shell Eco Marathon Team'; 'Ensure a risk assessment is in place before attempting to use the equipment'; ''; 'Before use please do the following:'; '- Ensure Arduino Nano is plugged into rotary encoder'; '- Ensure Arduino Due is plugged into Digital 1,2 and 3 of the Escon motor controller'; ''; 'PLEASE DO NOT YET PLUG LAPTOP INTO ANYTHING'};

            % Create CONTINUEButton
            app.CONTINUEButton = uibutton(app.UIFigure, 'push');
            app.CONTINUEButton.ButtonPushedFcn = createCallbackFcn(app, @continueButtonPushed, true);
            app.CONTINUEButton.Position = [271 108 100 23];
            app.CONTINUEButton.Text = 'CONTINUE';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = App_StartScreen

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

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