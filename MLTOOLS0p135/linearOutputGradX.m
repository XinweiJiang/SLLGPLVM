function g = linearOutputGradX(model, X)

% LINEAROUTPUTGRADX Evaluate derivatives of linear model outputs with respect to inputs.
%
%	Description:
%
%	G = LINEAROUTPUTGRADX(MODEL, X) returns the derivatives of the
%	outputs of an LINEAR model with respect to the inputs to the model.
%	 Returns:
%	  G - the gradient of the output with respect to the inputs, in
%	 Arguments:
%	  MODEL - the model for which the derivatives will be computed.
%	  X - the locations at which the derivatives will be computed.
%	
%
%	See also
%	LINEAROUTPUTGRAD, MODELOUTPUTGRADX


%	Copyright (c) 2006 Neil D. Lawrence
% 	linearOutputGradX.m CVS version 1.1
% 	linearOutputGradX.m SVN version 24
% 	last update 2007-11-03T14:24:25.000000Z

g = repmat(shiftdim(model.W, -1), [size(X, 1) 1 1]);