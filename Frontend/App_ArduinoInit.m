classdef App_ArduinoInit < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                     matlab.ui.Figure
        Heading                      matlab.ui.control.Label
        DueSignal                    matlab.ui.control.Button
        ConnectArduinoDueLabel       matlab.ui.control.Label
        NanoSignal                   matlab.ui.control.Button
        ConnectArduinoNanoLabel      matlab.ui.control.Label
        ContinueButton               matlab.ui.control.Button
        VariablesInstance            Variables
        UpdatePorts
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
            app.Heading.Position = [75 337 491 34];
            app.Heading.Text = {'This Software is for use with the Imperial Shell Eco Marathon Team'; 'Ensure a risk assessment is in place before attempting to use the equipment'};


            % Create ConnectArduinoNanoLabel
            app.ConnectArduinoNanoLabel = uilabel(app.UIFigure);
            app.ConnectArduinoNanoLabel.Position = [116 240 127 22];
            app.ConnectArduinoNanoLabel.Text = 'Connect Arduino Nano';

            % Create NanoSignal
            app.NanoSignal = uibutton(app.UIFigure, 'push');
            app.NanoSignal.BackgroundColor = [1 0 0];
            app.NanoSignal.Position = [130 221 100 23];
            app.NanoSignal.Text = 'Not Connected';

            % Create ConnectArduinoDueLabel
            app.ConnectArduinoDueLabel = uilabel(app.UIFigure);
            app.ConnectArduinoDueLabel.Position = [397 240 120 22];
            app.ConnectArduinoDueLabel.Text = 'Connect Arduino Due';

            % Create DueSignal
            app.DueSignal = uibutton(app.UIFigure, 'push');
            app.DueSignal.BackgroundColor = [1 0 0];
            app.DueSignal.Position = [407 221 100 23];
            app.DueSignal.Text = 'Not Connected';

            % Create CONTINUEButton
            app.ContinueButton = uibutton(app.UIFigure, 'push');
            app.ContinueButton.ButtonPushedFcn = createCallbackFcn(app, @continueButtonPushed, true);
            app.ContinueButton.Position = [271 112 100 23];
            app.ContinueButton.Text = 'CONTINUE';
            app.ContinueButton.Enable = "off";

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % Callbacks that handle component events
    methods (Access = private)
        % Button pushed function: CONTINUEButton
        function continueButtonPushed(app, event)
            % Launch the Home Page app
            homePageApp = App_HomePage(app.VariablesInstance);
            homePageApp.UIFigure.Visible = 'on';

            % Close the current app
            delete(app)
        end

        function checkPorts(app)
            availablePorts = serialportlist("available");
            nano_connected = true;
            due_connected = true;
            % for i = 1:length(availablePorts)
            %     port = availablePorts(i);
            %     if ~nano_connected
            %         if contains(port, "/dev/tty.usbserial") 
            %             app.VariablesInstance.nano_port = port;
            %             app.NanoSignal.BackgroundColor = [0 1 0];
            %             app.NanoSignal.Text = 'Connected';
            %             nano_connected = true;
            %         end
            %     end
            % 
            %     if ~due_connected
            %         if contains(port, "/dev/tty.usbmodem")
            %             app.VariablesInstance.due_port = port;
            %             app.DueSignal.BackgroundColor = [0 1 0];
            %             app.DueSignal.Text = 'Connected';
            %             due_connected = true;
            %         end
            %     end
            % end

            if ~nano_connected
                app.VariablesInstance.nano_port = [];
                app.NanoSignal.BackgroundColor = [1 0 0];
                app.NanoSignal.Text = 'Not Connected';
            end

            if ~due_connected
                app.VariablesInstance.due_port = [];
                app.DueSignal.BackgroundColor = [1 0 0];
                app.DueSignal.Text = 'Not Connected';
            end

            if due_connected && nano_connected
                app.ContinueButton.Enable = "on";
            else
                app.ContinueButton.Enable = "off";
            end
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = App_ArduinoInit

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Initialize an instance of the Variables class
            app.VariablesInstance = Variables;

            app.UpdatePorts = timer('ExecutionMode', 'fixedRate', ...
                        'Period', 0.3, ... % Adjust the period as needed
                        'TimerFcn', @(src, event)checkPorts(app));

            start(app.UpdatePorts);

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)
            if isvalid(app.UpdatePorts)
                stop(app.UpdatePorts);
                delete(app.UpdatePorts);
            end
            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end