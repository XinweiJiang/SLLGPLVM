function model = sgpFgplvmOptimise(model, display, iters);

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

paramsR = fgplvmExtractParam(model.modelR);
paramsL = fgplvmExtractParam(model.modelL);
       
switch model.trainModel
   case 'hyper'
       startVal = model.modelR.N*model.modelR.q+1;
       endVal = model.modelR.N*model.modelR.q+model.modelR.kern.nParams;
       paramsR = paramsR(1,startVal:endVal);
       startVal = model.modelL.N*model.modelL.q+1;
       endVal = model.modelL.N*model.modelL.q+model.modelL.kern.nParams;
       paramsL = paramsL(1,startVal:endVal);
       params = [paramsR paramsL];
       
   case 'latent'
       startVal = 1;
       endVal = model.modelR.N*model.modelR.q;
       params = paramsR(1,startVal:endVal);
       
   case 'modelR'
       params = paramsR;
       
   case 'modelL'
       params = paramsL;
       
   otherwise
       error('Unknown train model.')
end

options = optOptions;
if display
  options(1) = 1;
  if length(params) <= 100
    options(9) = 1;
  end
end
options(14) = iters;

if isfield(model, 'optimiser')
  optim = str2func(model.optimiser);
else
  optim = str2func('optimiMinimize');
end

if strcmp(func2str(optim), 'optimiMinimize')
  % Carl Rasmussen's minimize function 
  params = optim('sgplvmObjectiveGradient', params, options, model);
else
  % NETLAB style optimization.
  params = optim('fgplvmObjective0', params,  options, ...
                 'fgplvmGradient0', model);
end

       
switch model.trainModel
   case 'hyper'
       startVal = 1;
       endVal = model.modelR.kern.nParams;
       paramsR = [model.modelR.X(:)' params(1,startVal:endVal)];
       model.modelR = fgplvmExpandParam(model.modelR, paramsR);
       
       startVal = endVal+1;
       endVal = endVal+model.modelL.kern.nParams;
       paramsL = [model.modelL.X(:)' params(1,startVal:endVal)];
       model.modelL = fgplvmExpandParam(model.modelL, paramsL);
       
   case 'latent'
       paramsR = [params model.modelR.kern.hyper];
       model.modelR = fgplvmExpandParam(model.modelR, paramsR);
       paramsL = [params model.modelL.kern.hyper];
       model.modelL = fgplvmExpandParam(model.modelL, paramsL);
       
   case 'modelR'
       model.modelR = fgplvmExpandParam(model.modelR, params);
       
   case 'modelL'
       model.modelL = fgplvmExpandParam(model.modelL, params);
       
   otherwise
       error('Unknown train model.')
end

