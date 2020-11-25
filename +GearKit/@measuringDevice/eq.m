function bool = eq(a,b)
    
%     nA  = size(a,1);
%     nB  = size(b,1);
    
    
    % convert inputs if neccessary
    a = harmonizeInput(a);
    b = harmonizeInput(b);
    
    sA  = size(a);
    sB  = size(b);
    
    if sum(sA > 1) <= 1 && sum(sB > 1) <= 1
        a       = reshape(a,[],1);
        b       = reshape(b,1,[]);
        [a,b]	= ndgrid(a,b);
    else
        error('GearKit:measuringDevice:eq:matrixDimensionsDisagree',...
            'Matrix dimensions must agree.')
    end

    aType   = cat(1,a.Type);
    bType   = cat(1,b.Type);
    aSN     = {a.SerialNumber}';
    bSN     = {b.SerialNumber}';
    
    aHasUndefinedSN = strcmp(aSN,'') | strcmp(aSN,'<undefined>');
    bHasUndefinedSN = strcmp(bSN,'') | strcmp(bSN,'<undefined>');
    hasUndefinedSN	= aHasUndefinedSN | bHasUndefinedSN;

    if any(hasUndefinedSN)
        affectedMeasuringDevicesInA    = a(reshape(aHasUndefinedSN,size(a,1),size(a,2)));
        affectedMeasuringDevicesInA    = unique(cat(1,affectedMeasuringDevicesInA.Type));
        if isempty(affectedMeasuringDevicesInA)
            affectedMeasuringDevicesInA = '';
        end
        affectedMeasuringDevicesInB    = b(reshape(bHasUndefinedSN,size(a,1),size(a,2)));
        affectedMeasuringDevicesInB    = unique(cat(1,affectedMeasuringDevicesInB.Type));
        if isempty(affectedMeasuringDevicesInB)
            affectedMeasuringDevicesInB = '';
        end
        warning('GearKit:measuringDevice:eq:missingSerialNumber',...
            'Equality can''t be tested for at least 1 pair because a measuring device serial number is not defined. Returning ''false'' for that pair.\n\tA: %s\n\tB: %s',strjoin(cellstr(affectedMeasuringDevicesInA),', '),strjoin(cellstr(affectedMeasuringDevicesInB),', '))
    end
    
    bool                    = aType == bType & strcmp(aSN,bSN);
    bool(hasUndefinedSN)    = false;
    bool                    = reshape(bool,size(a,1),size(a,2));
end

function out = harmonizeInput(in)
    
    [~,validMeasuringDeviceTypes] = enumeration('GearKit.measuringDeviceType');
    if isa(in,'GearKit.measuringDevice')
        out = in;
    elseif isa(in,'cell')
        % First test if all device types in b are valid
        im  = ismember(in(:,1),validMeasuringDeviceTypes);
        
        % Convert b to a measuring device instance
        out = repmat(GearKit.measuringDevice,size(in,1),1);
        [out.Type]              = deal(GearKit.measuringDeviceType.undefined); % initialize
        [out(im).Type]          = in{im,1};
        [out(im).SerialNumber]	= in{im,2};
    end
end