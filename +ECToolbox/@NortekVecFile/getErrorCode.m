function errorCode = getErrorCode(obj)
    structureId 	= 17;
    errorCodeRaw 	= obj.getDataArray(structureId,22,'uint8');
	% extract error codes
    errorCode       = errorCodeRaw;
end