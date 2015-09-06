function Y = modelSamp(model, X)

% MODELSAMP Give a sample from a model for given X.
%
%	Description:
%	Y = modelSamp(model, X)
%% 	modelSamp.m CVS version 1.1
% 	modelSamp.m SVN version 24
% 	last update 2007-11-03T14:24:25.000000Z

fhandle = str2func([model.type 'Samp']);
Y = fhandle(model, X);