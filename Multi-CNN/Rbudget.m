function [c,ceq]=Rbudget(RLH)
load('temp.mat')
Rbg = L4*gamcdf(RLH(1),Alpha,Beta)+L6*gamcdf(RLH(2),Alpha,Beta)+L3*(Alpha*Beta)*gamcdf(RLH(1),Alpha+1,Beta)+L5*(Alpha*Beta)*gamcdf(RLH(2),Alpha+1,Beta)+aSP-Ravl;

%%% constraint is such that Rbudget (Rsent) is less than or equal Ravl
c=Rbg;
ceq=[];

%%% constraint is such that Rbudget (Rsent) equals Ravl
% ceq=Rbg;
% c=[];

