function varargout = rotateSegregateScalars(obj)

    nargoutchk(0,1)
    
    obj.TimeRS        = reshape(cat(1,obj.TimeQC,NaN(obj.NSamplesWindowsPadding,1)),obj.NSamplesPerWindow,obj.NWindows + 1);

    tmpVelocity	= permute(reshape(shiftdim(cat(1,obj.VelocityQC,NaN(obj.NSamplesWindowsPadding,3)),-1),obj.NSamplesPerWindow,obj.NWindows + 1,[]),[1,3,2]);
    obj.VelocityRS 	= NaN(obj.NSamplesPerWindow,obj.NWindows + 1,3);
    for win = 1:obj.NWindows + 1
        obj.VelocityRS(:,win,:) = tmpVelocity(:,:,win)*obj.CoordinateSystemUnitVectors(:,:,win);
    end

    obj.FluxParameterRS = reshape(shiftdim(cat(1,obj.FluxParameterQC,NaN(obj.NSamplesWindowsPadding,obj.NFluxParameters)),-1),obj.NSamplesPerWindow,obj.NWindows + 1,[]);
    
    if nargout == 2
        varargout{1} = obj;
    end
end