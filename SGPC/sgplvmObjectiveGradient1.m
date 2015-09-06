function [nlZ, dnlHpW] = sgplvmObjectiveGradient1(params, model)

% Laplace approximation to the posterior Gaussian Process.
% The function takes a specified covariance function (see covFunction.m) and
% likelihood function (see likelihoods.m), and is designed to be used with
% binaryGP.m. See also approximations.m.
%
% Copyright (c) 2006, 2007 Carl Edward Rasmussen and Hannes Nickisch 2007-03-29


nlZ = 0;

% if size(params,1) > size(params,2)
%     params = params';
% end
switch model.trainModel
   case 'hyper'
        startVal = 1;
        endVal = model.modelL.kern.nParams;
        paramsL = [model.modelL.X(:)' reshape(params(startVal:endVal), 1, model.modelL.kern.nParams)];
        [f, g] = fgplvmObjectiveGradient00(paramsL, model.modelL);
        startVal = model.N*model.p+1;
        endVal = model.N*model.p+model.modelL.kern.nParams;
        dnlHpL = reshape(g(startVal:endVal), 1, model.modelL.kern.nParams);
        nlZ = nlZ + f;

        startVal = model.modelL.kern.nParams+1;
        endVal = model.modelL.kern.nParams+model.modelU.kern.nParams;
        paramsU = [model.modelU.X(:)' reshape(params(startVal:endVal), 1, model.modelU.kern.nParams)];
        [f, g] = fgplvmObjectiveGradient00(paramsU, model.modelU);
        startVal = model.N*model.p+1;
        endVal = model.N*model.p+model.modelU.kern.nParams;
        dnlHpU = reshape(g(startVal:endVal), 1, model.modelU.kern.nParams);
        nlZ = nlZ + f;

        dnlHpW = [dnlHpL dnlHpU]';
        
    case 'latent'
        paramsL = [reshape(params, 1, model.N*model.p) model.modelL.kern.hyper];
        [f, g] = fgplvmObjectiveGradient00(paramsL, model.modelL);
        startVal = 1;
        endVal = model.N*model.p;
        dnlZL = g(startVal:endVal);
        nlZ = nlZ + f;

        paramsU = [reshape(params, 1, model.N*model.p) model.modelU.kern.hyper];
        [f, g] = fgplvmObjectiveGradient00(paramsU, model.modelU);
        startVal = 1;
        endVal = model.N*model.p;
        dnlZU = g(startVal:endVal);
        nlZ = nlZ + f;
        
        dnlZ = dnlZL+dnlZU;

        dnlHpW = dnlZ';
        
    case 'modelL'
        [f, g] = fgplvmObjectiveGradient00(params, model.modelL);
        nlZ = f;
        dnlHpW = g;
        
    case 'modelU'
        [f, g] = fgplvmObjectiveGradient00(params, model.modelU);
        nlZ = f;
        dnlHpW = g;
        
    otherwise
        error('Unknown train model.')
end
 
end
