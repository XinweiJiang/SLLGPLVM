function AccAll = sgpGetAccuracyDC( ds,ModelType,basedir )
%SGPGETACCURACY Summary of this function goes here
%   Detailed explanation goes here

if nargin < 2 || strcmp(ModelType,'')
    MT = {'Fgplvm','SgplvmOri','Sllgplvm','Gpgplvm','Slltpslvm'};
else
    MT = {ModelType};
end

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

AccAll = [];

for mi = [1:length(MT)]

    Acc = [];
    
    for iii = [1:15]

        matfname = [basedir 'dem' MT{mi} ds 'Tr' num2str(nTr) 'Te' num2str(nTe) 'L' num2str(iii) '.mat'];
        if strcmp(MT{mi},'Gpgplvm')
            matfname = [basedir 'dem' MT{mi} ds 'Tr' num2str(nTr) 'Te' num2str(nTe) 'L' num2str(iii) 'C.mat'];
        end
        if exist(matfname,'file') ~= 2
            continue;
        end
        load(matfname, 'latentDim','retAcc', 'y', 'yy', 'dataSetName');
        Acc = [Acc; [latentDim size(y,1) size(yy,1) retAcc]];
    end
    
%     filename = ['ret' MT{mi} ds 'Accuracy' ];
%     save(filename, 'Acc');
    
    matfname = [basedir 'ret' MT{mi} ds 'Accuracy.mat'];
    if isempty(Acc) && exist(matfname,'file') == 2
        load([basedir 'ret' MT{mi} ds 'Accuracy.mat'], 'Acc');
    end       
    
    eval(['AccAll.' MT{mi} '=Acc;']);
    
end

end

