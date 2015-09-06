clc;clear all; close all; st = fclose('all');
randn('seed', 1e5);
rand('seed', 1e5);
Threshold = 1e-1;

Opt.itersTrain = -100;  %number of iteration for training
Opt.itersTest = -100;   %number of iteration for testing
Opt.approx = 'ftc';     %full gplvm
Opt.nKnn = 10;          %parameter K in KNN
Opt.isAutoClosePlot = 1;    %does automatically plot results?
dataSetName = 'OilFT150';
Opt.back = 0;       %back-constrain: 0-none
Opt.dynamic = 0;    %dynamic: 0-none

% load data
[x, y] = lvmLoadData('oil');
x = sgpNormalize( x );      %normalize the input x
[ x, y ] = smgpSort( x, y );    %sort x according to label y
[ x, y, xx, yy ] = sgpDivTrainTestData( x, y, 50, 1000 );  %divide dataset into training (x,y) and testing data (xx,yy)
                                                            %where each class in training and testing data consists of
                                                            %50, 1000 samples, respectively.
                                                            %In this demo, we have 150 training data and 700 testing data.
latentDim = 2;  %set dimensionality of latent space
Fgplvm( dataSetName, x, y, xx, yy, latentDim, Opt );


