function obj = calculate(obj,varargin)
% CALCULATE

    obj = fit(obj);
    obj = calculateFlux(obj);
end