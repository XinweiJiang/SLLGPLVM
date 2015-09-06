clc;clear all; close all; st = fclose('all');

Opt.iters = -100;       %number of iteration for training
Opt.nKnn = 10;          %parameter K in KNN
Opt.isPlot = 1;         %does automatically plot results?
Opt.isAutoClosePlot = 1;%does automatically close the plot?
Opt.isAutoSave = 1;     %does automatically save results?
dataSetName = 'Usps5And3DC';
filename = ['retSllgplvm' dataSetName 'Accuracy' ];
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

% is it multiple-class or binary-class problem?                                                            %In this demo, we have 300 training data and 700 testing data.
if size(y,2) == 1
    nClass = length(unique(y));
else
    nClass = size(y,2);
end

for latentDim = [2]
    if nClass > 2
        [z, zz, retAcc]  = MultiSllgplvm( dataSetName, x, y, xx, yy, latentDim, Opt );
    else
        [z, zz, retAcc]  = BinarySllgplvm( dataSetName, x, y, xx, yy, latentDim, Opt );
    end
        
    Acc = [Acc; [latentDim size(x,1) size(xx,1) retAcc]];
end

save(filename, 'Acc');
