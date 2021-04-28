function obj = extendBitmask(obj,varargin)

    import DebuggerKit.Debugger.printDebugMessage
    
    % Extend bitmask if necessary
    dimensionMaxSubscript   	= obj.Size;
    newDimensionMaxSubscript    = cellfun(@(sub) max(sub(:)),varargin);
    nNewDimensions              = numel(varargin);
    nDimensions                 = numel(dimensionMaxSubscript);
    if nNewDimensions < nDimensions
        error('Dingi:DataKit:bitmask:setBit:subscriptsHaveInvalidDimensions',...
            'There should be %u subscripts provided. There were %u instead.',nDimensions,nNewDimensions)
    end
    if nNewDimensions > nDimensions || any(newDimensionMaxSubscript > dimensionMaxSubscript)
        printDebugMessage('Dingi:DataKit:bitmask:setBit:subscriptsExceedBitmaskSize',...
            'Warning',['Subscript exceeds bitmask size. The Bitmask is extended from %u',repmat('x%u',1,nDimensions - 1),' to %u',repmat('x%u',1,nNewDimensions - 1),'.'],dimensionMaxSubscript,newDimensionMaxSubscript)
        % extend bitmask
        newBitmask  = obj.Bits_;
        for dim = 1:nNewDimensions
            if dim > nDimensions
                dN = newDimensionMaxSubscript(dim) - 1;
            else
                dN = newDimensionMaxSubscript(dim) - dimensionMaxSubscript(dim);
            end
            if dN > 0
                newShape        = dimensionMaxSubscript;
                newShape(dim)   = dN;
                newBitmask    	= cat(dim,newBitmask,zeros(newShape));
            end
            dimensionMaxSubscript  = size(newBitmask); % update size
        end
        obj     = obj.setNum(newBitmask);
    end
end