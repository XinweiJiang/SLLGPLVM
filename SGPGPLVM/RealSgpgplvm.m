function [ z, zz, retRMSE ] = RealSgpgplvm( dataSetName, x, y, xx, yy, latentDim, Opt )
%REALSLLGPLVM Summary of this function goes here
%   Detailed explanation goes here


randn('seed', 1e5);
rand('seed', 1e5);

model.gtype = 'sgpgplvm';
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
optionsL = fgplvmOptions('ftc');%fitc
optionsL.optimiser = 'optimiMinimize';%scg
optionsL.kern = Opt.kernL;%{'rbfard','white'};

optionsR = fgplvmOptions('ftc');%fitc
optionsR.optimiser = 'optimiMinimize';%scg
optionsR.kern = Opt.kernR;%{'rbfard','white'};

model.optionsL = optionsL;
model.optionsR = optionsR;

d = size(y, 2);
z = ppcaEmbed(x, latentDim);
model.X = x;
model.Y = y;
model.Z = z;
[model.N model.D] = size(x);
model.p = latentDim;

model.modelL = fgplvmCreate(latentDim, d, z, y, optionsL);
model.modelR = gpCreate(size(x,2), latentDim, x, z, optionsR);

% Optimise the model.
model = fgplvmOptimise(model, 1, iters);

% Test model
z = model.Z;
zz = gpPosteriorMeanVar(model.modelR, xx);

[mu, varsigma] = gpPosteriorMeanVar(model.modelL, zz);

diffZ = mu - yy;
retRMSE = sqrt(sum(diffZ.*diffZ)/length(yy))

if ~isfield(Opt,'isAutoSave') || Opt.isAutoSave == 1
    filename = ['demSgpgplvm' dataSetName 'Tr' num2str(size(y,1)) 'Te' num2str(size(yy,1)) 'L' num2str(latentDim)];
    save([filename]);
end

end

