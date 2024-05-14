% jA1 = [0 pi/2 pi pi/3];
% jA2 = [pi/2 0 pi/4 pi];
% jA3 = [pi/3 pi 0 3*pi/4];
function [] = pinchermodel2(jA)
configNow = jA;
dhparams = [0 pi/2 0.04495 jA(1);
           0.1035 0 0 jA(2);
           0.10375 0 0 jA(3);
           0.111 0 0 jA(4)];
numJoints = size(dhparams,1);
% Create a rigid body tree object.
robot = rigidBodyTree;
% Create a model of the robot using DH parameters.
% Create a cell array for the rigid body object, and another for the joint
% objects. Iterate through the DH parameters performing this process:
% 1. Create a rigidBody object with a unique name.
% 2. Create and name a revolute rigidBodyJoint object.
% 3. Use setFixedTransform to specify the body-to-body transformation of the
% joint using DH parameters.
% 4. Use addBody to attach the body to the rigid body tree.
bodies = cell(numJoints,1);
joints = cell(numJoints,1);
for i = 1:numJoints
   bodies{i} = rigidBody(['body' num2str(i)]);
   joints{i} = rigidBodyJoint(['jnt' num2str(i)],"revolute");
   setFixedTransform(joints{i},dhparams(i,:),"dh");
   bodies{i}.Joint = joints{i};
   if i == 1 % Add first body to base
       addBody(robot,bodies{i},"base")
   else % Add current body to previous body by name
       addBody(robot,bodies{i},bodies{i-1}.Name)
   end
end
% Verify that your robot has been built properly by using the showdetails or
% show function. The showdetails function lists all the bodies of the robot
% in the MATLAB® command window. The show function displays the robot with
% a specified configuration (home by default).
showdetails(robot)
figure(Name="Phantom X Pincher")
show(robot);
%% Forward Kinematics for different configurations
% Enter joint angles in the matrix below in radians
% configNow = [pi/3,pi/3,pi/3,pi/3]; assigned above already
% Display robot in provided configuration
config = homeConfiguration(robot);
for i = 1:numJoints
   config(i).JointPosition = configNow(i);
end
show(robot,config);
% Determine the pose of end-effector in provided configuration
poseNow = getTransform(robot,config,"body4");
% Display position and orientation of end-effector
clc;
disp('The position of end-effector is:');
disp('');
disp(['X: ', num2str(poseNow(1,4))]);
disp('');
disp(['Y: ', num2str(poseNow(2,4))]);
disp('');
disp(['Z: ', num2str(poseNow(3,4))]);
disp(' ');
disp(['R: ']);
poseNow(1:3,1:3)
disp(' ');
disp('The orientation angle is given with respect to the x-axis of joint 2:');
disp('');
poseNow01 = getTransform(robot,config,"body1");
R14 = poseNow01(1:3,1:3)'*poseNow(1:3,1:3);
angle = rad2deg(atan2(R14(2,1),R14(1,1)));
disp(['Angle: ',num2str(angle), ' degrees.']);