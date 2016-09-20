function [z, zz, retAcc,distance] = BinarySAutoEncoderGP(  dataSetName, x, y, xx, yy, latentDim, Opt  )
%BINARYGPGPLVM Summary of this function goes here
%   Detailed explanation goes here

randn('seed', 1e5);
rand('seed', 1e5);

type = 'saegp';
experimentNo = 1;
Threshold = 1e-1;

if ~isfield(Opt, 'kernForGpc')
    Opt.kernForGpc = 0;                 %0 - covLINone; 1 - covSEiso; 2 - covLINard; 3 - covSEard
end

if ~isfield(Opt, 'priorForGpHyper')
    Opt.priorForGpHyper = 0;            %0 - no prior placed over hyperparameters of GP;   1 - Gaussian prior used
end

if ~isfield(Opt, 'priorForGpcHyper')
    Opt.priorForGpcHyper = 0;            %0 - no prior placed over hyperparameters of GPC;   1 - Gaussian prior used
end

model.priorForGpHyper = Opt.priorForGpHyper;
model.priorForGpcHyper = Opt.priorForGpcHyper;

itersX = Opt.itersX;
itersY = Opt.itersY;
if isfield(Opt, 'trainModel') && strcmp(Opt.trainModel, 'seperate') && isfield(Opt, 'itersS')
    itersS = Opt.itersS;
else
    itersS = 20;
end
nKnn = Opt.nKnn;
isAutoClosePlot = Opt.isAutoClosePlot;
dataSetName = [upper(dataSetName(1)), dataSetName(2:length(dataSetName))];
fprintf('BinarySAutoEncoderGP; Dataset: %s; Latent Dimension:%d; Training Data: %d; Testing Data: %d\n', dataSetName,latentDim,size(x,1),size(xx,1));

if latentDim > size(x,2)
    fprintf('Latent Dimension (%d) is larger than training dimension (%d), return null directly.\n',latentDim, size(x,2));
    retZ = [];
    zc = [];
    retAcc = 0;
    return;
end


%-----------         Set up model        -------------%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Model                          Y
%                                |(Laplace)
%                              GPLVM(U) 
%                                |
%                   X--GPLVM(L)--Z--GP(R)--X
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set up the initial parameters
optionsL = fgplvmOptions('ftc');%fitc
optionsL.optimiser = 'optimiMinimize';%scg
if isfield(Opt, 'kernL')
    optionsL.kern = Opt.kernL;%{'rbfard','white'};
end

optionsR = fgplvmOptions('ftc');%fitc
optionsR.optimiser = 'optimiMinimize';%scg
if isfield(Opt, 'kernR')
    optionsR.kern = Opt.kernR;%{'rbfard','white'};
end

model.optionsL = optionsL;
model.optionsR = optionsR;

% Scale outputs to variance 1.
% options.scale2var1 = true;

if size(y,2)>1
    y = smgpTransformLabel( y );
    yy = smgpTransformLabel( yy );
end

z = ppcaEmbed(x, latentDim);
% model.trainModel = 'combined';

if isfield(Opt, 'trainModel') && strcmp(Opt.trainModel, 'seperate')
    model.trainModel = 'seperate';
else
    model.trainModel = 'combined';
end

%-----------         Set up model x = f(g(x))       -------------%
model.modelL = fgplvmCreate(latentDim, size(x,2), z, x, optionsL);
model.modelR = gpCreate(size(x,2), latentDim, x, z, optionsR);

%-----------         Set up model y = g(z)          -------------%
model.gType = type;
model.X0 = x;
model.X = z;
model.Y = y;
model.YY = yy;
[model.N, model.D] = size(x);
model.p = latentDim;
model.isMissingData = 0;

