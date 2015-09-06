
% DNETTEST Test some settings for the density network.
%
%	Description:
%	% 	dnetTest.m SVN version 24
% 	last update 2009-09-05T21:46:28.000000Z

model = dnetCreate(2, 3, randn(2, 3), dnetOptions);

model.basisStored = false;

modelTest(model)  