function [ z, zz, retAcc ] = SAutoEncoderGP( dataSetName, x, y, xx, yy, latentDim, Opt )
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
dataSetName = [upper(dataSetName(1)), dataSetName(2:length(dataSetName))];
fprintf('Dataset: %s; Latent Dimension:%d; Training Data: %d; Testing Data: %d\n', dataSetName,latentDim,size(x,1),size(xx,1));

if latentDim > size(x,2)
    fprintf('Latent Dimension (%d) is larger than training dimension (%d), return null directly.\n',latentDim, size(x,2));
    z = [];
    zz = [];
    retAcc = 0;
    return;
end

% Set up model                   Y
%                                |
%                              GPLVM(U) 
%                                |
%%%%%%%%%%%%%%%     X--GPLVM(L)--Z--GP(R)--X     %%%%%%%%%%%

optionsL = fgplvmOptions('ftc');%fitc
optionsL.optimiser = 'optimiMinimize';%scg
optionsL.kern = Opt.kernL;%{'rbfard','white'};

optionsR = fgplvmOptions('ftc');%fitc
optionsR.optimiser = 'optimiMinimize';%scg
optionsR.kern = Opt.kernR;%{'rbfard','white'};

optionsU = fgplvmOptions('ftc');%fitc
optionsU.optimiser = 'optimiMinimize';%scg
optionsU.kern = Opt.kernU;%{'rbfard','white'};

model.optionsL = optionsL;
model.optionsR = optionsR;
model.optionsU = optionsU;

if size(y,2)==1
    y = smgpTransformLabel( y );
    yy = smgpTransformLabel( yy );
end
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
model.modelU = fgplvmCreate(latentDim, size(y,2), z, y, optionsU);

% Optimise the model.
switch Opt.trainType
    case 'C'
        model.alpha = Opt.alpha;model.beta = Opt.beta;
        model = fgplvmOptimiseSAE(model, 1, iters);         % GPLVM + GP + GPLVM(Combined)
    case 'S1'
        model = fgplvmOptimiseSAE1(model, 1, iters);        % GPLVM + GP + GPLVM(Seperate)
    case 'S2'
        model = fgplvmOptimiseSAE2(model, 1, iters);        % SGPGPLVM + GPLVM
    case 'S3'
        model = fgplvmOptimiseSAE3(model, 1, iters);        % SGPGPLVM + GPAM(Combined)
    case 'S4'
        model = fgplvmOptimiseSAE4(model, 1, iters);        % SGPGPLVM + GPAM(Seperate)
    case 'S5'
        model = fgplvmOptimiseSAE5(model, 1, iters);        % SGPGPLVM + SGPLVM
    otherwise
        error('unrecognized traintype!');
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

filename = ['demSAutoEncoderGP' dataSetName 'Tr' num2str(size(z,1)) 'Te' num2str(size(zz,1)) 'L' num2str(latentDim) Opt.trainType];

if ~isfield(Opt, 'isAutoSave') || Opt.isAutoSave == 1
    plotZ(z, y, filename,Opt.isAutoClosePlot);
    save([filename '.mat']);
end


end