switch Opt.kernForGpc
    case 0
        kern.type = 'covLINone';
        kern.covfunc = cellstr(kern.type);
        kern.length = eval(feval(kern.covfunc{:}));
        kern.hyper = zeros(kern.length, 1);
        kern.variance = exp(-2*kern.hyper(1));                                     % signal variance
    case 1
        kern.type = 'covSEiso';
        kern.covfunc = cellstr(kern.type);
        kern.length = eval(feval(kern.covfunc{:}));
        kern.hyper = zeros(kern.length, 1);
        kern.inverseWidth = 1/exp(kern.hyper(1))/exp(kern.hyper(1));                      % characteristic length scale
        kern.variance = exp(2*kern.hyper(2));                                     % signal variance
    case 2
        kern.type = 'covLINard';
        kern.covfunc = cellstr(kern.type);
        kern.length = eval(feval(kern.covfunc{:}));
        kern.hyper = zeros(kern.length, 1);
        kern.inputScales = exp(-2*kern.hyper');
    case 3
        kern.type = 'covSEard';
        kern.covfunc = cellstr(kern.type);
        kern.length = eval(feval(kern.covfunc{:}));
        kern.hyper = zeros(kern.length, 1);
        kern.inputScales = exp(-2*transpose(kern.hyper(1:kern.length-1)));
        kern.variance = exp(2*kern.hyper(kern.length));        
    otherwise
        error('Unknow kernel for GPC!');
end

model.kern = kern;
model.approx = 'cumGauss';

%---------------      Training         ---------------%

trTime = cputime;
if strcmp(model.trainModel, 'seperate')
    oldZ = z(:);
    for i = 1:itersS
        model.trainModelStage = 1;
        hyper_z = model.modelR.y(:);    
        newloghyper = minimize(hyper_z, 'binaryLaplaceGP', itersX, model.kern.covfunc, model.approx, model);
        
        [ hyper, z, params ] = parseParamForSAEGP( newloghyper, model );
        model.modelR = gpCreate(size(x,2), latentDim, x, z, options);
        model.modelR.options = options;
        model.modelR = gpExpandParam(model.modelR, hyperR');
        
        
        model.trainModelStage = 2;  % only for seperate model
        hyper_z = [model.kern.hyper;hyperR]; 
        newloghyper = minimize(hyper_z, 'binaryLaplaceGP', itersX, model.kern.covfunc, model.approx, model);

        [ hyper, z0, hyperR ] = parseParamForBinary( newloghyper, model );
        model.kern.hyper = hyper;
        switch model.kern.type
            case 'covSEiso'
                model.kern.inverseWidth = 1/exp(model.kern.hyper(1))/exp(model.kern.hyper(1));                           % characteristic length scale
                model.kern.variance = exp(2*model.kern.hyper(2));   
            case 'covLINone'
                model.kern.variance = exp(-2*model.kern.hyper(1));   
            case 'covLINard'
                model.kern.inputScales = exp(-2*hyper');
            case 'covSEard'
                model.kern.inputScales = exp(-2*transpose(hyper(1:model.kern.length-1)));
                model.kern.variance = exp(2*hyper(length(hyper))); 
            otherwise
                error('Unrecognized kernel function!');            
        end   
        
        model.modelR = gpExpandParam(model.modelR, hyperR');        
        
        diffZ = z(:) - oldZ;
        sumDiffZ = sum(diffZ.*diffZ)
        if sumDiffZ < Threshold
            break;
        else
            oldZ = z(:);
        end
    end
else
    paramsL = fgplvmExtractParam(model.modelL);
    hyperL = reshape(paramsL(length(paramsL)-model.modelL.kern.nParams+1:length(paramsL)), 1, model.modelL.kern.nParams);
    hyperR = gpExtractParam(model.modelR);
    hyperU = model.kern.hyper;
    hyper_z = [hyperL';hyperR';hyperU;z(:)];
    newloghyper = minimize(hyper_z, 'binaryLaplaceGP0', itersY, model.kern.covfunc, model.approx, model);
    
    [ hyperL, hyperR, hyperU, z ] = parseParamForSAEGP( newloghyper, model );
    model.modelL = fgplvmExpandParam(model.modelL, [z(:)' hyperL']);
    model.modelR = gpCreate(model.D, model.p, model.X0, z, model.optionsR);
    model.modelR = gpExpandParam(model.modelR, hyperR');
    model.kern.hyper = hyperU;
    switch model.kern.type
        case 'covSEiso'
            model.kern.inverseWidth = 1/exp(model.kern.hyper(1))/exp(model.kern.hyper(1));                           % characteristic length scale
            model.kern.variance = exp(2*model.kern.hyper(2));   
        case 'covLINone'
            model.kern.variance = exp(-2*model.kern.hyper(1));   
        case 'covLINard'
            model.kern.inputScales = exp(-2*model.kern.hyper');
        case 'covSEard'
            model.kern.inputScales = exp(-2*transpose(model.kern.hyper(1:model.kern.length-1)));
            model.kern.variance = exp(2*model.kern.hyper(length(model.kern.hyper))); 
        otherwise
            error('Unrecognized kernel function!');            
    end    
end
trTime = cputime-trTime;

%---------------      Testing         ---------------%

teTime = cputime;
zplusY = [z y];
zz = zeros(size(xx,1), model.p);
% for i = 1:model.p
%     [zz(:,i), varSigma] = gpPosteriorMeanVar(model.modelR{i}, xx);
% end
 
[zz, varSigma] = gpPosteriorMeanVar(model.modelR, xx);
teTime = cputime-teTime;

% Classify testing data with kNN
[resultClass, classes, distance] = kNN(zplusY, zz, nKnn, model);
result = resultClass - model.YY;
res = tabulate(result)
retAccKnn = res(find(res(:,1)==0),3);

% Classify testing data with Gpc
pp = binaryLaplaceGPForGpc(model.kern.hyper, model.kern.type, 'cumGauss', z, y, zz);
retAccGpc = 100*sum((pp>0.5) == (yy>0))/size(yy,1)
varZZ = mean((yy==1).*log2(pp)+(yy==-1).*log2(1-pp))+1;
% retAccGpc = 0;

retAccCell.Knn = retAccKnn;
retAccCell.Gpc = retAccGpc;

if isfield(Opt, 'classifier') && strcmp(Opt.classifier, 'Gpc')
    retAcc = retAccCell.Gpc;
else
    retAcc = retAccCell.Knn;
end


if ispc && isfield(Opt, 'isPlot') && Opt.isPlot == 1
    filename = ['demSAutoEncoderGP' dataSetName 'Tr' num2str(size(z,1)) 'L' num2str(latentDim) upper(model.trainModel(1))];
    plotZ(z, model.Y, filename,isAutoClosePlot);
    filename = ['demSAutoEncoderGP' dataSetName 'Te' num2str(size(zz,1)) 'L' num2str(latentDim) upper(model.trainModel(1))];
    plotZ(zz, model.YY, filename,isAutoClosePlot);
end

if ~isfield(Opt, 'isAutoSave') || Opt.isAutoSave == 0
    filename = ['demSAutoEncoderGP' dataSetName 'Tr' num2str(size(z,1)) 'Te' num2str(size(zz,1)) 'L' num2str(latentDim) upper(model.trainModel(1))];
    save([filename]);
end

end

