function varargout = planarFitCoordinateSystem(obj)
    
    nargoutchk(0,1)
    
    nObj    = numel(obj);
  	if nObj > 1
        error('Dingi:GearKit:eddyFluxAnalysis:planarFitCoordinateSystem:objSize',...
              'planarFitCoordinateSystem only works in a scalar context. To get data from multiple instances, loop over all.')
    end
    
  	fitLinear(obj)

    % wilczak’s routine
    u       = (obj.Velocity(:,1))';
    v       = (obj.Velocity(:,2))';
    w       = (obj.Velocity(:,3))';
    flen	= length(u);
    
    su  = sum(u);
    sv  = sum(v);
    sw  = sum(w);
    suv = sum(u*v');
    suw = sum(u*w');
    svw = sum(v*w');
    su2 = sum(u*u');
    sv2 = sum(v*v');
    H   = [flen su sv; su su2 suv; sv suv sv2];
    g   = [sw suw svw]';
    x   = H\g;
    b0  = x(1);
    b1  = x(2);
    b2  = x(3);

    % determine unit vector k
    k(3) = 1/(1 + b1^2 + b2^2);
    k(1) = -b1*k(3);
    k(2) = -b2*k(3);
    
	j = cross(k,U1);
    j = j/(sum(j.*j))^0.5;
    i = cross(j,k);
    
    if nargout == 1
        varargout{1} = obj;
    end
end