function model = mappingOptimise(model, X, Y, varargin)

% MAPPINGOPTIMISE Optimise the given model.
%
%	Description:
%	model = mappingOptimise(model, X, Y, varargin)
%% 	mappingOptimise.m CVS version 1.2
% 	mappingOptimise.m SVN version 24
% 	last update 2007-11-03T14:24:25.000000Z

fhandle = str2func([model.type 'Optimise']);
model = fhandle(model, X, Y, varargin{:});