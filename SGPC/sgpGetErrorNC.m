function AccAll = sgpGetErrorNC( ds,ModelType,basedir )
%SGPGETACCURACY Summary of this function goes here
%   Detailed explanation goes here

if nargin < 3
    basedir = ['..\Result\mat\' ds '\'];
end

if nargin < 2 || strcmp(ModelType,'') 
    MT = {'SgplvmOri','Sllgplvm','Sgpgplvm','Gpr','Svr'};
else
    MT = {ModelType};
end

nMinus = 0;
switch ds
    case 'HouseNC'
        LoopArr = [50:50:400];
        nStep = 50;
        LatentDimArr = [1,2,3,5,9];
        nTeArr = 506-LoopArr;
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
%         eval(['AccAll.' MT{mi} '= Acc;']);
% 
%     end
% 
%     for mi = [5:length(MT)]
%         matfname = ['..\Result\mat\' ds '\ret' MT{mi} ds 'Accuracy.mat'];
%         if exist(matfname,'file') ~= 2
%             continue;
%         end
%         load(matfname, 'Acc');
%         eval(['AccAll.' MT{mi} '= Acc;']);
%     end
% else

    for mi = [1:length(MT)]
        switch(MT{mi})
            case {'Gpr','Svr','SgplvmOri','Sllgplvm','Sgpgplvm'}
                matfname = [basedir 'ret' MT{mi} ds 'Error.mat'];
                if exist(matfname,'file') ~= 2
                    return;
                end
                load(matfname, 'Acc');                
                eval(['AccAll.' MT{mi} '= Acc;']);
                
            otherwise
                error('Wrong ModelType!');
        end
    end
    
% end

end

