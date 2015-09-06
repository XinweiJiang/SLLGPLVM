clc;clear all; close all; st = fclose('all');
randn('seed', 1e5);
rand('seed', 1e5);
Threshold = 1e-1;

Opt.itersTrain = -100;  %number of iteration for training
Opt.itersTest = -100;   %number of iteration for testing
Opt.approx = 'ftc';     %full gplvm
Opt.nKnn = 10;          %parameter K in KNN
Opt.isAutoClosePlot = 1; %does automatically plot results?
dataSetName = 'Usps5And3DC';
Acc = [];

% load data
[x, y, xx, yy] = loadBinaryUSPS(3,5);
xx = [x(51:717,:); xx];
yy = [y(51:717,:); yy];
x1 = x(1:50,:);x2 = x(718:767,:);
x=[x1;x2];
y1 = y(1:50,:);y2 = y(718:767,:);
y=[y1;y2];
clear x1 x2 y1 y2;

%test mutiple dimensionalities of latent space
for latentDim = [1,2,3,4,5,7,9,10,13,15]
    [ z, retAcc ] = Fgplvm( dataSetName, x, y, xx, yy, latentDim, Opt );
    Acc = [Acc; [latentDim size(y,1) size(yy,1) retAcc]];
end

filename = ['retFgplvm' dataSetName 'Accuracy' ];
save(filename, 'Acc');
