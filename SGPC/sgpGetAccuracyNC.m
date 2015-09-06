function AccCell = sgpGetAccuracyNC( ds,ModelType,basedir )
%SGPGETACCURACY Summary of this function goes here
%   Detailed explanation goes here

if nargin < 3
    basedir = ['..\Result\mat\' ds '\'];
end

if nargin < 2 || strcmp(ModelType,'') 
    MT = {'Fgplvm','SgplvmOri','Sllgplvm','Sllgplvm1VsRest','Gpgplvm','Gpgplvm1VsRest','Gpc','Svm','LDA'};
%     MT = {'Fgplvm','SgplvmOri','Sllgplvm','Sllgplvm1VsRest','Gpgplvm','Gpc','Svm','LDA','Slltpslvm'};
%     MT = {'Fgplvm','SgplvmOri','Sllgplvm'};
else
    MT = {ModelType};
end

nMinus = 0;
switch ds
    case 'IonosphereNC'
        LoopArr = [20:20:200];
        nStep = 20;
        LatentDimArr = [1,2,3,4,5,7,9,10,11,13,15,16,18,20];
        nTeArr = 351-LoopArr;
    case 'OilNC'
        LoopArr = [30:30:300];
        nStep = 30;
        LatentDimArr = [1,2,5,9];
        nTeArr = 1000-LoopArr;
    case 'WineNC'
        LoopArr = [30:15:120];
        nStep = 15;
        nMinus = 1;
        LatentDimArr = [1,2,4,5,7,9,10,12];
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
        LatentDimArr = [1,2,3,4,5,9,10,15];
        nTeArr = 2308*ones(1,length(LoopArr));
    case 'GisetteNC'
        LoopArr = [20:20:200];
        nStep = 20;
        LatentDimArr = [2,5,7,8,9,10,12,13,15];
        nTeArr = 1000*ones(1,length(LoopArr));
    otherwise
        error(['unrecognized dataset name: ' ds]);
end

% if nargin < 2 || strcmp(ModelType,'') 
%     for mi = [1:4]
% 
%         Acc = [];
% 
%         for iii = LatentDimArr
%             for nnn = LoopArr
% 
%                 matfname = [basedir 'dem' MT{mi} ds 'Tr' num2str(nnn) 'Te' num2str(nTeArr(nnn/nStep-nMinus)) 'L' num2str(iii) '.mat'];
%                 if exist(matfname,'file') ~= 2
%                     continue;
%                 end
%         %         fid = fopen(matfname);
%         %         if fid < 3
%         %             continue;
%         %         end
%         %         fclose(fid);
%                 load(matfname, 'latentDim','retAcc', 'y', 'yy', 'dataSetName');
%                 Acc = [Acc; [latentDim size(y,1) size(yy,1) retAcc]];
%                 clear( 'latentDim','retAcc', 'y', 'yy');
%             end
% 
%         end
% 
%         filename = ['ret' MT{mi} ds 'Accuracy' ];
%         save(filename, 'Acc');
%         eval(['AccCell.' MT{mi} '= Acc;']);
% 
%     end
% 
%     for mi = [5:length(MT)]
%         matfname = ['..\Result\mat\' ds '\ret' MT{mi} ds 'Accuracy.mat'];
%         if exist(matfname,'file') ~= 2
%             continue;
%         end
%         load(matfname, 'Acc');
%         eval(['AccCell.' MT{mi} '= Acc;']);
%     end
% else

    for mi = [1:length(MT)]
        switch(MT{mi})
            case {'Fgplvm','SgplvmOri','LDA','Slltpslvm'}
                Acc = [];
                for iii = LatentDimArr
                    for nnn = LoopArr
                        matfname = [basedir 'dem' MT{mi} ds 'Tr' num2str(nnn) 'Te' num2str(nTeArr(nnn/nStep-nMinus)) 'L' num2str(iii) '.mat'];
                        if exist(matfname,'file') ~= 2
                            continue;
                        end
                        load(matfname, 'latentDim','retAcc', 'y', 'yy', 'dataSetName');
                        Acc = [Acc; [latentDim size(y,1) size(yy,1) retAcc]];
                        clear( 'latentDim','retAcc', 'y', 'yy');
                    end
                end
                eval(['AccCell.' MT{mi} '= Acc;']);
            
            case {'Sllgplvm','Sllgplvm1VsRest'}
                Acc = [];
                AccGpc = [];
                for iii = LatentDimArr
                    for nnn = LoopArr
                        matfname = [basedir 'dem' MT{mi} ds 'Tr' num2str(nnn) 'Te' num2str(nTeArr(nnn/nStep-nMinus)) 'L' num2str(iii) '.mat'];
                        if exist(matfname,'file') ~= 2
                            continue;
                        end
                        load(matfname, 'latentDim','retAccCell','retAcc', 'y', 'yy', 'dataSetName');
                        if exist('retAccCell','var')
                            Acc = [Acc; [latentDim size(y,1) size(yy,1) retAccCell.Knn]];
                            AccGpc = [AccGpc; [latentDim size(y,1) size(yy,1) retAccCell.Gpc]];
                        else
                            Acc = [Acc; [latentDim size(y,1) size(yy,1) retAcc]];
                            AccGpc = [AccGpc; [latentDim size(y,1) size(yy,1) 0]];
                        end
                        clear( 'latentDim','retAccCell','retAcc', 'y', 'yy');
                    end
                end
                eval(['AccCell.' MT{mi} '= Acc;']);
                eval(['AccCell.' MT{mi} 'Gpc= AccGpc;']);
                
            case {'Gpgplvm','Gpgplvm1VsRest'}
                Acc = [];
                AccGpc = [];
                for iii = LatentDimArr
                    for nnn = LoopArr
%                         matfname = [basedir 'dem' MT{mi} ds '103-MlpWBTr' num2str(nnn) 'Te' num2str(nTeArr(nnn/nStep-nMinus)) 'L' num2str(iii) 'C.mat'];
                        matfname = [basedir 'dem' MT{mi} ds 'MlpWBTr' num2str(nnn) 'Te' num2str(nTeArr(nnn/nStep-nMinus)) 'L' num2str(iii) 'C.mat'];
                        if exist(matfname,'file') ~= 2
                            continue;
                        end
                        load(matfname, 'latentDim','retAccCell','retAcc', 'y', 'yy', 'dataSetName');
                        if exist('retAccCell','var')
                            Acc = [Acc; [latentDim size(y,1) size(yy,1) retAccCell.Knn]];
                            AccGpc = [AccGpc; [latentDim size(y,1) size(yy,1) retAccCell.Gpc]];
                        else
                            Acc = [Acc; [latentDim size(y,1) size(yy,1) retAcc]];
                            AccGpc = [AccGpc; [latentDim size(y,1) size(yy,1) 0]];
                        end
                        clear( 'latentDim','retAccCell','retAcc', 'y', 'yy');
                    end
                end
                
                matfname = [basedir 'ret' MT{mi} ds 'Accuracy.mat'];
                if isempty(Acc) && exist(matfname,'file') == 2
                    load([basedir 'ret' MT{mi} ds 'Accuracy.mat'], 'Acc');
                end                
                
                eval(['AccCell.' MT{mi} '= Acc;']);
                eval(['AccCell.' MT{mi} 'Gpc= AccGpc;']);
                
            case {'Gpc','Svm'}
                matfname = [basedir 'ret' MT{mi} ds 'Accuracy.mat'];
                if exist(matfname,'file') ~= 2
                    return;
                end
                load(matfname, 'Acc');                
                eval(['AccCell.' MT{mi} '= Acc;']);
                
            otherwise
                error('Wrong ModelType!');
        end
    end
    
% end

end

