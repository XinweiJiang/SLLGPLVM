function [retZ, zz, retAcc,distance] = BinarySllgplvm(  dataSetName, x, y, xx, yy, latentDim, Opt  )
%BINARYSGPLVM Summary of this function goes here
%   Detailed explanation goes here

randn('seed', 1e5);
rand('seed', 1e5);

type = 'sllgplvm';
experimentNo = 1;

iters = Opt.iters;
nKnn = Opt.nKnn;
isAutoClosePlot = Opt.isAutoClosePlot;
dataSetName = [upper(dataSetName(1)), dataSetName(2:length(dataSetName))];
fprintf('Dataset: %s; Latent Dimension:%d; Training Data: %d; Testing Data: %d\n', dataSetName,latentDim,size(x,1),size(xx,1));

if latentDim > size(x,2)
    fprintf('Latent Dimension (%d) is larger than training dimension (%d), return null directly.\n',latentDim, size(x,2));
    retZ = [];
    zc = [];
    retAcc = 0;
    return;
end

% Initlize W for the supervised model Y=g(Z)=g(XW)
z = ppcaEmbed(x, latentDim);
if rank(x) ~= size(x,2)
    w = pinv(x)*z;
else
    w = x\z;
end

model.gType = type;
model.X = x;
model.Y = y;
model.Z = z;
model.W = w;
model.YY = yy;
[model.N, model.D] = size(x);
model.p = latentDim;
model.isMissingData = 0;

kern.hyper = [0; 0];
kern.type = 'covSEiso';
kern.covfunc = cellstr(kern.type);
kern.length = eval(feval(kern.covfunc{:}));
kern.inverseWidth = exp(kern.hyper(1));                           % characteristic length scale
kern.variance = exp(2*kern.hyper(2));                                     % signal variance

model.kern = kern;
model.approx = 'cumGauss';

%---------------      Training         ---------------%

trTime = cputime;
hyper_w = [model.kern.hyper;w(:)];
newloghyper = minimize(hyper_w, 'binaryLaplaceGP', iters, model.kern.covfunc, model.approx, model);
trTime = cputime-trTime;

startVal = 1;
endVal = model.kern.length;
model.kern.hyper = reshape(newloghyper(startVal:endVal), model.kern.length, 1);
model.kern.inverseWidth = 1/exp(model.kern.hyper(1))/exp(model.kern.hyper(1));                           % characteristic length scale
model.kern.variance = exp(2*model.kern.hyper(2));   
startVal = endVal+1;
endVal = endVal + model.D*model.p;
w = reshape(newloghyper(startVal:endVal), model.D, model.p);

%---------------      Testing         ---------------%

model.Z = x*w;
zplusY = [model.Z y];

teTime = cputime;
zz = xx*w;
teTime = cputime-teTime;

%------------   Classification with KNN  ------------%
[resultClass, classes, distance] = kNN(zplusY, zz, nKnn, model);
result = resultClass - model.YY;
res = tabulate(result)
retAcc = res(find(res(:,1)==0),3);

if isfield(Opt, 'isPlot') && Opt.isPlot == 1
    filename = ['demSllgplvm' dataSetName 'Tr' num2str(size(model.Z,1)) 'L' num2str(latentDim)];
    plotZ(model.Z, model.Y, filename,isAutoClosePlot);
    filename = ['demSllgplvm' dataSetName 'Te' num2str(size(zz,1)) 'L' num2str(latentDim)];
    plotZ(zz, model.YY, filename,isAutoClosePlot);
end

retZ = model.Z;
if isfield(Opt, 'isAutoSave') && Opt.isAutoSave == 1
    filename = ['demSllgplvm' dataSetName 'Tr' num2str(size(model.Z,1)) 'Te' num2str(size(zz,1)) 'L' num2str(latentDim)];
    save([filename]);
end

end

