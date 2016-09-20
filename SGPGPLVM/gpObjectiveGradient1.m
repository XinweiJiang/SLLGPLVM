function [f, g] = gpObjectiveGradient1(params, model)

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

startVal = 1;
endVal = model.modelR.kern.nParams; 
hyperR = reshape(params(startVal:endVal), 1, model.modelR.kern.nParams);

startVal = endVal+1;
endVal = endVal + model.N*model.p;
model.Z = reshape(params(startVal:endVal), model.N, model.p);    


model.modelR = gpCreate(model.D, model.p, model.X, model.Z, model.optionsR);
model.modelR = gpExpandParam(model.modelR, hyperR);


[fR, ghR] = gpObjectiveGradient(hyperR, model.modelR);


gzR = model.modelR.invK_uu*model.modelR.y;         
gz = gzR;

f = fR;
g = [ghR gz(:)']';

