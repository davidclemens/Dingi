classdef bitflag < DataKit.bitmask
    % Frontend
    properties (Dependent)
        EnumerationClassName char
        EnumerationMembers
        EnumerationMemberIds
    end
    
    % Backend
    properties (Access = private)
        EnumerationClassName_ char = ''
        Bitmask_ DataKit.bitmask = DataKit.bitmask.empty
    end
    properties (Access = private, Dependent)
        MaxEnumerationId
    end
    
    methods
        function obj = bitflag(enum,varargin)
            
            
            %   Syntax
            %     obj = bitflag(enum,A)
            %     obj = bitflag(enum,m,n)
            %     obj = bitflag(enum,i,j,flagId)
            %     obj = bitflag(enum,i,j,flagId,m,n)
            
            import DataKit.bitflag.validateEnumerationClassName
            
            narginchk(0,6)
            
            % Validate input ids if necessary
            switch nargin - 1
                case {-1,0,1,2}
                    % -1: Handled by superclass constructor: Return empty object
                    %  0: Handled by superclass constructor: Return empty bitflag
                    %  1: Handled by superclass constructor: Convert input array to bitflag array
                    %  2: Handled by superclass constructor: Initialize bitflag array of size m x n
                    %     with all flagId set to 0
                case {3,5}
                    %  3: Initialize bitflag array of size max(i(:)) x max(j(:)) and set bitflag
                    %     at index (i,j) to flagId
                    %  5: Initialize bitflag array of size m x n and set bitflag at index (i,j)
                    %     to flagId
                    
                    % Interpret the flag input correctly depending on the enumeration class
                    % name.
                    validEnumerationClassName = validateEnumerationClassName(enum);
                    varargin{3} = DataKit.bitflag.validateFlag(validEnumerationClassName,varargin{3});
            end
            
            % Call superclass constructor
            obj     = obj@DataKit.bitmask(varargin{:});
            
            % Set the enumeration class name
            obj.EnumerationClassName_ = validateEnumerationClassName(enum);
        end
    end
    
    % Overloaded methods
    methods
        disp(obj,varargin)
    end
    
    methods
        obj = setFlag(obj,flag,highlow,varargin)
    end
    
    methods (Access = private, Static)
        validEnumerationClassName = validateEnumerationClassName(enumerationClassName)
        validFlagId = validateFlag(enumerationClassName,flagId)
    end
    
    % Get methods
    methods
        function enumerationClassName = get.EnumerationClassName(obj)
            enumerationClassName = obj.EnumerationClassName_;
        end
        function enumerationMembers = get.EnumerationMembers(obj)
            info = DataKit.enum.core_listMembersInfo(obj.EnumerationClassName);
            enumerationMembers = cellstr(info{info{:,'Id'} > 0,'EnumerationMemberName'});
        end
        function enumerationMemberIds = get.EnumerationMemberIds(obj)
            enumerationMemberIds = DataKit.enum.listValidPropertyValues(obj.EnumerationClassName,'Id');
        end
        function maxEnumerationId = get.MaxEnumerationId(obj)
            maxEnumerationId = max(obj.EnumerationMemberIds);
        end
    end
    
    % Set methods
    methods
        function obj = set.EnumerationClassName(obj,value)
            if isempty(obj.EnumerationClassName_)
                % Allow setting the enumeration class name after instance creation if it
                % was initialized empty.
                validEnumerationClassName = obj.validateEnumerationClassName(value);
                obj.EnumerationClassName_ = validEnumerationClassName;
            else
                error('Dingi:DataKit:bitflag:setEnumerationClassName:immutableProperty',...
                    'The ''EnumerationClassName'' is immutable.')
            end
        end
    end
end