clc;clear all; close all; st = fclose('all');

Opt.iters = -100;       %number of iteration for training
Opt.nKnn = 10;          %parameter K in KNN
Opt.isPlot = 1;         %does automatically plot results?
Opt.isAutoClosePlot = 1;%does automatically close the plot?
Opt.isAutoSave = 1;     %does automatically save results?
dataSetName = 'OilNC';
filename = ['retSllgplvm1VsRest' dataSetName 'Accuracy' ];
Acc = [];

for i=[50]       %change the number of training data     [10:10:100] 

    nTrOfEachClass = i; %number of training data for each class
    nTeOfEachClass = 1000;%number of testing data for each class
    % load data
    [x, y] = lvmLoadData('oil');
    [ x, y ] = smgpSort( x, y );    %sort x according to label y
    [ x, y, xx, yy ] = sgpDivTrainTestData( x, y, nTrOfEachClass, nTeOfEachClass );%divide dataset into training (x,y) and testing data (xx,yy)
                                                            %where each class in training and testing data consists of
                                                            %100, 1000 samples, respectively.
    % is it multiple-class or binary-class problem?
    if size(y,2) == 1
        nClass = length(unique(y));
    else
        nClass = size(y,2);
    end

    %test mutiple dimensionalities of latent space
    for latentDim = [9]
        if nClass > 2
            [retAcc]  = MultiSllgplvm1VsRest( dataSetName, x, y, xx, yy, latentDim, Opt );  %handle multi-class by one versus rest scheme
        else
            [z, zz, retAcc]  = BinarySllgplvm( dataSetName, x, y, xx, yy, latentDim, Opt );
        end
        
        Acc = [Acc; [latentDim size(x,1) size(xx,1) retAcc]];
    end
end

save(filename, 'Acc');
