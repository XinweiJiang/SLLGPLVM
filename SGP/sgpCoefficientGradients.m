function gW = sgpCoefficientGradients(gZ, X)
%SGPCOEFFICIENTGRADIENTS Summary of this function goes here
%   Finds the gradients for the W of the model Z=W'X

N = size(X, 1);
gW = zeros(size(gZ,2), size(X,2));

for i=1:N
    gW = gW + sgpOuterProduct(gZ(i,:), X(i,:));
end

end

