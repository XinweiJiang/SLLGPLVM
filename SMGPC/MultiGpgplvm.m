function [ z, zz, retAcc ] = MultiGpgplvm( dataSetName, x_tr, out_tr, x_te, out_te, latentDim, Opt )
%MULTISLLGPLVM Summary of this function goes here
%   Detailed explanation goes here


type = 'mgpgplvm';
experimentNo = 1;

randn('seed', 1e5);
rand('seed', 1e5);
Threshold = 1e-1;
jitter = 0.01;				% stabilization of covariance
GPCPATH  = ['']; % this is where the GP code sits
DATAPATH = ['']; % this is the data directory
path(GPCPATH,path)			% set up the path for GP routines
col = [];

global model N_Split;
global invS4 invS5 B invSxTVEC sinvSxTVEC makepredflag;

itersX = Opt.itersX;
itersY = Opt.itersY;
if isfield(Opt, 'trainModel') && strcmp(Opt.trainModel, 'seperate') && isfield(Opt, 'itersS')
    itersS = Opt.itersS;
else
    itersS = 1;
end
N_Split = Opt.nSplit;
nKnn = Opt.nKnn;
isAutoClosePlot = Opt.isAutoClosePlot;
dataSetName = [upper(dataSetName(1)) dataSetName(2:length(dataSetName))];
outfile = ['demGpgplvm' dataSetName 'Tr' num2str(size(out_tr, 1)) 'Te' num2str(size(out_te, 1))];
fprintf('MultiGpgplvm V2.1; Dataset: %s; Latent Dimension:%d; Training Data: %d; Testing Data: %d\n', dataSetName,latentDim,size(x_tr,1),size(x_te,1));

if latentDim > size(x_tr,2)
    fprintf('Latent Dimension (%d) is larger than training dimension (%d), return null directly.\n',latentDim, size(x_tr,2));
    retZ = [];
    zc = [];
    retAcc = 0;
    return;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Model : Y = GP(Z) = GP(GP(X))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------         Set up model z = g(x)       -------------%


% Initlize Z by creating Z = GP(X)

% Set up the model
optionsGP = gpOptions('ftc');
optionsGP.optimiser = 'optimiMinimize';%scg
if isfield(Opt, 'kern')
    optionsGP.kern = Opt.kern;
end
% optionsGP.kern = {'rbf','lin','white'};

% Scale outputs to variance 1.
% options.scale2var1 = true;

% Use the full Gaussian process model
% If latentDim (dimensionality of Z) is more than 1, then multi independent
% GPs are modeled

z = ppcaEmbed(x_tr, latentDim);
model.trainModel = 'combined';

if isfield(Opt, 'trainModel') && strcmp(Opt.trainModel, 'seperate')
    model.trainModel = 'seperate';
    model.modelR = gpCreate(model.D, latentDim, x_tr, z, optionsGP);
else
    model.modelR = gpCreate(size(x_tr,2), latentDim, x_tr, z, optionsGP);
    model.modelR.options = optionsGP;
    hyperR = gpExtractParam(model.modelR);
end

%-----------         Set up model y = g(z)       -------------%


meth = 'ml';                % use MAP estimate only
% meth = 'ml_hmc';			% use MAP as inital w for HMC
% other options are meth = 'ml' or meth = 'hmc'

npc = latentDim + 2;		% number of parameters per class
rand('state',0);				% set the seed
randn('state',0);

m = size(out_tr,2);					% number of classes
hyper = rand(m*npc, 1);			% initial paramters

parvec = pak(m, size(x_tr,1), size(x_te,1)); % a vector of useful parameters

% MAP hyperparameter SCG search
options = zeros(1,18);		% Default options vector.
options(1) = 1;			% Display error values
options(14) = itersY;		% Number of iterations
options(9) = 0;			% 1 => do a gradient check
 
% HMC options
hmcopt(1) = 10;			% number of retained samples
hmcopt(2) = 10;			% trajectory length
hmcopt(3) = 5;			% burn in
hmcopt(4) = 0.2;		% step size

% Set up the Gaussian hyperprior distributions for the parameters.
% For M independent classes, there are M different sets
% of covariance	parameters to specify.
% For each class, the first component is the scale
% and the last is the bias. 

% scale and bias:
for ci = 1:m
  mean_prior(ci,1) = -3;		% mean scale
  var_prior(ci,1) = 9;			% variance of scale
  mean_prior(ci,npc) = -3;		% mean bias
  var_prior(ci,npc) = 9;		% variance of bias
end

% input attribute hyperparameters:
for ci = 1:m
  mean_prior(ci,2:npc-1)  = -3.*ones(1,npc-2); 
  var_prior(ci,2:npc-1)   = 9.*ones(1,npc-2);
end

% model.modelR = modelR;
model.gType = type;
model.X = z;
model.Y = out_tr;
model.XX = x_te;
model.YY = out_te;
[model.N, model.D] = size(x_tr);
model.M = m;        % Number of Class
model.p = latentDim;
model.isMissingData = 0;
model.isTranspose = 0;

kern.hyper = hyper;
kern.type = 'covMulitRbfArd';
kern.length = size(hyper,1);
model.kern = kern;
model.approx = 'cumGauss';
model.optimiser = 'minimize'; % scg or minimize

%---------------      Training         ---------------%

trTime = cputime;
if strcmp(model.trainModel, 'seperate')
    oldZ = z(:);
    for i = 1:itersS
        hyper_z = [model.kern.hyper;z(:)];    
        hyper_z = driverm(dataSetName,col,outfile,DATAPATH,z,out_tr,x_te,out_te,meth,...
  options,hyper_z,hmcopt,mean_prior,var_prior,jitter);

        [ model.kern.hyper, z, hyperR ] = parseParam( hyper_z, model );    
        model.modelR = gpCreate(model.D, latentDim, x_tr, z, optionsGP);
        model.modelR = gpOptimise(model.modelR, 1, itersX);
