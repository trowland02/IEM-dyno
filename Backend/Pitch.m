classdef Pitch < handle
    properties
        distances
        elevation
        incline
    end
    
    methods
        % Constructor
        function obj = Pitch(file_path)
            T = readtable(file_path, 'VariableNamingRule', 'preserve'); % Read the csv file
            obj.distances = T.("Distance(m)"); % Extract the distances from the table
            obj.elevation = T.("Elevation(m)"); % Extract the elevations from the table
            
            % Calculate the incline
            dElevation = diff(obj.elevation);
            dDistance = diff(obj.distances);
            incline = atan(dElevation ./ dDistance);
            obj.incline = [incline; incline(1)]; % Concatenate the first incline at the end
        end
        
        % Return the incline and distances
        function [incline, distances] = get_incline_dist(obj)
            incline = obj.incline;
            distances = obj.distances;
        end
       
    end
end
