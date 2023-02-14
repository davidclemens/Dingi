function setRelativeTimeFunction(obj)

    import DebuggerKit.Debugger.printDebugMessage

    printDebugMessage('Dingi:AnalysisKit:bigoSalinityInjectionAnalysis:setRelativeTimeFunction:settingRelativeTimeFunc',...
        'Verbose','Setting relative time function ...')
    
    switch obj.TimeUnit
        case 'ms'
            TimeFunc   	= @milliseconds;
            newVariable = DataKit.Metadata.variable.DurationMs;
        case {'s','sec'}
            TimeFunc   	= @seconds;
            newVariable = DataKit.Metadata.variable.DurationS;
        case {'m','min'}
            TimeFunc   	= @minutes;
            newVariable = DataKit.Metadata.variable.DurationMin;
        case {'h','hr'}
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
            printDebugMessage('Dingi:AnalysisKit:bigoSalinityInjectionAnalysis:setRelativeTimeFunction:unknownTimeUnitIdentifier',...
                'Error','''%s'' is an unknown time unit identifier.',obj.TimeUnit)
    end
    obj.TimeUnitFunction    = TimeFunc;
    obj.TimeVariable        = newVariable;
    
    printDebugMessage('Dingi:AnalysisKit:bigoSalinityInjectionAnalysis:setRelativeTimeFunction:settingRelativeTimeFunc',...
        'Verbose','Setting relative time function ... done')
end
