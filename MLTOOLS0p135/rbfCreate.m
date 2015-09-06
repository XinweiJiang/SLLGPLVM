function model = rbfCreate(inputDim, outputDim, options)

% RBFCREATE Wrapper for NETLAB's rbf `net'.
%
%	Description:
%	model = rbfCreate(inputDim, outputDim, options)
%% 	rbfCreate.m CVS version 1.2
% 	rbfCreate.m SVN version 24
% 	last update 2007-11-03T14:24:23.000000Z

model = rbf(inputDim, options.hiddenDim, outputDim, options.activeFunc, options.outFunc);
model.numParams = model.nwts;
model.inputDim = inputDim;
model.outputDim = outputDim;
