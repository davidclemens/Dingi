function varargout = detrend(obj,varargin)
% DETREND

	import internal.stats.parseArgs
    
    nargoutchk(0,1)
    
    % parse Name-Value pairs
    optionName          = {'DetrendFluxParameter','DetrendVerticalVelocity'}; % valid options (Name)
    optionDefaultValue  = {true,true}; % default value (Value)
    [detrendFluxParameter,...
     detrendVerticalVelocity,...
    ]	= parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments

	switch obj.DetrendingMethod
        case 'none'
            
        case 'mean removal'
            if detrendFluxParameter
                obj.FluxParameter_ = detrendMeanRemoval(obj.FluxParameter);
            end
            if detrendVerticalVelocity
                obj.W_ = detrendMeanRemoval(obj.Velocity(:,:,3));
            end
        case 'linear'
            if detrendFluxParameter
                obj.FluxParameter_ = detrendLinear(obj.FluxParameter);
            end
            if detrendVerticalVelocity
                obj.W_ = detrendLinear(obj.Velocity(:,:,3));
            end            
        case 'moving mean'
            window = obj.WindowLength/2;
            if detrendFluxParameter
                obj.FluxParameter_ = detrendMovingMean(obj.FluxParameter,window);
            end
            if detrendVerticalVelocity
                obj.W_ = detrendMovingMean(obj.Velocity(:,:,3),window);
            end 
        otherwise
            error('Dingi:GearKit:eddyFluxAnalysis:detrend:unknownDetrendingMethod',...
                '''%s'' is not a valid detrending method.',obj.DetrendingMethod)
	end
    
    if nargout == 1
        varargout{1} = obj;
    end
end