%         z = model.modelR.y;
%         [z, varSigma] = gpPosteriorMeanVar(model.modelR, x_tr);

        diffZ = z(:) - oldZ;
        sumDiffZ = sum(diffZ.*diffZ)
        if sumDiffZ < Threshold
            break;
        else
            oldZ = z(:);
        end
    end
else
    hyper_z = [model.kern.hyper;z(:);hyperR'];
    hyper_z = driverm(dataSetName,col,outfile,DATAPATH,z,out_tr,x_te,out_te,meth,...
  options,hyper_z,hmcopt,mean_prior,var_prior,jitter);

    [ model.kern.hyper, z, hyperR ] = parseParam( hyper_z, model );  
    model.modelR.y = z;    
    model.modelR = gpExpandParam(model.modelR, hyperR');
end
trTime = cputime-trTime;

%---------------      Testing         ---------------%

y = smgpTransformLabel( model.Y );
yy = smgpTransformLabel( model.YY );

teTime = cputime;
zplusY = [z y];
[zz, varSigma] = gpPosteriorMeanVar(model.modelR, x_te);
teTime = cputime-teTime;

[resultClass, classes, distance, voteMatrix] = kNN(zplusY, zz, nKnn, model);

nTest = length(yy);
% result = zeros(nTest, model.M);
% for ci = 1:model.M
%     result = resultClass(:,ci) - yy;
%     res = tabulate(result)
% end
result = zeros(nTest,1);
for i = 1:nTest
    ret = zeros(model.M, model.M);
    for ci = 1:model.M
        ret(:,ci) = voteMatrix(:,i,ci);
    end
    [result(i),ct] = find(ret == max(max(ret)), 1, 'first');
end
res = tabulate(result-yy)
retAccKnn = res(find(res(:,1)==0),3);

% Prediction options when using the hyperparameter sample(s)
retAccGpc = 0;
if isfield(model, 'gType') && strcmp(model.gType, 'mgpgplvm') && ~(isfield(Opt, 'noGpc') && Opt.noGpc == 1)
  fname = [outfile,'.ml'];

  fid_w = fopen([fname,'.smp'],'w');	% store ML parameters to a file
  mprintf(fid_w,'%f',model.kern.hyper); fclose(fid_w);
  
  potential = 'mpot';gradpot = 'mgrad';makeclasspred= 'makepredm';
  makepredflag = 1;
  dummie = feval(potential,hyper_z);	% 	set global variables for makeclasspred
  makepredflag = 0;

  zt = z';zzt = zz';
  ntr = model.N;
  nte = nTest;
  ntrte = ntr+nte;
  nd = size(zt,1);			% number of input dimensions
  
  if nte > N_Split
      for i = 1:ceil(size(zzt,2)/N_Split)
          nBeg = (i-1)*N_Split+1;
          nEnd = i*N_Split;
          if nEnd > size(zzt,2)
              nEnd = size(zzt,2);
          end
          zzt0 = zzt(:, nBeg:nEnd);
        
          nte0 = size(zzt0,2);
          x_all0 = zeros(nd, ntr + nte0);
          x_all0(:,1:ntr) = zt; 
          x_all0(:,ntr+1:ntr+nte0) = zzt0;
          [mlout0,mlss0] = feval(makeclasspred,model.kern.hyper,zt,ntr,nte0,x_all0,m,jitter,B,invSxTVEC,invS4,invS5); % make predictions
          fname = [outfile num2str(i) '.ml'];
          putmclass(fname,mlout0,mlss0,m);	% store the predictive gaussians
      end
  else
      x_all = [zt zzt];
      [mlout,mlss] = feval(makeclasspred,model.kern.hyper,zt,ntr,nte,x_all,m,jitter,B,invSxTVEC,invS4,invS5); % make predictions
      putmclass(fname,mlout,mlss,m);	% store the predictive gaussians
  end

    reject = 0;	% number of hyperparameter samples rejected when predicting
    gsmp = 100;	% number of activation samples in softmax posterior average

    out_trte = [out_tr; out_te]';
    [ty_all,tru_all]=max(out_trte);			% correct predictions
    tru = tru_all(1,ntr+1:ntrte);

    [meanpred_all] = final_pred([outfile,'.ml'], reject, gsmp, parvec);
    [py_all,pred_all]=max(meanpred_all');		% GP predictions
    pred = pred_all(1,ntr+1:ntrte);

    retAccGpc = length(find(pred-tru==0))/nte*100
end

retAccCell.Knn = retAccKnn;
retAccCell.Gpc = retAccGpc;

if isfield(Opt, 'classifier') && strcmp(Opt.classifier, 'Gpc')
    retAcc = retAccCell.Gpc;
else
    retAcc = retAccCell.Knn;
end

if ispc && isfield(Opt, 'isPlot') && Opt.isPlot == 1
    filename = ['demGpgplvm' dataSetName 'Tr' num2str(size(z,1)) 'L' num2str(model.p) upper(model.trainModel(1))];
    plotZ(z,model.Y,filename,isAutoClosePlot);
    filename = ['demGpgplvm' dataSetName 'Te' num2str(size(zz,1)) 'L' num2str(model.p) upper(model.trainModel(1))];
    plotZ(zz,model.YY,filename,isAutoClosePlot);
end

filename = ['demGpgplvm' dataSetName 'Tr' num2str(size(z,1)) 'Te' num2str(size(zz,1)) 'L' num2str(model.p) upper(model.trainModel(1))];
save([filename '.mat']);

end

