function [ z, zz, retAcc ] = AutoEncoderGP( dataSetName, x, y, xx, yy, latentDim, Opt )
%REALSLLGPLVM Summary of this function goes here
%   Detailed explanation goes here


randn('seed', 1e5);
rand('seed', 1e5);

model.gType = 'autoencodergp';
experimentNo = 1;

iters = Opt.iters;
if isfield(Opt, 'threshold')
    model.threshold = Opt.threshold;
end
if ~isfield(Opt, 'trainType')
    Opt.trainType = 'S';
end
dataSetName = [upper(dataSetName(1)), dataSetName(2:length(dataSetName))];
fprintf('Dataset: %s; Latent Dimension:%d; Training Data: %d; Testing Data: %d\n', dataSetName,latentDim,size(x,1),size(xx,1));

if latentDim > size(x,2)
    fprintf('Latent Dimension (%d) is larger than training dimension (%d), return null directly.\n',latentDim, size(x,2));
    z = [];
    zz = [];
    retAcc = 0;
    return;
end

% Set up model        
%%%%%%%%%%%%%%%     X--GPLVM(L)--Z--GP(R)--X     %%%%%%%%%%%
optionsL = fgplvmOptions('ftc');%fitc
optionsL.optimiser = 'optimiMinimize';%scg
optionsL.kern = Opt.kernL;%{'rbfard','white'};

optionsR = fgplvmOptions('ftc');%fitc
optionsR.optimiser = 'optimiMinimize';%scg
optionsR.kern = Opt.kernR;%{'rbfard','white'};

model.optionsL = optionsL;
model.optionsR = optionsR;

d = size(x, 2);
z = ppcaEmbed(x, latentDim);
model.X = x;
model.Y = y;
model.Z = z;
[model.N model.D] = size(x);
model.p = latentDim;
model.M = latentDim;
model.modelL = fgplvmCreate(latentDim, d, z, x, optionsL);
model.modelR = gpCreate(size(x,2), latentDim, x, z, optionsR);

% Optimise the model.
if Opt.trainType == 'C'     %   simultaneous optimization
    model = fgplvmOptimise(model, 1, iters);
elseif Opt.trainType == 'S'     %   asynchronous optimization
    model = fgplvmOptimise1(model, 1, iters);
else
    error('unrecognized train type!');
end

% Test model
z = model.Z;
zz = gpPosteriorMeanVar(model.modelR, xx);

% Classify testing data with kNN
if size(y,2)>1
    y = smgpTransformLabel( y );
    yy = smgpTransformLabel( yy );
end
zplusY = [z y];
[resultClass, classes, distance] = kNN(zplusY, zz, Opt.nKnn, model);
result = resultClass - yy;
res = tabulate(result)
retAccKnn = res(find(res(:,1)==0),3);

% Classify testing data with Gpc
% pp = binaryLaplaceGPForGpc(model.kern.hyper, model.kern.type, 'cumGauss', z, y, zz);
% retAccGpc = 100*sum((pp>0.5) == (yy>0))/size(yy,1)
% varZZ = mean((yy==1).*log2(pp)+(yy==-1).*log2(1-pp))+1;
retAccGpc = 0;

retAccCell.Knn = retAccKnn;
retAccCell.Gpc = retAccGpc;

if isfield(Opt, 'classifier') && strcmp(Opt.classifier, 'Gpc')
    retAcc = retAccCell.Gpc;
else
    retAcc = retAccCell.Knn;
end

filename = ['demAutoEncoderGP' dataSetName 'Tr' num2str(size(z,1)) 'Te' num2str(size(zz,1)) 'L' num2str(latentDim) Opt.trainType];

if ~isfield(Opt, 'isAutoSave') || Opt.isAutoSave == 1
    plotZ(z, y, filename,Opt.isAutoClosePlot);
    save([filename]);
end


end

