function obj = fit(obj,varargin)
% FIT

    fitObj      = cell(obj.NFits,1);
    FitGOF      = cell(obj.NFits,1);
    FitOutput   = cell(obj.NFits,1);
    for ff = 1:obj.NFits
        % Get data pool & variable indices
        dp      = obj.PoolIndex(ff);
        var     = obj.VariableIndex(ff);
        
        % Fetch data
        data    = fetchData(obj.Bigo.data,[],[],[],[],dp,var,...
                    'ForceCellOutput',  false,...
                    'GroupBy',          'Variable');
        
        % Convert from duration to the set 'TimeUnit' for the fit
        xData   = obj.TimeUnitFunction(data.IndepData{1} - obj.FitOriginTime(ff));
        yData   = data.DepData;
        
        % Data is excluded from fitting if it has manually been marked as
        % rejected or if it falls outside the FitInterval.
        exclude     = isFlag(data.Flags,'ExcludeFromFit');        
        
        % Remove NaNs for the fit
        maskNaN = isnan(xData) | isnan(yData);
        xData   = xData(~maskNaN);
        yData   = yData(~maskNaN);
        exclude	= exclude(~maskNaN);                
        
        switch obj.FitType
            case 'linear'
                FitType  	= fittype('k*t + Coff',...
                                'dependent',        'C',...
                                'independent',		't');
                fitOptions	= fitoptions(...
                                'Method',			'NonlinearLeastSquares',...
                                'Robust',           'LAR',...
                                'StartPoint',		[rand(1)	rand(1)	],...
                                'Lower',			[-inf      -inf     ],...
                                'Upper',			[ inf       inf     ],...
                                'Display',			'off',...
                                'Normalize',        'off',...
                                'Exclude',          exclude);
            case 'sigmoidal'
%                 error('Dingi:AnalysisKit:bigoFluxAnalysis:fit:notImplementedYet',...
%                 'Not fully implemented yet.')
                %                   R2  kMag ResMag dCMag Brushed
                UIQFlag         = [ 0   0    0      0     1     ];  % initialize
                    
                FitType  	= fittype('Cmax/(1 + exp(-k*(t - t0))) + Coff',...
                                'dependent',        'C',...
                                'independent',		't');
                LM = 2e3;
                %               Cmax        k       t0      Coff
                FitLimits   = [ LM          LM      NaN     LM    	; ...   % upper limit
                                LM/4        rand(1)	NaN     rand(1)	; ...   % start points
                                0          -LM      NaN    -LM     	];      % lower limit

                % Evaluate if concentration increases or decreases
                kDir	= sum(yData(find(~exclude,2,'last'))) - sum(yData(find(~exclude,2,'first'))) > 0;	% true if concentration increases
                
                if kDir                                 % concentration increases
                    FitLimits(:,3)  = [LM;rand(1);0];
                else                                    % concentration decreases
                    FitLimits(:,3)  = [0;-rand(1);-LM];
                end

                fitOptions	= fitoptions(...
                                'Method',			'NonlinearLeastSquares',...
                                'Upper',			FitLimits(1,:),...
                                'StartPoint',		FitLimits(2,:),...
                                'Lower',			FitLimits(3,:),...
                                'Display',			'off',...
                                'Normalize',        'off',...
                                'Exclude',          exclude);
            otherwise
                error('Dingi:AnalysisKit:bigoFluxAnalysis:fit:unknownFitType',...
                    'The fit type ''%s'' is not defined yet.',obj.FitType)
        end

        [fitObj{ff},FitGOF{ff},FitOutput{ff}] = fit(xData,yData,FitType,fitOptions);
    end

    obj.FitObjects  = fitObj;
    obj.FitGOF      = FitGOF;
    obj.FitOutput   = FitOutput;
end
