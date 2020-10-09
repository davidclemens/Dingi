function varargout = plot(obj,varargin)
    narginchk(1,5)

    optionName          = {'Parameters','Smooth'}; % valid options (Name)
    optionDefaultValue  = {'velocity',false}; % default value (Value)
    [parameters,smooth]...
                        = internal.stats.parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments

    if ~iscell(parameters)
        parameters  = {parameters};
    end
    nParameters         = numel(parameters);
    
    if numel(smooth) ~= nParameters && ...
       numel(smooth) == 1
        smooth      = repmat(smooth,1,nParameters);
    end
    
    
    
   	[im,imInd]              = ismember(parameters,obj.dataMetadata{:,'parameter'});
        
    % TODO: handle invalid parameter names
    
	hfig                    = figure(10);
    hsp                     = gobjects(0);
    obj.plotHandles.hfig	= hfig;
    obj.plotHandles.hsp     = hsp;
    fig                     = hfig.Number;
    set(hfig,...
        'name',     ['Vector: ',obj.UserConfiguration.deploymentName])
    clf

    spnx        = 1;
    spny        = nParameters;
    spi         = reshape(1:spnx*spny,spnx,spny)';

    col     = 1;
    for row = 1:spny
        par = row;
        hsp(spi(row,col),fig) = subplot(spny,spnx,spi(row,col),...
                                            'NextPlot',     'add');
            XData   = obj.(['time',obj.dataMetadata{imInd(par),'time'}{:}]); % 'Relative'
            if smooth(par)
                YData   = movmedian(obj.(parameters{par}),obj.(['sampleRate',obj.dataMetadata{imInd(par),'time'}{:}])*60);
            else
                YData   = obj.(parameters{par});
            end
            
            plot(XData,YData)
            
            if row == spny
                xlabel('time (h)')
            end
            ylabel([obj.dataMetadata{imInd(par),'parameterString'}{:},' (',obj.dataMetadata{imInd(par),'unit'}{:},')'])
    end
    hlnk = linkprop(hsp(spi(:,col),fig),{'XLim'});
    
    if nargout > 0
        varargout{1}    = hfig;
        varargout{2}    = hlnk;
    end
end