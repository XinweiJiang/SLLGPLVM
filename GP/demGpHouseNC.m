clc;clear all; close all; st = fclose('all');
randn('seed', 1e7)
rand('seed', 1e7)
Opt.iters = -1000;
dataSetName = 'House';
filename = ['retGpr' dataSetName 'Error' ];
Acc = [];

% for nTr = [200]
for nTr = [50:50:400]

    load('Housing.mat');
%     indTr = unidrnd(size(x,1),nTr,1);
    indTr = [1:nTr]';
    indTe = setdiff([1:length(y)], indTr)';
    xx = x(indTe,:);
    yy = y(indTe,:);
    x = x(indTr,:);
    y = y(indTr,:);
    
    % Set up the model
    options = gpOptions('ftc');
    options.optimiser = 'optimiMinimize';%scg
    options.kern = {'rbfard','white'};

    % Scale outputs to variance 1.
    % options.scale2var1 = true;

    % Use the full Gaussian process model.
    q = size(x, 2);
    d = size(y, 2);
    model = gpCreate(q, d, x, y, options);

    display = 1;
    iters = Opt.iters;

    model = gpOptimise(model, display, iters);

    [mu, varSigma] = gpPosteriorMeanVar(model, xx);

    diffZ = mu - yy;
    retMSE = sqrt(sum(diffZ.*diffZ)/length(yy));
    
    Acc = [Acc; [size(y,1) size(yy,1) retMSE]];
    
    clear x y xx yy indTr indTe model;
end

save(filename, 'Acc');
