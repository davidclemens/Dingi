function disp(obj,varargin)
% disp  Displays dimension instance
%   DISP displays a dimension instance.
%
%   Syntax
%     DISP(obj)
%     DISP(__,'builtin')
%
%   Description
%     DISP(obj) displays the dimension instance obj.
%     DISP(__,'builtin') runs the builtin disp method.
%
%   Example(s)
%     DISP(obj)
%
%
%   Input Arguments
%     obj - Dimension
%       DataKit.Units.dimension
%         An instance of the DataKit.Units.dimension class.
%
%
%   Output Arguments
%
%
%   Name-Value Pair Arguments
%
%
%   See also DATAKIT.UNITS.DIMENSION
%
%   Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
%

    narginchk(1,2)
    if nargin == 1
        callBuiltin     = false;
    elseif nargin == 2
        validOptions    = {'builtin','dimension'};
        callBuiltin     = strcmp(validatestring(varargin{1},validOptions),'builtin');
    end

    if callBuiltin
        builtin('disp',obj);
        return
    end
    
    sz     	= size(obj);
    nDims	= ndims(obj);
    
    % Display header
    if obj.IsBaseDimension
        fprintf(['  %u',repmat('x%u',1,nDims - 1),' base <a href="matlab:help(''DataKit.Units.dimension'')">dimension</a>\n\n'],sz)
    else
        fprintf(['  %u',repmat('x%u',1,nDims - 1),' <a href="matlab:help(''DataKit.Units.dimension'')">dimension</a>\n\n'],sz)
    end
    
    % Display expression
    fprintf('Expression:\n\n')
	if obj.IsBaseDimension || ~isa(obj.Value,'DataKit.Units.dimension')
        displayStr = ['\t',obj.Name,'\n'];
	else
        displayStr = ['\t',obj.Name,' = ',obj.Value.Name,'\n\n'];
	end    
    fprintf(displayStr)
    
    % Display dimensionalites
    fprintf('\nDimensionalities:\n\n')
    displayStr = cellstr(cat(2,char(strcat(obj.Dimensions,{': '})),num2str(obj.Degrees)));
    fprintf('\t%s\n',displayStr{:})
end
