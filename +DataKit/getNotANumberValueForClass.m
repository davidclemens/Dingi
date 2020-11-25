function value = getNotANumberValueForClass(class,varargin)

    narginchk(1,2)
    if nargin == 1
        shape	= ones(1,2);
    elseif nargin == 2
        shape   = varargin{1};
        shape   = shape(:)';
        if numel(shape) == 1
            shape   = cat(2,shape,1);
        end
    end
    shapeAsCell = num2cell(shape,1);
    
    if ~(ischar(class) || iscellstr(class)) || ~isvector(class) || size(class,1) ~= 1
        error('DataKit:getNotANumberValueForClass:invalidClassDataType',...
            'The input class has to be a char vector or cellstr.')
    elseif ischar(class)
        class = cellstr(class);
    end
    
    nClass  = numel(class);
    value   = cell(1,nClass);
    for c = 1:nClass
        switch class{c}
            case {'double','single'}
                value{c} = NaN(shapeAsCell{:},class{c});
            case 'datetime'
                value{c} = NaT(shapeAsCell{:});
            case {'int8','uint8','int16','uint16','int32','uint32','int64','uint64'}
                value{c} = zeros(shapeAsCell{:},class{c});
            otherwise
                error('DataKit:getNotANumberValueForClass:invalidClass',...
                    '''%s'' is not a valid class.',class{c})
        end
    end
end