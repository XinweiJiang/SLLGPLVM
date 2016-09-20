function model = fgplvmOptimiseSAE(model, display, iters);

% FGPLVMOPTIMISE Optimise the FGPLVM.
%
%	Description:
%
%	MODEL = FGPLVMOPTIMISE(MODEL, DISPLAY, ITERS) takes a given GP-LVM
%	model structure and optimises with respect to parameters and latent
%	positions.
%	 Returns:
%	  MODEL - the optimised model.
%	 Arguments:
%	  MODEL - the model to be optimised.
%	  DISPLAY - flag dictating whether or not to display optimisation
%	   progress (set to greater than zero) (default value 1).
%	  ITERS - number of iterations to run the optimiser for (default
%	   value 2000).
%	fgplvmLogLikeGradients, fgplvmObjective, fgplvmGradient
%	
%
%	See also
%	FGPLVMCREATE, FGPLVMLOGLIKELIHOOD, 


%	Copyright (c) 2005, 2006 Neil D. Lawrence
% 	fgplvmOptimise.m CVS version 1.5
% 	fgplvmOptimise.m SVN version 29
% 	last update 2009-09-12T11:14:05.000000Z


if nargin < 3
  iters = 2000;
  if nargin < 2
    display = 1;
  end
end

paramsL = fgplvmExtractParam(model.modelL);
paramsL = reshape(paramsL(length(paramsL)-model.modelL.kern.nParams+1:length(paramsL)), 1, model.modelL.kern.nParams);
paramsR = gpExtractParam(model.modelR);
paramsU = fgplvmExtractParam(model.modelU);
paramsU = reshape(paramsU(length(paramsU)-model.modelU.kern.nParams+1:length(paramsU)), 1, model.modelU.kern.nParams);
z = model.Z;

options = optOptions;
if display
  options(1) = 1;
  if length(paramsL) <= 100
    options(9) = 1;
  end
end
options(14) = iters;

if isfield(model.modelL, 'optimiser')
  optim = str2func(model.modelL.optimiser);
else
  optim = str2func('scg');
end

if strcmp(func2str(optim), 'optimiMinimize')
  % Carl Rasmussen's minimize function 
  params = optim('fgplvmObjectiveGradientSAE', [paramsL paramsR paramsU z(:)'], options, model);
else
  % NETLAB style optimization.
  params = optim('fgplvmObjective', [paramsL paramsR paramsU z(:)'],  options, ...
                 'fgplvmGradient', model);
end

startVal = 1;
endVal = model.modelL.kern.nParams; 
hyperL = reshape(params(startVal:endVal), 1, model.modelL.kern.nParams);

startVal = endVal+1;
endVal = endVal +  model.modelR.kern.nParams;
hyperR = reshape(params(startVal:endVal), 1, model.modelR.kern.nParams);

startVal = endVal+1;
endVal = endVal +  model.modelU.kern.nParams; 
hyperU = reshape(params(startVal:endVal), 1, model.modelU.kern.nParams);

startVal = endVal+1;
endVal = endVal + model.N*model.p;
model.Z = reshape(params(startVal:endVal), model.N, model.p);    

model.modelL = fgplvmExpandParam(model.modelL, [model.Z(:)' hyperL]);
model.modelR = gpCreate(model.D, model.p, model.X, model.Z, model.optionsR);
model.modelR = gpExpandParam(model.modelR, hyperR);
model.modelU = fgplvmExpandParam(model.modelU, [model.Z(:)' hyperU]);
