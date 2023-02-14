function convertToTEOS10(obj)
    
    Sp  = obj.SalinityPractical; % practical salinity (PSU)
    t   = obj.TemperatureRaw; % In-situ temperature (°C)
    p   = obj.Pressure; % Pressure (dbar)
    lon = obj.Parent.longitude;
    lat = obj.Parent.latitude;
    
    Sa = gsw_SA_from_SP(Sp,p,lon,lat); % g kg-1
    CT = gsw_CT_from_t(Sa,t,p); % °C
    
    
    obj.SalinityAbsolute = Sa;
    obj.TemperatureConservative = CT;
end

