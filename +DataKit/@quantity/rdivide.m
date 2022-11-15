function obj = rdivide(A,B)
    % Q = A./B
    % sigmaQ = abs(Q).*sqrt((sigmaA./A).^2 + (sigmaB./B).^2)
    
    % Convert to quantity
    if ~isa(A,'DataKit.quantity')
        A = DataKit.quantity(A);
    end
    if ~isa(B,'DataKit.quantity')
        B = DataKit.quantity(B);
    end
    
    relSigmaA = A.Sigma./double(A);
    relSigmaB = B.Sigma./double(B);
    Q = rdivide@double(A,B);
    obj = DataKit.quantity(...
        Q,...
        abs(Q).*sqrt(relSigmaA.^2 + relSigmaB.^2));
end
