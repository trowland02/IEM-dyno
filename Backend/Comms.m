classdef Comms < handle
    properties(Access = private)
        SerialObj
    end
    
    methods
        function obj = Comms(nano_port)
            obj.connect(nano_port, 115200);
        end
        
        function connect(obj, port, baudrate)
            obj.SerialObj = serialport(port, baudrate, "Timeout", 1/25000);
        end
        
        function data = readData(obj)
            % Read data from the Arduino
            try
                while true
                    data = read(obj.SerialObj, 4, "uint8");
                    if ~isempty(data) && numel(data) == 4
                        data = typecast(uint8(data), 'uint32');
                        return;
                    end
                end
            catch
                disp("Communication terminated.");
                obj.close();
            end
        end
        
        function close(obj)
            if ~isempty(obj.SerialObj)
                delete(obj.SerialObj);
                obj.SerialObj = [];
            end
        end
    end
end
