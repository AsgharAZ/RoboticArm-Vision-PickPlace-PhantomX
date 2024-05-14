function [x,y,z,R,theta,phy] = FindPincher()
%Queries the current angles from Phantom X Pincher motor encoders and
%returns the current end-effector position and orientation in the specified
%order

    true_pos = arb.getpos();
    jointAngles = true_pos(1:4);
    % Below is the code of PinckerFK 
   % Function to calculate end-effector position and orientation for Phantom X Pincher
  
   % Extract joint angles
   theta1 = jointAngles(1);
   theta2 = jointAngles(2);
   theta3 = jointAngles(3);
   theta4 = jointAngles(4);
   % Homogeneous Transformation matrices using DH parameters
   T01 = dhTransform(0, pi/2, 0.04495, theta1);
   T12 = dhTransform(0.1035, 0, 0, theta2);
   T23 = dhTransform(0.10375, 0, 0, theta3);
   T34 = dhTransform(0.111, 0, 0, theta4);
   % Resultant transformation matrix
   T04 = T01 * T12 * T23 * T34;
   % Extract position and orientation from the transformation matrix
   x = T04(1, 4);
   y = T04(2, 4);
   z = T04(3, 4);
   R = T04(1:3, 1:3);
   % Calculate theta and phi from the rotation matrix
   phi = atan2(sqrt(R(1,3)^2 + R(2,3)^2), R(3,3));
   theta = atan2(R(2,3)/sin(phi), R(1,3)/sin(phi));
end

