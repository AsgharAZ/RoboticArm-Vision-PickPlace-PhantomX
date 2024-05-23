% Function to transform camera coordinates to world coordinates
function [world_coords] = cam_to_world_coords(cam_coords)
    % Display camera coordinates for checking
    cam_coords 
    
    % Define camera parameters
    fx = 1400;
    fy = 1400;
    u0 = 932;
    v0 = 526;
    s = 0;
    
    % Intrinsic transformation matrix
    Intrinsic_trans = [fx s u0 ; 0 fy v0 ; 0 0 1];
    
    % Initialize array to store (x,y) of world coordinates
    world_coords = zeros(2, length(cam_coords));
    
    % Depth of cube in camera coordinates
    Z_c = 660;
    
    % Loop over cube (x,y) to transform coordinates to real world
    for k = 1:length(cam_coords)
        % Transform points to camera coordinates
        pts_transformed_in_cam = inv(Intrinsic_trans) * [cam_coords{k}(1); cam_coords{k}(2); 1] * Z_c;
        pts_transformed_in_cam = [pts_transformed_in_cam; 1]; % Add homogeneous coordinate
        
        % Define transformation matrix from camera to world coordinates
        zc = 660;
        R_T_W = [1 0 0 0;
                 0 -1 0 0;
                 0 0 -1 zc;
                 0 0 0 1];
        
        % Apply transformation to obtain world coordinates
        final_ = R_T_W * pts_transformed_in_cam;
        world_coords(1, k) = final_(1);
        world_coords(2, k) = final_(2);
    end
end