function obj = rdivide(A,B)
    % valueQ = valueA./valueB
    % sigmaQ = abs(Q).*sqrt((sigmaA./A).^2 + (sigmaB./B).^2)
    % flagQ  = flagA | flagB
    
    % Convert to quantity
    if ~isa(A,'DataKit.quantity')
        A = DataKit.quantity(A);
    end
    if ~isa(B,'DataKit.quantity')
        B = DataKit.quantity(B);
    end
    
    % Define error propagation function
    sigmaFunc = @(A,B,dA,dB) abs(A.*B).*sqrt((dA./A).^2 + (dB./B).^2);

    obj = DataKit.quantity(...
        rdivide@double(A,B),...
        sigmaFunc(double(A),double(B),A.Sigma,B.Sigma),...
        or(A.Flag,B.Flag));
end
