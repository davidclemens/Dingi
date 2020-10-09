function [k,b0] = csPlanarFitUnitVectorK(U1)
% determines unit vector k (parallel to new z-axis)
%
% input
%   U1(:,1):    mean u1 in instrument coordinate
%     (:,2):    mean v1 in instrument coordinate
%     (:,3):    mean w1 in instrument coordinate
%
% output
%    k:         unit vector parallel to new coordinate z axis
%    b0:        instrument offset in w1
%
% Sources:
% Wilczak, J. M., Oncley, S. P. and Stage, S. A.: Sonic Anemometer Tilt
%   Correction Algorithms, Boundary-Layer Meteorology, 99(1), 127–150,
%   doi:10.1023/A:1018966204465, 2001.
%
% Lee, X., Finnigan, J. and U, K. T. P.: Coordinate Systems and Flux Bias
%   Error, in Handbook of Micrometeorology, vol. 29, edited by X. Lee,
%   W. Massman, and B. Law, pp. 33–66, Springer Netherlands, Dordrecht. 2005.   

    U1      = U1(~any(isnan(U1),2),:);
    % wilczak’s routine
    u       = (U1(:,1))';
    v       = (U1(:,2))';
    w       = (U1(:,3))';
    n	= length(u);
    
    % calculate matrix elements for matrix H and G (Wilczak et al. (2001), Eq. 48)    
    su  = sum(u);
    sv  = sum(v);
    sw  = sum(w);
    suv = sum(u*v');
    suw = sum(u*w');
    svw = sum(v*w');
    su2 = sum(u*u');
    sv2 = sum(v*v');

    % construct matrix H and G (Wilczak et al. (2001), Eq. 48)    
    H   = [n  su  sv
           su su2 suv
           sv suv sv2];
    G   = [sw
           suw
           svw];
     
    % solve H*b = G for b by left devision
    b   = H\G;
    
    
    b0  = b(1);
    b1  = b(2);
    b2  = b(3);

    % determine unit vector k
    k(3) = 1/(1 + b1^2 + b2^2);
    k(1) = -b1*k(3);
    k(2) = -b2*k(3);
end
