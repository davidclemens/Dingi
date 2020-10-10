function obj = calculateFlux(obj)
% CALCULATEFLUX
    
    n       = 100;
    flux    = NaN(obj.nFits,3);
    xq      = linspace(obj.fitInterval(1),obj.fitInterval(2),n)';
    fluxes  = NaN(size(xq));
    for ff = 1:obj.nFits
        fluxes      = differentiate(obj.fitObjects{ff},xq); % dUnit/dt
        flux(ff,1)  = median(fluxes);
    end
    obj.flux = flux;
end