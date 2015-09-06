function Acc = sgpReKnnNC( ds, modeltype, nKnn, basedir )
%SGPREKNN Summary of this function goes here
%   Detailed explanation goes here
nMinus = 0;
switch ds
     case 'IonosphereNC'
        LoopArr = [20:20:200];
        nStep = 20;
        LatentDimArr = [3,5,9,11,15];
        nTeArr = 351-LoopArr;
    case 'OilNC'
        LoopArr = [30:30:300];
        nStep = 30;
        LatentDimArr = [2,5,9];
        nTeArr = 1000-LoopArr;
    case 'VehicleNC'
        LoopArr = [20:20:200];
        nStep = 20;
        LatentDimArr = [5,9,15];
        nTeArr = 846-LoopArr;
    case 'Usps0To4NC'
        LoopArr = [25:25:200];
        nStep = 25;
%         nMinus = 4;
        LatentDimArr = [2,5,9,15];
        nTeArr = 2308*ones(1,length(LoopArr));
    otherwise
        error(['unrecognized dataset name: ' ds]);
end

if nargin < 4
    basedir = ['..\Result\mat\' ds '\'];
end

Acc = [];

switch modeltype
    case 'Fgplvm'
       for iii = LatentDimArr
            for nnn = LoopArr

                matfname = [basedir 'dem' modeltype ds 'Tr' num2str(nnn) 'Te' num2str(nTeArr(nnn/nStep-nMinus)) 'L' num2str(iii) '.mat'];
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
        end
    case 'SgplvmOri'
        for iii = LatentDimArr
            for nnn = LoopArr

                matfname = [basedir 'dem' modeltype ds 'Tr' num2str(nnn) 'Te' num2str(nTeArr(nnn/nStep-nMinus)) 'L' num2str(iii) '.mat'];
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
        end
    case 'Sllgplvm'
        for iii = LatentDimArr
            for nnn = LoopArr

                matfname = [basedir 'dem' modeltype ds 'Tr' num2str(nnn) 'Te' num2str(nTeArr(nnn/nStep-nMinus)) 'L' num2str(iii) '.mat'];
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
        end
    otherwise
        error(['unrecognized model type: ' modeltype]);
end

end

