function [ f, g ] = sgpLikelihoodGradientForHyperParam( theta )
%SGPLIKELIHOODGRADIENTFORHYPERPARAM Summary of this function goes here
%   Detailed explanation goes here

% For SGPGPLVM, we have to impose prior on the hyperparamters in GPR model
% \theta \sim N(0,I)
% This function will return the negative log likelihood and corresponding
% gradients for \theta

[m,n] = size(theta);
if(m == 1) 
    theta = theta'; 
end;
    
f = 0.5*theta'*theta;
g = theta;


end

