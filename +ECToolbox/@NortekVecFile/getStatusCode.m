function statusCode = getStatusCode(obj)
    structureId 	= 17;
    statusCodeRaw 	= obj.getDataArray(structureId,23,'uint8');
	% extract status codes
    statusCode      = statusCodeRaw;
end