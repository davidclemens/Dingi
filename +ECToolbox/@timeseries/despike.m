function tsDespiked = despike(obj,varargin)
    optionName          = {'Method'}; % valid options (Name)
    optionDefaultValue  = {'Phase-Space Thresholding'}; % default value (Value)
    method              = internal.stats.parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments
    
    import ECToolbox.*


    
    switch method
        case 'Phase-Space Thresholding'
            despiker	= PhaseSpaceThresholding(obj);
        otherwise
            error('''%s'' is an invalid or unimplemented despiking method.',method)
    end
    
    tsDespiked                          = obj;
    tsDespiked.Data                     = despiker.dataDespiked;
    tsDespiked.Quality                  = -128.*ones(1,size(tsDespiked.Data,2)).*despiker.isSpike;
    tsDespiked.QualityInfo.Code         = [0,-128];
    tsDespiked.QualityInfo.Description  = {'','Spike'};
end