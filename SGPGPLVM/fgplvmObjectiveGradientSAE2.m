function [f, g] = fgplvmObjectiveGradientSAE2(params, model)

% FGPLVMOBJECTIVEGRADIENT Wrapper function for FGPLVM objective and gradient.
%
%	Description:
%
%	[F, G] = FGPLVMOBJECTIVEGRADIENT(PARAMS, MODEL) returns the negative
%	log likelihood of a Gaussian process model given the model structure
%	and a vector of parameters. This allows the use of NETLAB
%	minimisation functions to find the model parameters.
%	 Returns:
%	  F - the negative log likelihood of the FGPLVM model.
%	  G - the gradient of the negative log likelihood of the FGPLVM
%	   model with respect to the parameters.
%	 Arguments:
%	  PARAMS - the parameters of the model for which the objective will
%	   be evaluated.
%	  MODEL - the model structure for which the objective will be
%	   evaluated.
%	
%
%	See also
%	MINIMIZE, FGPLVMCREATE, FGPLVMGRADIENT, FGPLVMLOGLIKELIHOOD, FGPLVMOPTIMISE


%	Copyright (c) 2005, 2006 Neil D. Lawrence
% 	fgplvmObjectiveGradient.m CVS version 1.1
% 	fgplvmObjectiveGradient.m SVN version 29
% 	last update 2007-11-03T14:32:57.000000Z

% startVal = 1;
% endVal = model.modelL.kern.nParams; 
% hyperL = reshape(params(startVal:endVal), 1, model.modelL.kern.nParams);
% 
% startVal = endVal+1;
% endVal = endVal +  model.modelR.kern.nParams;
startVal = 1;
endVal = model.modelR.kern.nParams; 
hyperR = reshape(params(startVal:endVal), 1, model.modelR.kern.nParams);

startVal = endVal+1;
endVal = endVal +  model.modelU.kern.nParams;
hyperU = reshape(params(startVal:endVal), 1, model.modelU.kern.nParams);

startVal = endVal+1;
endVal = endVal + model.N*model.p;
model.Z = reshape(params(startVal:endVal), model.N, model.p);    

% model.modelL = fgplvmExpandParam(model.modelL, [model.Z(:)' hyperL]);

model.modelR = gpCreate(model.D, model.p, model.X, model.Z, model.optionsR);
model.modelR = gpExpandParam(model.modelR, hyperR);

model.modelU = fgplvmExpandParam(model.modelU, [model.Z(:)' hyperU]);


% fL = - fgplvmLogLikelihood(model.modelL);
% gzhL = - fgplvmLogLikeGradients(model.modelL);

[fR, ghR] = gpObjectiveGradient(hyperR, model.modelR);

fU = - fgplvmLogLikelihood(model.modelU);
gzhU = - fgplvmLogLikeGradients(model.modelU);


% startVal = 1;
% endVal = model.N*model.p;
% gzL = reshape(gzhL(startVal:endVal), model.N, model.p);   
% startVal = endVal+1;
% endVal = endVal+model.modelL.kern.nParams; 
% ghL = reshape(gzhL(startVal:endVal), 1, model.modelL.kern.nParams);

gzR = model.modelR.invK_uu*model.modelR.y;         

startVal = 1;
endVal = model.N*model.p;
gzU = reshape(gzhU(startVal:endVal), model.N, model.p);   
startVal = endVal+1;
endVal = endVal+model.modelU.kern.nParams; 
ghU = reshape(gzhU(startVal:endVal), 1, model.modelU.kern.nParams);

% gz = model.alpha*gzL+model.beta*gzR+model.alpha*gzU;
gz = gzR+gzU;

% fL = model.alpha*fL;fR = model.beta*fR;fU = model.alpha*fU;
% %   fprintf('fL: %d; fR: %d; fU: %d\n', fL, fR, fU);
%  if abs(fL/fR) < 10
%  error('1');
%  end

% f = fL+fR+fU;
f = fR+fU;
% g = [model.alpha*ghL model.beta*ghR model.alpha*ghU gz(:)']';
g = [ghR ghU gz(:)']';

