function obj = plus(A,B)
    % valueQ = valueA + valueB
    % sigmaQ = sqrt(sigmaA.^2 + sigmaB.^2)
    % flagQ  = flagA | flagB
    
    % Convert to quantity
    if ~isa(A,'DataKit.quantity')
        A = DataKit.quantity(A);
    end
    if ~isa(B,'DataKit.quantity')
        B = DataKit.quantity(B);
    end
    
    % Define error propagation function
    sigmaFunc = @(dA,dB) sqrt(dA.^2 + dB.^2);
    
    obj = DataKit.quantity(...
        plus@double(A,B),...
        sigmaFunc(A.Sigma,B.Sigma),...
        or(A.Flag,B.Flag));
end
