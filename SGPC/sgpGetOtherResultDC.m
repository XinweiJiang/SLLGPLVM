function Acc = sgpGetOtherResultDC( ds, modeltype, kind, basedir )
%SGPGETOTHERRESULT Summary of this function goes here
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
    case {'Fgplvm','SgplvmOri'}
        for iii = [1:15]
            matfname = [basedir 'dem' modeltype ds 'Tr' num2str(nTr) 'Te' num2str(nTe) 'L' num2str(iii) '.mat'];
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
        
    case {'Gpgplvm'}
        for iii = [1:15]
            matfname = [basedir 'dem' modeltype ds 'Tr' num2str(nTr) 'Te' num2str(nTe) 'L' num2str(iii) 'C.mat'];
            if exist(matfname,'file') ~= 2
                continue;
            end
%             load(matfname, 'retAccCell','retAccKnn','retAccGpc','pp','varZZ','latentDim', 'y', 'yy','model','z','zz');
            load(matfname, 'retAccCell','retAccKnn','retAccGpc','latentDim', 'y', 'yy','model','z','zz');
                    
            if exist('retAccCell', 'var') && isfield(retAccCell,kind)
%                 if retAccCell.Gpc == 0
%                     pp = binaryLaplaceGPForGpc(model.kern.hyper, 'covSEiso', 'cumGauss', z, y, zz);
%                     retAccGpc = 100*sum((pp>0.5) == (yy>0))/size(yy,1);
%                     varZZ = mean((yy==1).*log2(pp)+(yy==-1).*log2(1-pp))+1;
%                     retAccCell.Gpc = retAccGpc;
%                 end
                
                eval([ 'retAcc = retAccCell.' kind ';']);
                save(matfname, 'retAcc','retAccCell','retAccKnn','retAccGpc','-append');
                Acc = [Acc; [latentDim size(y,1) size(yy,1) retAcc]];
            end
            clear( 'retAcc', 'retAccCell','latentDim', 'y', 'yy','model','z','zz','retAccGpc','retAccKnn');
        end
        
    otherwise
        error(['unrecognized model type: ' modeltype]);
end


end

