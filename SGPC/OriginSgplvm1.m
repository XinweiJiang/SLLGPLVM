function  [ retZ, zc, retAcc, retAccCell ]  = OriginSgplvm1( dataSetName, x, y, xx, yy, latentDim, Opt )
%ORIGINSGPLVM Summary of this function goes here
%   Detailed explanation goes here


randn('seed', 1e5);
rand('seed', 1e5);
Threshold = 0.1;%1e-1

type = 'sgplvm';
experimentNo = 1;

itersTrain = Opt.itersTrain;
itersX = Opt.itersX;
itersY = Opt.itersY;
itersTest = Opt.itersTest;
nKnn = Opt.nKnn;
isAutoClosePlot = Opt.isAutoClosePlot;
dataSetName = [upper(dataSetName(1)) dataSetName(2:length(dataSetName))];
fprintf('Dataset: %s; Latent Dimension:%d; Training Data: %d; Testing Data: %d\n', dataSetName,latentDim,size(x,1),size(xx,1));

if latentDim > size(x,2)
    fprintf('Latent Dimension (%d) is larger than training dimension (%d), return null directly.\n',latentDim, size(x,2));
    retZ = [];
    zc = [];
    retAcc = 0;
    return;
end

options = fgplvmOptions('ftc');%fitc
options.optimiser = 'optimiMinimize';%scg
options.gType = type;
% options.kern = {'poly', 'bias', 'white'};
% options.kern = {'rbfard', 'white'};
options.kern = {'rbf','lin', 'white'};
d = size(x, 2);

model.modelR = fgplvmCreate(latentDim, d, x, options);


%-----------         Set up model y = g(z)       -------------%


d = size(y, 2);
% options.kern = {'rbfard', 'lin', 'white'};
options.kern = {'rbfard', 'white'};
options.initX = model.modelR.X;
model.modelL = fgplvmCreate(latentDim, d, y, options);
model.modelL.X = model.modelR.X;


%---------------      Training         ---------------%

trTime = cputime;
% TRAINMODELS = {'hyper','latent'};
TRAINMODELS = {'modelR','modelL'};
oldZ = model.modelR.X(:);
for i = 1:itersTrain
    model.trainModel = TRAINMODELS{1};
    display = 1;
    model = sgpFgplvmOptimise(model, display, itersX);

    model.trainModel = TRAINMODELS{2};
    model = sgpFgplvmOptimise(model, display, itersY);
        
    diffZ = model.modelR.X(:) - oldZ;
    sumDiffZ = sum(diffZ.*diffZ)
    if sumDiffZ < Threshold
        break;
    else
        oldZ = model.modelR.X(:);
    end
end
trTime = cputime-trTime;

%---------------      Testing         ---------------%

teTime = cputime;
zz = zeros(size(xx, 1), latentDim);
for i = 1:size(xx, 1)
  llVec = fgplvmPointLogLikelihood(model.modelR, model.modelR.X, repmat(xx(i, :), model.modelR.N, 1));
  [void, ind] = max(llVec);
  zz(i, :) = model.modelR.X(ind, :);
end
% zz = ppcaEmbed(xx, latentDim); 

% Optimise X
zc = zeros(size(zz, 1), latentDim);
for i = 1:size(zz, 1)
  zc(i, :) = fgplvmOptimisePoint(model.modelR, zz(i, :), xx(i, :), 0, itersTest);
end
teTime = cputime-teTime;

%-------------------Classification/Regression-----------------------%

if ~isfield(Opt, 'modelType') || strcmp(Opt.modelType, 'Classification')
    
    yy = smgpTransformLabel( yy );

    %   Use original GP as classifier in the latent space
    yU = smgpTransformLabel(unique(smgpTransformLabel(y),'rows'));
    yT = smgpTransformLabel( yU );
    resultClassOri = zeros(size(zc, 1), 1);
    for i =1:size(zc, 1)
      [mu, varsigma] = gpPosteriorMeanVar(model.modelL, zc(i, :));
      mu = repmat(mu, size(yU, 1), 1);
      predictLabel = sum((yU-mu).^2, 2);
      nPLabelIndex = find(predictLabel == min(predictLabel),1,'first');
      resultClassOri(i) = yT(nPLabelIndex);
    end

    resultOri = resultClassOri - yy;
    resOri = tabulate(resultOri)
    retAccCell.Ori = resOri(find(resOri(:,1)==0),3);

    %   Use kNN as classifier in the latent space
    y = smgpTransformLabel( y );

    zplusY = [model.modelR.X y];
    [resultClassKnn, classes, distance] = kNN_SGPLVM(zplusY, zc, nKnn, model.modelR);

    resultKnn = resultClassKnn - yy;
    resKnn = tabulate(resultKnn)
    retAccCell.Knn = resKnn(find(resKnn(:,1)==0),3);

    % %   Use 2 kNNs as classifier in the latent space
    % [resultClassKnn2, classes, distance, voteMatrix] = kNN_SGPLVM(zplusY, zc, nKnn, model);
    % 
    % nTest = size(yy,1);
    % resultClassKnn2 = zeros(nTest,1);
    % for i = 1:nTest
    %     ret = zeros(3, 2);
    %     for ci = 1:2
    %         ret(:,ci) = voteMatrix(:,i,ci);
    %     end
    %     [resultClassKnn2(i),ct] = find(ret == max(max(ret)), 1, 'first');
    % end
    % 
    % resultKnn2 = resultClassKnn2 - yy;
    % resKnn2 = tabulate(resultKnn2)
    % retAccCell.Knn2 = resKnn2(find(resKnn2(:,1)==0),3);

    if isfield(Opt, 'classifier') && strcmp(Opt.classifier, 'Ori')
        retAcc = retAccCell.Ori;
    elseif isfield(Opt, 'classifier') && strcmp(Opt.classifier, 'Knn2')
        retAcc = retAccCell.Knn2;
    else
        retAcc = retAccCell.Knn;
    end
else
    %   Regression

    [mu, varsigma] = gpPosteriorMeanVar(model.modelL, zc(i, :));
    diffZ = mu - yy;
    retAcc = sqrt(sum(diffZ.*diffZ)/length(yy))

end

%----------------------------Plot-------------------------------------%

if ~isfield(Opt, 'modelType') || strcmp(Opt.modelType, 'Classification')
    filename = ['demSgplvmOri' dataSetName 'Tr' num2str(size(model.modelR.X, 1)) 'L' num2str(latentDim)];
    plotZ(model.modelR.X, y, filename, isAutoClosePlot);
    filename = ['demSgplvmOri' dataSetName 'Te' num2str(size(zc, 1)) 'L' num2str(latentDim)];
    plotZ(zc, yy, filename, isAutoClosePlot);
end

retZ = model.modelR.X;
filename = ['demSgplvmOri' dataSetName 'Tr' num2str(size(model.modelR.X, 1)) 'Te' num2str(size(zc, 1)) 'L' num2str(latentDim)];
save([filename]);

end

