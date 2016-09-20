function model = fgplvmOptimiseSAE3(model, display, iters);

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

Threshold = 0.1;%1e-1
if isfield(model, 'threshold')
    Threshold = model.threshold;
end

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

options = optOptions;
if display
  options(1) = 1;
  if length(paramsL) <= 100
    options(9) = 1;
  end
end
options(14) = iters;

nLoop = -iters;
oldZ = model.Z(:);
optim = str2func(model.modelL.optimiser);

for i = 1:nLoop
    params = optim('fgplvmObjectiveGradientSAE2', [paramsR paramsU model.Z(:)'], options, model);
    startVal = 1;
    endVal = model.modelR.kern.nParams; 
    paramsR = reshape(params(startVal:endVal), 1, model.modelR.kern.nParams);

    startVal = endVal+1;
    endVal = endVal +  model.modelU.kern.nParams;
    paramsU = reshape(params(startVal:endVal), 1, model.modelU.kern.nParams);

    startVal = endVal+1;
    endVal = endVal + model.N*model.p;
    model.Z = reshape(params(startVal:endVal), model.N, model.p);   
    
    params = optim('fgplvmObjectiveGradient', [paramsL paramsR model.Z(:)'], options, model);
    startVal = 1;
    endVal = model.modelL.kern.nParams; 
    paramsL = reshape(params(startVal:endVal), 1, model.modelL.kern.nParams);
    
    startVal = endVal+1;
    endVal = endVal + model.modelR.kern.nParams; 
    paramsR = reshape(params(startVal:endVal), 1, model.modelR.kern.nParams);

    startVal = endVal+1;
    endVal = endVal + model.N*model.p;
    model.Z = reshape(params(startVal:endVal), model.N, model.p);  

    diffZ = model.Z(:) - oldZ;
    sumDiffZ = sum(diffZ.*diffZ)
    if sumDiffZ < Threshold
        break;
    else
        oldZ = model.Z(:);
    end
end


model.modelL = fgplvmExpandParam(model.modelL, [model.Z(:)' paramsL]);
model.modelR = gpCreate(model.D, model.p, model.X, model.Z, model.optionsR);
model.modelR = gpExpandParam(model.modelR, paramsR);
model.modelU = fgplvmExpandParam(model.modelU, [model.Z(:)' paramsU]);
