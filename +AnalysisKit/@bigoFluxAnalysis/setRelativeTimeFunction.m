function setRelativeTimeFunction(obj)

    switch obj.TimeUnit
        case 'ms'
            TimeFunc   	= @milliseconds;
            newVariable = DataKit.Metadata.variable.DurationMs;
        case 's'
            TimeFunc   	= @seconds;
            newVariable = DataKit.Metadata.variable.DurationS;
        case 'm'
            TimeFunc   	= @minutes;
            newVariable = DataKit.Metadata.variable.DurationMin;
        case 'h'
            TimeFunc   	= @hours;
            newVariable = DataKit.Metadata.variable.DurationH;
        case 'd'
            TimeFunc   	= @days;
            newVariable = DataKit.Metadata.variable.DurationD;
        case 'y'
            TimeFunc   	= @years;
            newVariable = DataKit.Metadata.variable.DurationY;
        case 'datetime'
            % time is already stored as datetime
            TimeFunc  	= @(x) x;
            newVariable = DataKit.Metadata.variable.Time;
        case 'datenum'
            TimeFunc   	= @datenum;
            newVariable = DataKit.Metadata.variable.Time;
        otherwise
            error('Dingi:AnalysisKit:bigoFluxAnalysis:setRelativeTimeFunction:unknownTimeUnitIdentifier',...
                '''%s'' is an unknown time unit identifier.',obj.TimeUnit)
    end
    obj.TimeUnitFunction    = TimeFunc;
    obj.TimeVariable        = newVariable;
end