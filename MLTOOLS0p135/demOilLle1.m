
% DEMOILLLE1 Demonstrate LLE on the oil data.
%
%	Description:
%	% 	demOilLle1.m SVN version 99
% 	last update 2009-09-05T21:46:31.000000Z

[Y, lbls] = lvmLoadData('oil');

options = lleOptions(4);
model = lleCreate(2, size(Y, 2), Y, options);
model = lleOptimise(model);

lvmScatterPlot(model, lbls);

if exist('printDiagram') & printDiagram
  lvmPrintPlot(model, lbls, 'Oil', 1);
end

errors = lvmNearestNeighbour(model, lbls);
