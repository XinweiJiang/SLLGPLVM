function Acc = sgpReKnnDC( ds, modeltype, nKnn, basedir )
%SGPREKNN Summary of this function goes here
%   Detailed explanation goes here
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

if nargin < 4
    basedir = ['..\Result\mat\' ds '\'];
end

Acc = [];

switch modeltype
    case 'Fgplvm'
        for iii = [1:15]
            matfname = [basedir 'dem' modeltype ds 'Tr' num2str(nTr) 'Te' num2str(nTe) 'L' num2str(iii) '.mat'];
            if exist(matfname,'file') ~= 2
                continue;
            end
            load(matfname, 'retAccCell','zplusY', 'latentDim','y', 'yy','zcInit','zcNoInit','model');
            
            [resultClassInit, classes, distance] = kNN_SGPLVM(zplusY, zcInit, nKnn, model);
            resInit = tabulate(resultClassInit - yy);
            retAccInit = resInit(find(resInit(:,1)==0),3);
            
            [resultClassNoInit, classes, distance] = kNN_SGPLVM(zplusY, zcNoInit, nKnn, model);
            resNoInit = tabulate(resultClassNoInit - yy);
            retAccNoInit = resNoInit(find(resNoInit(:,1)==0),3);
        
            retAccCell.Init = retAccInit;
            retAccCell.NoInit = retAccNoInit;
            retAcc = retAccInit;
            save(matfname, 'retAccCell','retAcc','nKnn','resultClassInit','resInit','retAccInit','resultClassNoInit','resNoInit','retAccNoInit','-append');
            Acc = [Acc; [latentDim size(y,1) size(yy,1) retAcc]];

            clear( 'retAcc', 'retAccCell','latentDim','zplusY', 'y', 'yy','zcInit','zcNoInit','model','resultClassInit','resInit','retAccInit','resultClassNoInit','resNoInit','retAccNoInit');
        end
    case 'SgplvmOri'
        for iii = [1:15]
            matfname = [basedir 'dem' modeltype ds 'Tr' num2str(nTr) 'Te' num2str(nTe) 'L' num2str(iii) '.mat'];
            if exist(matfname,'file') ~= 2
                continue;
            end
            load(matfname, 'retAccCell','latentDim','zplusY','zc','model', 'y', 'yy');
            
            [resultClassKnn, classes, distance] = kNN_SGPLVM(zplusY, zc, nKnn, model.modelR);

            resultKnn = resultClassKnn - yy;
            resKnn = tabulate(resultKnn);
            retAccCell.Knn = resKnn(find(resKnn(:,1)==0),3);
            retAcc = retAccCell.Knn;

            save(matfname, 'retAcc','retAccCell','nKnn','resultClassKnn','resultKnn','resKnn','-append');
            Acc = [Acc; [latentDim size(y,1) size(yy,1) retAcc]];

            clear( 'retAcc', 'retAccCell','latentDim','zplusY','zc','model', 'y', 'yy','resultClassKnn','resultKnn','resKnn');
        end
    case 'Sllgplvm'
        for iii = [1:15]
            matfname = [basedir 'dem' modeltype ds 'Tr' num2str(nTr) 'Te' num2str(nTe) 'L' num2str(iii) '.mat'];
            if exist(matfname,'file') ~= 2
                continue;
            end
            load(matfname, 'latentDim','zplusY','zz','model', 'y', 'yy');
            
            if length(unique(y)) > 2
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
                res = tabulate(result-yy);
                retAcc = res(find(res(:,1)==0),3);
            else
                [resultClass, classes, distance] = kNN(zplusY, zz, nKnn, model);
                result = resultClass - model.YY;
                res = tabulate(result);
                retAcc = res(find(res(:,1)==0),3);
            end

            save(matfname, 'retAcc','nKnn','resultClass','result','res','-append');
            Acc = [Acc; [latentDim size(y,1) size(yy,1) retAcc]];

            clear( 'retAcc','latentDim','zplusY','zz','model', 'y', 'yy','resultClass','result','res');
        end
    otherwise
        error(['unrecognized model type: ' modeltype]);
end

end

