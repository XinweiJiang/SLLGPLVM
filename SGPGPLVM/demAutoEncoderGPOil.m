clc;clear all; close all; st = fclose('all');
randn('seed', 1e7)
rand('seed', 1e7)
Opt.iters = -100;   %-200(scheme in paper), here we reduce the number of iter to 100 for speed
Opt.trainType = 'S';    %S: asynchronous optimization(scheme in paper), or C:simultaneous optimization 
Opt.isAutoSave = 1;
Opt.isAutoClosePlot = 0;
Opt.nKnn = 10;
DS = 'Oil';

% test different kernel functions
KernCell = {{'rbf','white','bias'}%,{'rbfard','white'},...
%             {'lin','white'},{'linard','white'},...
%             {'mlp','white'},{'poly','white'},...
%             {'mlpard','white'},{'polyard','white'},...
%             {'rbf','white','bias'},{'lin','white','bias'},...
%             {'rbfard','white','bias'},{'linard','white','bias'},...
%             {'polyard','white','bias'},{'mlpard','white','bias'}
            };
        
for j = 1: length(KernCell)
    Opt.kernL = KernCell{j};
    for i = 1: length(KernCell)
        Opt.kernR = KernCell{i};
    
        DSName = strcat(DS, ['-' upper(Opt.kernL{1}(1)) Opt.kernL{1}(2:end) ]);
        for c = 2:length(Opt.kernL)
            if strcmp(Opt.kernL{c}, 'white') || strcmp(Opt.kernL{c}, 'bias')
                DSName = strcat(DSName, upper(Opt.kernL{c}(1)));
            else
                DSName = strcat(DSName, [upper(Opt.kernL{c}(1)) Opt.kernL{c}(2:end)]);
            end
        end
        dataSetName = strcat(DSName, ['-' upper(Opt.kernR{1}(1)) Opt.kernR{1}(2:end) ]);
        for c = 2:length(Opt.kernR)
            if strcmp(Opt.kernR{c}, 'white') || strcmp(Opt.kernR{c}, 'bias')
                dataSetName = strcat(dataSetName, upper(Opt.kernR{c}(1)));
            else
                dataSetName = strcat(dataSetName, [upper(Opt.kernR{c}(1)) Opt.kernR{c}(2:end)]);
            end
        end
    
%         dataSetName = [dataSetName 'S'];
        filename = ['retAutoEncoderGP' dataSetName];
        Acc = [];

        [x, y] = lvmLoadData('oil');
        x = sgpNormalize( x,1 );
        [ x, y ] = smgpSort( x, y );
        [ x, y, xx, yy ] = sgpDivTrainTestData( x, y, 200, 1000 );  % each class with 200 samples for training

    %         for latentDim = [1,2,3,5,7,9,11,12];
        for latentDim = [2]
            [ z, zz, retMSE ] = AutoEncoderGP( dataSetName, x, y, xx, yy, latentDim, Opt );
        end    
    end
end