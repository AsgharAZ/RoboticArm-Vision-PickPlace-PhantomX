function t = readLoad(arb,id)
% readLoad(arb,id) Reads the currently applied load on servomotor number id. 
% The arm does not have a torque sensor, so this value is determined based
% on the current consumption
% 
% If t is in 0~1023 then the load works to the CCW direction and if it is
% in 1024~2047 then it is in CW direction. For example, if t=512, it means
% load is detected in CCW direction and about 50% of maximum torque is
% exerted. 
    arb.flush();
    retval = arb.readdata(id, 40 , 2);
    t = typecast(uint8(retval.params),'uint16');            
end