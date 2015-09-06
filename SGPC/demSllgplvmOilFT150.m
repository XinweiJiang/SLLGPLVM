clc;clear all; close all; st = fclose('all');

Opt.iters = -100;       %number of iteration for training
Opt.nKnn = 10;          %parameter K in KNN
Opt.isPlot = 1;         %does automatically plot results?
Opt.isAutoClosePlot = 1;%does automatically close the plot?
Opt.isAutoSave = 1;     %does automatically save results?
dataSetName = 'OilFT150';


% load data
[x, y] = lvmLoadData('oil');
[ x, y ] = smgpSort( x, y );    %sort x according to label y
[ x, y, xx, yy ] = sgpDivTrainTestData( x, y, 50, 1000 );  %divide dataset into training (x,y) and testing data (xx,yy)
                                                            %where each class in training and testing data consists of
                                                            %50, 1000 samples, respectively.
% is it multiple-class or binary-class problem?             %In this demo, we have 150 training data and 700 testing data.
if size(y,2) == 1
    nClass = length(unique(y));
else
    nClass = size(y,2);
end

for latentDim = [2,3]
    if nClass > 2
        [z, zz, retAcc]  = MultiSllgplvm( dataSetName, x, y, xx, yy, latentDim, Opt );  %handle multi-class by multi-class GP classification model
    else
        [z, zz, retAcc]  = BinarySllgplvm( dataSetName, x, y, xx, yy, latentDim, Opt );
    end
end
