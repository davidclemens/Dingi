function obj = calculate(obj,varargin)
% CALCULATE
    
    % parse Name-Value pairs
%     optionName          = {'Downsample','RotateCoordinateSystem','DetrendFluxParameter','DetrendVerticalVelocity'}; % valid options (Name)
%     optionDefaultValue  = {false,false,false,false}; % default value (Value)
%     [Downsample,...
%      RotateCoordinateSystem,...
%      DetrendFluxParameter,...
%      DetrendVerticalVelocity,...
%     ]	= internal.stats.parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments


    obj = fit(obj);


end