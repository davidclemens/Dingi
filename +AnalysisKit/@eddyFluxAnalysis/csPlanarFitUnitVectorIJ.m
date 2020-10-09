function [i,j] = csPlanarFitUnitVectorIJ(U1,k)
% determines unit vectors i, j (parallel to new coordinate x and y axes)
%
% input
%   U1(1):  (30-min) mean u1 in instrument coordinate
%     (2):  (30-min) mean v1 in instrument coordinate
%     (3):  (30-min) mean w1 in instrument coordinate
%   k:      unit vector parallel to the new coordinate z-axis
%
% output
%    i, j:  unit vector parallel to new coordinate x and y axes
%
% Source:
% Lee, X., Finnigan, J. and U, K. T. P.: Coordinate Systems and Flux Bias
%   Error, in Handbook of Micrometeorology, vol. 29, edited by X. Lee,
%   W. Massman, and B. Law, pp. 33–66, Springer Netherlands, Dordrecht. 2005.

    j = cross(k,U1);
    j = j/sqrt(sum(j.^2));
    i = cross(j,k);
end