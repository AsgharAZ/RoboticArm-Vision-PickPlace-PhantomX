% Function to compare actual angles with motor angles and determine error margin
function margin_error = error_estimator(actual_angles, motor_angles)
    % Initialize margin_error flag to false
    margin_error = false;
    
    % Loop through each angle (assuming 5 angles)
    for k = 1:5
        % Check if the absolute difference between motor angle and actual angle is less than 0.05
        if abs(motor_angles(k) - actual_angles(k)) < 0.05
            % If within margin, set margin_error to false
            margin_error = false;
        else
            % If outside margin for any angle, set margin_error to true and exit loop
            margin_error = true;
            break; % Exit loop since error detected
        end
    end
end