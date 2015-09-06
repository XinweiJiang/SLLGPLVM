function Acc = sgpGetOtherResultNC( ds, modeltype, kind, basedir )
%SGPGETOTHERRESULT Summary of this function goes here
%   Detailed explanation goes here

if nargin < 4
    basedir = ['..\Result\mat\' ds '\'];
end

nMinus = 0;
switch ds
    case 'IonosphereNC'
        LoopArr = [20:20:200];
        nStep = 20;
        LatentDimArr = [1,2,3,4,5,7,9,10,13,15];
        nTeArr = 351-LoopArr;
    case 'OilNC'
        LoopArr = [30:30:300];
        nStep = 30;
        LatentDimArr = [2,5,9];
        nTeArr = 1000-LoopArr;
    case 'WineNC'
        LoopArr = [30:15:120];
        nStep = 15;
        nMinus = 1;
        LatentDimArr = [5,10,12];
        nTeArr = 178-LoopArr;
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
    case 'GisetteNC'
        LoopArr = [20:20:200];
        nStep = 20;
        LatentDimArr = [1,2,3,4,5,7,9,10,13,15];
        nTeArr = 1000*ones(1,length(LoopArr));
    otherwise
        error(['unrecognized dataset name: ' ds]);
end

Acc = [];

switch modeltype
    case {'Fgplvm','SgplvmOri'}
        for iii = LatentDimArr
            for nnn = LoopArr

                matfname = [basedir 'dem' modeltype ds 'Tr' num2str(nnn) 'Te' num2str(nTeArr(nnn/nStep-nMinus)) 'L' num2str(iii) '.mat'];
                if exist(matfname,'file') ~= 2
                    continue;
                end
                load(matfname, 'retAccCell','latentDim', 'y', 'yy');

                if exist('retAccCell', 'var') && isfield(retAccCell,kind)
                    eval([ 'retAcc = retAccCell.' kind ';']);
                    save(matfname, 'retAcc','-append');
                    Acc = [Acc; [latentDim size(y,1) size(yy,1) retAcc]];
                end
                clear( 'retAcc', 'retAccCell','latentDim', 'y', 'yy');
            end
        end
        
    case 'Gpgplvm'
        for iii = LatentDimArr
            for nnn = LoopArr

                matfname = [basedir 'dem' modeltype ds 'Tr' num2str(nnn) 'Te' num2str(nTeArr(nnn/nStep-nMinus)) 'L' num2str(iii) 'C.mat'];
                if exist(matfname,'file') ~= 2
                    continue;
                end
                load(matfname, 'retAcc','retAccCell','retAccKnn','retAccGpc','latentDim', 'y', 'yy','model','z','zz');
%                 load(matfname, 'retAcc','retAccCell','retAccKnn','retAccGpc','pp','varZZ','latentDim', 'y', 'yy','model','z','zz');
                
                if ~exist('retAccCell', 'var')
                    retAccKnn = retAcc;
                    retAccCell.Knn = retAccKnn;
                    retAccCell.Gpc = 0;
                end            
                
%                 if retAccCell.Gpc == 0
%                     pp = binaryLaplaceGPForGpc(model.kern.hyper, 'covSEiso', 'cumGauss', z, y, zz);
%                     retAccGpc = 100*sum((pp>0.5) == (yy>0))/size(yy,1);
%                     varZZ = mean((yy==1).*log2(pp)+(yy==-1).*log2(1-pp))+1;
%                     retAccCell.Gpc = retAccGpc;
%                 end
                
                eval([ 'retAcc = retAccCell.' kind ';']);
                save(matfname, 'retAcc','retAccCell','retAccGpc','retAccKnn','-append');
                Acc = [Acc; [latentDim size(y,1) size(yy,1) retAcc]];

                clear( 'retAcc', 'retAccCell','latentDim', 'y', 'yy','model','z','zz','retAccGpc','retAccKnn');
            end
        end

    otherwise
        error(['unrecognized model type: ' modeltype]);
end


end

