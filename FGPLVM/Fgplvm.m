function [ z, retAcc, retAccCell ] = Fgplvm( dataSetName, x, y, xx, yy, latentDim, Opt )
%FGPLVM Summary of this function goes here
%   Detailed explanation goes here

randn('seed', 1e5);
rand('seed', 1e5);

type = 'fgplvm';
experimentNo = 1;

itersTrain = Opt.itersTrain;
itersTest = Opt.itersTest;
approxType = Opt.approx;
nKnn = Opt.nKnn;
isAutoClosePlot = Opt.isAutoClosePlot;
dataSetName = [upper(dataSetName(1)) dataSetName(2:length(dataSetName))];
fprintf('Dataset: %s; Latent Dimension:%d; Training Data: %d; Testing Data: %d\n', dataSetName,latentDim,size(x,1),size(xx,1));

if latentDim > size(x,1)
    fprintf('Latent Dimension (%d) is larger than number of training samples (%d), return null directly.\n',latentDim, size(x,1));
    z = [];
    retAcc = 0;
    retAccCell = [];
    return;
end

if latentDim > size(x,2)
    fprintf('Latent Dimension (%d) is larger than training dimension (%d), return null directly.\n',latentDim, size(x,2));
    z = [];
    retAcc = 0;
    retAccCell = [];
    return;
end

%---------------------------- Training --------------------------------%

% Set up model
options = fgplvmOptions(approxType);%fitc
options.optimiser = 'optimiMinimize';%scg
% options.kern = {'poly', 'white', 'bias'};
% options.kern = {'mlp', 'bias', 'white'};
d = size(x, 2);
if d > 400
    options.computeS = true;
end
if isfield(Opt,'back') && Opt.back
    switch Opt.back
        case 1
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            options.back = 'kbr';
            options.backOptions = kbrOptions(x);
            options.backOptions.kern = kernCreate(x, 'rbf');
            options.backOptions.kern.inverseWidth = 0.0001;
        case 2
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            options.back = 'mlp';
            options.backOptions = mlpOptions;
            options.optimiseInitBack = 0;
    end
end

model = fgplvmCreate(latentDim, d, x, options);

% Add dynamics model.
if isfield(Opt,'dynamic') && Opt.dynamic
    switch Opt.dynamic
        case 1
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            optionsDyn = gpReversibleDynamicsOptions('ftc');
    %         optionsDyn.kern.comp{1}.comp{1}.inverseWidth = 1;
            model = fgplvmAddDynamics(model, 'gpReversible', optionsDyn);
        case 2
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            optionsDyn = gpOptions('ftc');
            optionsDyn.kern = kernCreate(model.X, {'rbf', 'white'});
            optionsDyn.kern.comp{1}.inverseWidth = 0.01;
            % This gives signal to noise of 0.1:1e-3 or 100:1.
            optionsDyn.kern.comp{1}.variance = 1;
            optionsDyn.kern.comp{2}.variance = 1e-3^2;
            model = fgplvmAddDynamics(model, 'gpTime', optionsDyn);
        case 3
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            optionsDyn = gpOptions('ftc');
            optionsDyn.kern = kernCreate(model.X, {'rbf', 'white'});
            optionsDyn.kern.comp{1}.inverseWidth = 0.01;
            % This gives signal to noise of 0.1:1e-3 or 100:1.
            optionsDyn.kern.comp{1}.variance = 0.1^2;
            optionsDyn.kern.comp{2}.variance = 1e-3^2;
            model = fgplvmAddDynamics(model, 'gp', optionsDyn);
    end
end

% Optimise the model.
display = 1;

trTime = cputime;
model = fgplvmOptimise(model, display, itersTrain);
trTime = cputime-trTime;

%---------------------------- Testing --------------------------------%

if size(y,2) > 1
    y = smgpTransformLabel( y );
    yy = smgpTransformLabel( yy );
end
zplusY = [model.X y];

% Optimise X With Initilization
teTimeInit = cputime;
zzInit = zeros(size(xx, 1), latentDim);
for i = 1:size(xx, 1)
  llVec = fgplvmPointLogLikelihood(model, model.X, repmat(xx(i, :), model.N, 1));
  [void, ind] = max(llVec);
  zzInit(i, :) = model.X(ind, :);
end
zcInit = zeros(size(zzInit, 1), latentDim);
for i =1:size(zzInit, 1)
  zcInit(i, :) = fgplvmOptimisePoint(model, zzInit(i, :), xx(i, :), 0, itersTest);
end
teTimeInit = cputime-teTimeInit;

% zcInit = modelOut(model.back, xx);

[resultClassInit, classes, distance] = kNN_SGPLVM(zplusY, zcInit, nKnn, model);
resInit = tabulate(resultClassInit - yy)
retAccInit = resInit(find(resInit(:,1)==0),3);


% % Optimise X Without Initilization
% teTimeNoInit = cputime;
% zzNoInit = ppcaEmbed(xx, latentDim); 
% zcNoInit = zeros(size(zzNoInit, 1), latentDim);
% for i =1:size(zzNoInit, 1)
%   zcNoInit(i, :) = fgplvmOptimisePoint(model, zzNoInit(i, :), xx(i, :), 0, itersTest);
% end
% teTimeNoInit = cputime-teTimeNoInit;
% 
% [resultClassNoInit, classes, distance] = kNN_SGPLVM(zplusY, zcNoInit, nKnn, model);
% resNoInit = tabulate(resultClassNoInit - yy)
% retAccNoInit = resNoInit(find(resNoInit(:,1)==0),3);

retAccNoInit = 0;

retAccCell.Init = retAccInit;
retAccCell.NoInit = retAccNoInit;
retAcc = retAccInit;

strtemp = [];
if isfield(model, 'back') && ~isempty(model.back)
    strtemp = [strtemp 'Back' num2str(Opt.back)];
end
if isfield(model, 'dynamics') && ~isempty(model.dynamics)
    strtemp = [strtemp 'Dyn' num2str(Opt.dynamic)];
end

if ispc
    filename = ['demFgplvm' dataSetName 'Tr' num2str(size(x, 1)) 'L' num2str(latentDim) strtemp];
    plotZ(model.X, y, filename,isAutoClosePlot);
    filename = ['demFgplvm' dataSetName 'Te' num2str(size(xx, 1)) 'L' num2str(latentDim) strtemp];
    plotZ(zcInit, yy, filename,isAutoClosePlot);
end

z = model.X;
filename = ['demFgplvm' dataSetName 'Tr' num2str(size(x, 1)) 'Te' num2str(size(xx, 1)) 'L' num2str(latentDim) strtemp];
save([filename]);

end

