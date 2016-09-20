function [ z, zz, retRMSE ] = RealSllgplvm( dataSetName, x, y, xx, yy, latentDim, Opt )
%REALSLLGPLVM Summary of this function goes here
%   Detailed explanation goes here


randn('seed', 1e5);
rand('seed', 1e5);

type = 'sllgplvm';
experimentNo = 1;

iters = Opt.iters;
dataSetName = [upper(dataSetName(1)), dataSetName(2:length(dataSetName))];
fprintf('Dataset: %s; Latent Dimension:%d; Training Data: %d; Testing Data: %d\n', dataSetName,latentDim,size(x,1),size(xx,1));

if latentDim > size(x,2)
    fprintf('Latent Dimension (%d) is larger than training dimension (%d), return null directly.\n',latentDim, size(x,2));
    z = [];
    zz = [];
    retMSE = 0;
    return;
end

% Set up model
options = fgplvmOptions('ftc');%fitc
options.optimiser = 'optimiMinimize';%scg
options.kern = {'rbfard','white'};
d = size(y, 2);

model = fgplvmCreate(latentDim, d, x, y, options);

% Optimise the model.
model = fgplvmOptimise(model, 1, iters);

% Test model
z = model.X;
zz = xx*model.W;

[mu, varsigma] = gpPosteriorMeanVar(model, zz);

diffZ = mu - yy;
retRMSE = sqrt(sum(diffZ.*diffZ)/length(yy))

if ~isfield(Opt,'isAutoSave') || Opt.isAutoSave == 1
    filename = ['demSllgplvm' dataSetName 'Tr' num2str(size(y,1)) 'Te' num2str(size(yy,1)) 'L' num2str(latentDim)];
    save([filename]);
end

end

