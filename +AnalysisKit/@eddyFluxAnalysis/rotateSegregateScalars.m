function varargout = rotateSegregateScalars(obj)

    import AnalysisKit.eddyFluxAnalysis.xyz2enu

    nargoutchk(0,1)
    
    % Segregate time
    obj.TimeRS      = reshape(cat(1,obj.TimeQC,NaN(obj.NSamplesWindowsPadding,1)),obj.NSamplesPerWindow,obj.NWindows + 1);

    % Segregate velocity
    tmpVelocity     = permute(reshape(shiftdim(cat(1,obj.VelocityQC,NaN(obj.NSamplesWindowsPadding,3)),-1),obj.NSamplesPerWindow,obj.NWindows + 1,[]),[1,3,2]);
    
    % Rotate velocity
    obj.VelocityRS      = NaN(obj.NSamplesPerWindow,obj.NWindows + 1,3);
    obj.VelocityRSenu 	= NaN(obj.NSamplesPerWindow,obj.NWindows + 1,3);
    for win = 1:obj.NWindows + 1
        obj.VelocityRS(:,win,:)     = tmpVelocity(:,:,win)*obj.CoordinateSystemUnitVectors(:,:,win); % Rotate 
        obj.VelocityRSenu(:,win,:)  = xyz2enu(tmpVelocity(:,:,win),obj.PitchRollHeading(1),obj.PitchRollHeading(2),obj.PitchRollHeading(3));
    end

    % Segregate flux parameter
    obj.FluxParameterRS = reshape(shiftdim(cat(1,obj.FluxParameterQC,NaN(obj.NSamplesWindowsPadding,obj.NFluxParameters)),-1),obj.NSamplesPerWindow,obj.NWindows + 1,[]);
    
    if nargout == 2
        varargout{1} = obj;
    end
end