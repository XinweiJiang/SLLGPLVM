function [nlZ, dnlHpW] = sgplvmObjectiveGradient(params, model)

% Laplace approximation to the posterior Gaussian Process.
% The function takes a specified covariance function (see covFunction.m) and
% likelihood function (see likelihoods.m), and is designed to be used with
% binaryGP.m. See also approximations.m.
%
% Copyright (c) 2006, 2007 Carl Edward Rasmussen and Hannes Nickisch 2007-03-29


nlZ = 0;

switch model.trainModel
   case 'hyper'
        startVal = 1;
        endVal = model.modelR.kern.nParams;
        paramsR = [model.modelR.X(:)' params(startVal:endVal,:)'];
        [f, g] = fgplvmObjectiveGradient(paramsR, model.modelR);
        startVal = model.modelR.N*model.modelR.q+1;
        endVal = model.modelR.N*model.modelR.q+model.modelR.kern.nParams;
        dnlHpR = reshape(g(startVal:endVal), model.modelR.kern.nParams, 1);
        nlZ = nlZ + f;

        startVal = model.modelR.kern.nParams+1;
        endVal = model.modelR.kern.nParams+model.modelL.kern.nParams;
        paramsL = [model.modelL.X(:)' params(startVal:endVal,:)'];
        [f, g] = fgplvmObjectiveGradient(paramsL, model.modelL);
        startVal = model.modelL.N*model.modelL.q+1;
        endVal = model.modelL.N*model.modelL.q+model.modelL.kern.nParams;
        dnlHpL = reshape(g(startVal:endVal), model.modelL.kern.nParams, 1);
        nlZ = nlZ + f;

        dnlHpW = [dnlHpR;dnlHpL];
        
    case 'latent'
        paramsR = [params' model.modelR.kern.hyper];
        [f, g] = fgplvmObjectiveGradient(paramsR, model.modelR);
        startVal = 1;
        endVal = model.modelR.N*model.modelR.q;
        dnlZR = reshape(g(startVal:endVal), model.modelR.N*model.modelR.q, 1);
        nlZ = nlZ + f;

        paramsL = [params' model.modelL.kern.hyper];
        [f, g] = fgplvmObjectiveGradient(paramsL, model.modelL);
        startVal = 1;
        endVal = model.modelL.N*model.modelL.q;
        dnlZL = reshape(g(startVal:endVal), model.modelL.N*model.modelL.q, 1);
        nlZ = nlZ + f;
        
        dnlZ = dnlZR+dnlZL;

        dnlHpW = dnlZ;
        
    case 'modelR'
        [f, g] = fgplvmObjectiveGradient(params, model.modelR);
        nlZ = f;
        dnlHpW = g;
        
    case 'modelL'
        [f, g] = fgplvmObjectiveGradient(params, model.modelL);
        nlZ = f;
        dnlHpW = g;
        
    otherwise
        error('Unknown train model.')
end
 
end
