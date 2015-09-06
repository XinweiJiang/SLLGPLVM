function gX = tpsKernGradX(kern, X, X2)

% RBFKERNGRADX Gradient of RBF kernel with respect to input locations.
%
%	Description:
%
%	G = RBFKERNGRADX(KERN, X1, X2) computes the gradident of the radial
%	basis function kernel with respect to the input positions where both
%	the row positions and column positions are provided separately.
%	 Returns:
%	  G - the returned gradients. The gradients are returned in a matrix
%	   which is numData2 x numInputs x numData1. Where numData1 is the
%	   number of data points in X1, numData2 is the number of data points
%	   in X2 and numInputs is the number of input dimensions in X.
%	 Arguments:
%	  KERN - kernel structure for which gradients are being computed.
%	  X1 - row locations against which gradients are being computed.
%	  X2 - column locations against which gradients are being computed.
%	
%	
%
%	See also
%	RBFKERNPARAMINIT, KERNGRADX, RBFKERNDIAGGRADX


%	Copyright (c) 2004, 2005, 2006 Neil D. Lawrence


%	With modifications by Mauricio Alvarez 2009, David Luengo, 2009
% 	rbfKernGradX.m CVS version 1.8
% 	rbfKernGradX.m SVN version 375
% 	last update 2009-06-02T22:01:41.000000Z

gX = zeros(size(X2, 1), size(X2, 2), size(X, 1));
for i = 1:size(X, 1);
  gX(:, :, i) = tpsKernGradXpoint(kern, X(i, :), X2);
end
  

function gX = tpsKernGradXpoint(kern, x, X2)

% TPSKERNGRADXPOINT Gradient with respect to one point of x.

gX = zeros(size(X2));
n2 = dist21(x, X2);
wi2 = (log(n2)+1)./(16*pi);
tpsPart = kern.variance*wi2;
for i = 1:size(x, 2)
  gX(:, i) = 2*(x(i) - X2(:, i)).*tpsPart;
end
% if isfield(kern, 'isNormalised') && (kern.isNormalised == true)
%     gX = gX * sqrt(kern.inverseWidth/(2*pi));
% end
