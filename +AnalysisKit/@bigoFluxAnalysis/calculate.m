function calculate(obj,varargin)
% CALCULATE

    setFitExclusions(obj);
    fit(obj);
    calculateFlux(obj);
end