function [ Acc, AccCell ] = sgpSgplvmOriReTest( ds, type, basedir )
%SGPSGPLVMORIRETEST Summary of this function goes here
%   Detailed explanation goes here

Acc = [];
AccCell = [];
AccCell.Knn = [];
AccCell.Ori = [];

if nargin < 3
    basedir = ['..\Result\mat\' ds '\'];
end

switch ds
    case 'Usps5And3DC'
        nTr = 100;
        nTe = 1440;
    case 'WineDC'
        nTr = 90;
        nTe = 88;
    otherwise
        error(['unrecognized dataset name: ' ds]);
end

% Re-test data with original testing approach
if strcmpi(type, 'Ori')

    for iii = [1:15]

        matfname = [basedir 'demSgplvmOri' ds 'Tr' num2str(nTr) 'Te' num2str(nTe) 'L' num2str(iii) '.mat'];
        if exist(matfname,'file') ~= 2
            continue;
        end

        load(matfname,'y','model','yy','zc','latentDim','retAcc');
        AccCell.Knn = [AccCell.Knn; [latentDim size(y,1) size(yy,1) retAcc]];
        yU = smgpTransformLabel(unique(y));
        yT = smgpTransformLabel( yU );
        resultClassOri = zeros(size(zc, 1), 1);
        for i =1:size(zc, 1)
          [mu, varsigma] = gpPosteriorMeanVar(model.modelL, zc(i, :));
          mu = repmat(mu, size(yU, 1), 1);
          predictLabel = sum((yU-mu).^2, 2);
          nPLabelIndex = find(predictLabel == min(predictLabel));
          resultClassOri(i) = yT(nPLabelIndex);
        end

        result = resultClassOri - yy;
        res = tabulate(result);
        retAcc = res(find(res(:,1)==0),3);

        Acc = [Acc; [latentDim size(y,1) size(yy,1) retAcc]];
        clear( 'result','res','retAcc', 'y','model','yy','zc','latentDim');
    end
    
    AccCell.Ori = Acc;
elseif strcmpi(type, 'Knn')
    % Re-test data with kNN
    for iii = [1:15]

        matfname = [basedir 'demSgplvmOri' ds 'Tr' num2str(nTr) 'Te' num2str(nTe) 'L' num2str(iii) '.mat'];
        if exist(matfname,'file') ~= 2
            continue;
        end

        load(matfname,'y','model','yy','zc','latentDim','retAcc','nKnn');
        AccCell.Ori = [AccCell.Ori; [latentDim size(y,1) size(yy,1) retAcc]];
        if size(y,2) > 1
            y = smgpTransformLabel( y );
        end
        zplusY = [model.modelR.X y];
        [resultClass, classes, distance] = kNN_SGPLVM(zplusY, zc, nKnn, model.modelR);

        result = resultClass - yy;
        res = tabulate(result);
        retAcc = res(find(res(:,1)==0),3);

        Acc = [Acc; [latentDim size(y,1) size(yy,1) retAcc]];
        clear( 'result','res','retAcc', 'y','model','yy','zc','latentDim','nKnn');
    end
    
    AccCell.Knn = Acc;
else
    error('Wrong Type!');
end


filename = ['retSgplvmOri' ds 'ReTestAccuracy' ];
save(filename, 'Acc');

end

