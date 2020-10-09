function velocity = getVelocity(obj)
    structureId     = 16;
    velRaw          = [obj.getDataArray(structureId,10:11,'int16'),...
                       obj.getDataArray(structureId,12:13,'int16'),...
                       obj.getDataArray(structureId,14:15,'int16')];
	% scale velocities
    velocity       	= velRaw.*obj.UserConfiguration.velocityScalingFaktor.*1e-3; % in m
    
	% TODO rotate velocities
end