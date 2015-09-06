function options = modelOptions(modelType, varargin)

% MODELOPTIONS Returns a default options structure for the given model.
%
%	Description:
%
%	OPTIONS = MODELOPTIONS(MODELTYPE, ...) returns a default options
%	structure for the given model.
%	 Returns:
%	  OPTIONS - options structure.
%	 Arguments:
%	  MODELTYPE - the type of model.
%	  ... - optional additional arguments (dependent on model type).
%	
%
%	See also
%	MODELCREATE


%	Copyright (c) 2006 Neil D. Lawrence
% 	modelOptions.m CVS version 1.1
% 	modelOptions.m SVN version 24
% 	last update 2007-11-03T14:24:24.000000Z

fhandle = str2func([modelType 'Options']);
options = fhandle(varargin{:});