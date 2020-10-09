function [func,varargout] = fitLinear(predictor,response)


    % read up on this @ https://de.mathworks.com/help/matlab/data_analysis/linear-regression.html

    % linear model: Y = beta0 + beta1*X1 + beta2*X2
    %         (depVar = beta0 + beta1*indVar1 + beta2*indVar2)
    %          (valueQ = beta0 + beta1*timeQ + beta2*signalQ)
    linCoeff        = [ones(size(predictor,1),1),predictor]\response;
    func            = @(predictor) [ones(size(predictor,1),1),predictor]*linCoeff;
    varargout{1}	= linCoeff;
end