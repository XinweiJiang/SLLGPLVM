function [ f, dW, dA ] = sgpSpasePriorLikelihoodGradients( w, A )
%SGPSPASEPRIORLIKELIHOODGRADIENTS Summary of this function goes here
%   Detailed explanation goes here

% the negative log likelihood and 
% gradients for the RVM-like prior over matrix W

[n, p] = size(w);

f = 0;
dA = zeros(p,1);
dW = w;

for i = 1:p
    f = f+0.5*(w(:,i)'*w(:,i)*A(i)-n*log(A(i)));
    dA(i) = 0.5*(w(:,i)'*w(:,i)-n/A(i));
end

end

