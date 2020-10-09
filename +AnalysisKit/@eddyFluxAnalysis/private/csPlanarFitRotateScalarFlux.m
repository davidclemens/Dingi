function [uc,vc,wc] = csPlanarFitRotateScalarFlux(u1c,v1c,w1c,i,j,k)
% determines scalar flux in new coordinate
%
% input
%    u1c,v1c,w1c:   scalar flux in instrument coordinate
%    i, j, k:       unit vectors parallel to the new coordinate x, y and
%
% z-axes output
%   uc,vc,wc:       scalar flux in new coordinate
%
% Source:
% Lee, X., Finnigan, J. and U, K. T. P.: Coordinate Systems and Flux Bias
%   Error, in Handbook of Micrometeorology, vol. 29, edited by X. Lee,
%   W. Massman, and B. Law, pp. 33–66, Springer Netherlands, Dordrecht. 2005.

    H   = [u1c v1c w1c];
    uc  = sum(i.*H);
    vc  = sum(j.*H);
    wc  = sum(k.*H);
end
