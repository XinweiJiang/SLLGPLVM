function [ nl, dnl ] = smgpcLikelihoodGradients( vectheta )
%MULTILAPLACEGP Summary of this function goes here
%   Detailed explanation goes here


nl = mpot(vectheta);
dnl = mgrad(vectheta);

end

