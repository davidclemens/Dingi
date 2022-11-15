function obj = plus(A,B)
    % Q = A + B
    % sigmaQ = sqrt(sigmaA.^2 + sigmaB.^2)
    
    % Convert to quantity
    if ~isa(A,'DataKit.quantity')
        A = DataKit.quantity(A);
    end
    if ~isa(B,'DataKit.quantity')
        B = DataKit.quantity(B);
    end
    obj = DataKit.quantity(...
        plus@double(A,B),...
        sqrt(A.Sigma.^2 + B.Sigma.^2));
end
