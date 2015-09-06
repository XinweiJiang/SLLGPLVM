function [ retZ, zz, retAcc ] = MultiSllgplvm( dataSetName, x_tr, out_tr, x_te, out_te, latentDim, Opt )
%MULTISLLGPLVM Summary of this function goes here
%   Detailed explanation goes here


type = 'smcgplvm';
experimentNo = 1;

randn('seed', 1e5);
rand('seed', 1e5);
Threshold = 1e-1;
jitter = 0.01;				% stabilization of covariance
GPCPATH  = ['']; % this is where the GP code sits
DATAPATH = ['']; % this is the data directory
path(GPCPATH,path)			% set up the path for GP routines
outfile = [];
col = [];

iters = Opt.iters;
nKnn = Opt.nKnn;
isAutoClosePlot = Opt.isAutoClosePlot;
dataSetName = [upper(dataSetName(1)) dataSetName(2:length(dataSetName))];
fprintf('Dataset: %s; Latent Dimension:%d; Training Data: %d; Testing Data: %d\n', dataSetName,latentDim,size(x_tr,1),size(x_te,1));

if latentDim > size(x_tr,2)
    fprintf('Latent Dimension (%d) is larger than training dimension (%d), return null directly.\n',latentDim, size(x_tr,2));
    retZ = [];
    zc = [];
    retAcc = 0;
    return;
end

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
options(14) = iters;		% Number of iterations
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


d = size(x_tr, 2);
z = ppcaEmbed(x_tr, latentDim); 
w = x_tr\z;

global model
% model.modelR = modelR;
model.gType = type;
model.X = x_tr;
model.Y = out_tr;
model.Z = z;
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
hyper_w = [hyper; w(:)];

hyper_w = driverm(dataSetName,col,outfile,DATAPATH,x_tr,out_tr,x_te,out_te,meth,...
  options,hyper_w,hmcopt,mean_prior,var_prior,jitter);

[ model.kern.hyper, w ] = parseParam( hyper_w, model );
trTime = cputime-trTime;

%---------------      Testing         ---------------%

model.Z = model.X*w;
y = smgpTransformLabel( model.Y );
yy = smgpTransformLabel( model.YY );
zplusY = [model.Z y];

teTime = cputime;
zz = model.XX*w;
teTime = cputime-teTime;

%------------   Classification with KNN  ------------%
[resultClass, classes, distance, voteMatrix] = kNN(zplusY, zz, nKnn, model);

nTest = length(yy);
result = zeros(nTest,1);
for i = 1:nTest
    ret = zeros(model.M, model.M);
    for ci = 1:model.M
        ret(:,ci) = voteMatrix(:,i,ci);
    end
    [result(i),ct] = find(ret == max(max(ret)), 1, 'first');
end
res = tabulate(result-yy)
retAcc = res(find(res(:,1)==0),3);

filename = ['demSllgplvm' dataSetName 'Tr' num2str(size(model.Z,1)) 'L' num2str(model.p)];
plotZ(model.Z,model.Y,filename,isAutoClosePlot);
filename = ['demSllgplvm' dataSetName 'Te' num2str(size(zz,1)) 'L' num2str(model.p)];
plotZ(zz,model.YY,filename,isAutoClosePlot);

retZ = model.Z;
filename = ['demSllgplvm' dataSetName 'Tr' num2str(size(model.Z,1)) 'Te' num2str(size(zz,1)) 'L' num2str(model.p)];
save([filename '.mat']);

end

