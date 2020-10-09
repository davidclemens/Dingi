function obj = detrend(obj,varargin)
% DETREND

                        
    % parse Name-Value pairs
    optionName          = {'DetrendFluxParameter','DetrendVerticalVelocity'}; % valid options (Name)
    optionDefaultValue  = {true,true}; % default value (Value)
    [DetrendFluxParameter,...
     DetrendVerticalVelocity,...
    ]	= internal.stats.parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments

	switch obj.detrendingMethod
        case 'none'
            
        case 'mean removal'
            if DetrendFluxParameter
                obj.fluxParameter_ = detrendMeanRemoval(obj.fluxParameter);
            end
            if DetrendVerticalVelocity
                obj.w_ = detrendMeanRemoval(obj.velocity(:,:,3));
            end
        case 'linear'
            if DetrendFluxParameter
                obj.fluxParameter_ = detrendLinear(obj.fluxParameter);
            end
            if DetrendVerticalVelocity
                obj.w_ = detrendLinear(obj.velocity(:,:,3));
            end            
        case 'moving mean'
            window = round(1*obj.windowN);
            if DetrendFluxParameter
                obj.fluxParameter_ = detrendMovingMean(obj.fluxParameter,window);
            end
            if DetrendVerticalVelocity
                obj.w_ = detrendMovingMean(obj.velocity(:,:,3),window);
            end 
        otherwise
            error('GearKit:eddyFluxAnalysis:detrend:unknownDetrendingMethod',...
                '''%s'' is not a valid detrending method.',obj.detrendingMethod)
	end
end