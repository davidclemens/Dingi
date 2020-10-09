function [uu,vv,ww,uw,vw]=csPlanarFitRotateVelocityStat(u,i,j,k)
% determines velocity statistics in new coordinate
%input
%   u:          3 by 3 matrix of cross product of the three velocity components
%               (u(1,1) = u1^u1, u(1,2)=u1^v1, etc.)  in instrument coordinate
%   i, j, k:    unit vectors parallel to the new coordinate x, y and
%
% z-axes output
% 	uu, vv, ww, uw, vw:  statistics in new coordinate
%

    uu = i(1)^2*u(1,1) + i(2)^2*u(2,2) + i(3)^2*u(3,3) + 2*(i(1)*i(2)*u(1,2) + i(1)*i(3)*u(1,3) + i(2)*i(3)*u(2,3));
    vv = j(1)^2*u(1,1) + j(2)^2*u(2,2) + j(3)^2*u(3,3) + 2*(j(1)*j(2)*u(1,2) + j(1)*j(3)*u(1,3) + j(2)*j(3)*u(2,3));
    ww = k(1)^2*u(1,1) + k(2)^2*u(2,2) + k(3)^2*u(3,3) + 2*(k(1)*k(2)*u(1,2) + k(1)*k(3)*u(1,3) + k(2)*k(3)*u(2,3));
    uw = i(1)*k(1)*u(1,1) + i(2)*k(2)*u(2,2) + i(3)*k(3)*u(3,3) + (i(1)*k(2) + i(2)*k(1))*u(1,2) + (i(1)*k(3) + i(3)*k(1))*u(1,3) + (i(2)*k(3) + i(3)*k(2))*u(2,3);
    vw = j(1)*k(1)*u(1,1) + j(2)*k(2)*u(2,2) + j(3)*k(3)*u(3,3) + (j(1)*k(2) + j(2)*k(1))*u(1,2) + (j(1)*k(3) + j(3)*k(1))*u(1,3) + (j(2)*k(3) + j(3)*k(2))*u(2,3);
end