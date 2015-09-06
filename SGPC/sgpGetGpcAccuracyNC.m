function AccCell = sgpGetGpcAccuracyNC( DATASOURCE,ModelType )
%SGPGETACCURACY Summary of this function goes here
%   Detailed explanation goes here

if nargin < 2 || strcmp(ModelType,'') 
%     MT = {'Fgplvm','SgplvmOri','Sllgplvm','Sllgplvm1VsRest','Gpgplvm','Gpgplvm1VsRest','Gpc','Svm'};
%     MT = {'Fgplvm','SgplvmOri','Sllgplvm','Sllgplvm1VsRest','Gpgplvm','Gpc','Svm','LDA','Slltpslvm'};
    MT = {'Gpgplvm','Gpgplvm1VsRest'};
else
    MT = {ModelType};
end

nMinus = 0;
switch DATASOURCE
    case 'IonosphereNC'
        LoopArr = [20:20:200];
        nStep = 20;
        LatentDimArr = [1:1:15];
        nTeArr = 351-LoopArr;
        isMultiClass = 0;
    case 'OilNC'
        LoopArr = [30:30:300];
        nStep = 30;
        LatentDimArr = [1:1:15];
        nTeArr = 1000-LoopArr;
        isMultiClass = 1;
    case 'WineNC'
        LoopArr = [30:15:120];
        nStep = 15;
        nMinus = 1;
        LatentDimArr = [1:1:15];
        nTeArr = 178-LoopArr;
        isMultiClass = 1;
    case 'VehicleNC'
        LoopArr = [20:20:200];
        nStep = 20;
        LatentDimArr = [1:1:15];
        nTeArr = 846-LoopArr;
        isMultiClass = 1;
    case 'Usps0To4NC'
        LoopArr = [25:25:200];
        nStep = 25;
%         nMinus = 4;
        LatentDimArr = [1:1:15];
        nTeArr = 2308*ones(1,length(LoopArr));
        isMultiClass = 1;
    case 'GisetteNC'
        LoopArr = [20:20:200];
        nStep = 20;
        LatentDimArr = [1:1:15];
        nTeArr = 1000*ones(1,length(LoopArr));
        isMultiClass = 0;
    otherwise
        error(['unrecognized dataset name: ' DATASOURCE]);
end

    for mi = [1:length(MT)]
        switch(MT{mi})
%             case {'Fgplvm','SgplvmOri','LDA','Slltpslvm'}
%                 Acc = [];
%                 for iii = LatentDimArr
%                     for nnn = LoopArr
%                         matfname = [basedir 'dem' MT{mi} ds 'Tr' num2str(nnn) 'Te' num2str(nTeArr(nnn/nStep-nMinus)) 'L' num2str(iii) '.mat'];
%                         if exist(matfname,'file') ~= 2
%                             continue;
%                         end
%                         load(matfname, 'latentDim','retAcc', 'y', 'yy', 'dataSetName');
%                         Acc = [Acc; [latentDim size(y,1) size(yy,1) retAcc]];
%                         clear( 'latentDim','retAcc', 'y', 'yy');
%                     end
%                 end
%                 eval(['AccCell.' MT{mi} '= Acc;']);
            
%             case {'Sllgplvm','Sllgplvm1VsRest'}
%                 Acc = [];
%                 AccGpc = [];
%                 for iii = LatentDimArr
%                     for nnn = LoopArr
%                         matfname = [basedir 'dem' MT{mi} ds 'Tr' num2str(nnn) 'Te' num2str(nTeArr(nnn/nStep-nMinus)) 'L' num2str(iii) '.mat'];
%                         if exist(matfname,'file') ~= 2
%                             continue;
%                         end
%                         load(matfname, 'latentDim','retAccCell','retAcc', 'y', 'yy', 'dataSetName');
%                         if exist('retAccCell','var')
%                             Acc = [Acc; [latentDim size(y,1) size(yy,1) retAccCell.Knn]];
%                             AccGpc = [AccGpc; [latentDim size(y,1) size(yy,1) retAccCell.Gpc]];
%                         else
%                             Acc = [Acc; [latentDim size(y,1) size(yy,1) retAcc]];
%                             AccGpc = [AccGpc; [latentDim size(y,1) size(yy,1) 0]];
%                         end
%                         clear( 'latentDim','retAccCell','retAcc', 'y', 'yy');
%                     end
%                 end
%                 eval(['AccCell.' MT{mi} '= Acc;']);
%                 eval(['AccCell.' MT{mi} 'Gpc= AccGpc;']);
                
            case {'Gpgplvm','Gpgplvm1VsRest'}
                KernTypeForGpc = [0,1,2,3];
                PriorForGpHyper = [0,1];        % place Gaussian prior over hyperparameters of GP?
                PriorForGpcHyper = [0,1];       % place Gaussian prior over hyperparameters of GPC?
                KernCell = {{'rbfard','white','bias'},{'linard','white','bias'},{'rbf','white','bias'},...
                            {'lin','white','bias'},{'polyard','white','bias'},{'mlpard','white','bias'},...
                            {'poly','white','bias'},{'mlp','white','bias'},{'rbfard','linard','white','bias'},...
                            {'rbfard','rbf','white','bias'},{'rbfard','lin','white','bias'},{'linard','rbf','white','bias'},...
                            {'linard','lin','white','bias'}};

                if isMultiClass == 1
                    for p1 = 1:length(PriorForGpHyper)
                        Opt.priorForGpHyper = PriorForGpHyper(p1);
                        for p2 = 1:length(PriorForGpcHyper)
                            Opt.priorForGpcHyper = PriorForGpcHyper(p2);
                            DS = [DATASOURCE num2str(Opt.priorForGpHyper) num2str(Opt.priorForGpcHyper)];

                            for t = 1:length(KernCell)
                                Opt.kern = KernCell{t};
                                ds = strcat(DS, ['-' upper(Opt.kern{1}(1)) Opt.kern{1}(2:end) ]);
                                for c = 2:length(Opt.kern)
                                    ds = strcat(ds, upper(Opt.kern{c}(1)));
                                end
                                filename = ['retGpgplvm' ds 'GpcAccuracy' ];

                                Acc = [];
                                AccGpc = [];
                                for iii = LatentDimArr
                                    for nnn = LoopArr
                                        matfname = ['dem' MT{mi} ds 'Tr' num2str(nnn) 'Te' num2str(nTeArr(nnn/nStep-nMinus)) 'L' num2str(iii) 'C.mat'];
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

    %                             matfname = [basedir 'ret' MT{mi} ds 'Accuracy.mat'];
    %                             if isempty(Acc) && exist(matfname,'file') == 2
    %                                 load([basedir 'ret' MT{mi} ds 'Accuracy.mat'], 'Acc');
    %                             end                

                                eval(['AccCell.' MT{mi} '= Acc;']);
                                eval(['AccCell.' MT{mi} 'Gpc= AccGpc;']);

                                save(filename, 'AccGpc');
                            end
                        end
                    end
                else
                    for p1 = 1:length(PriorForGpHyper)
                    Opt.priorForGpHyper = PriorForGpHyper(p1);
                    for p2 = 1:length(PriorForGpcHyper)
                        Opt.priorForGpcHyper = PriorForGpcHyper(p2);
                        DataSet = [DATASOURCE num2str(Opt.priorForGpHyper) num2str(Opt.priorForGpcHyper)];

                        for q = 1:length(KernTypeForGpc)
                            Opt.kernForGpc = KernTypeForGpc(q);
                            DS = [DataSet num2str(Opt.kernForGpc)];

                            for t = 1:length(KernCell)
                                Opt.kern = KernCell{t};
                                ds = strcat(DS, ['-' upper(Opt.kern{1}(1)) Opt.kern{1}(2:end) ]);
                                for c = 2:length(Opt.kern)
                                    ds = strcat(ds, upper(Opt.kern{c}(1)));
                                end
                            filename = ['retGpgplvm' ds 'GpcAccuracy' ];

                            Acc = [];
                            AccGpc = [];
                            for iii = LatentDimArr
                                for nnn = LoopArr
                                    matfname = ['dem' MT{mi} ds 'Tr' num2str(nnn) 'Te' num2str(nTeArr(nnn/nStep-nMinus)) 'L' num2str(iii) 'C.mat'];
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

%                             matfname = [basedir 'ret' MT{mi} ds 'Accuracy.mat'];
%                             if isempty(Acc) && exist(matfname,'file') == 2
%                                 load([basedir 'ret' MT{mi} ds 'Accuracy.mat'], 'Acc');
%                             end                

                            eval(['AccCell.' MT{mi} '= Acc;']);
                            eval(['AccCell.' MT{mi} 'Gpc= AccGpc;']);
                            
                            save(filename, 'AccGpc');
                            end
                        end
                    end
                    end
                end
                
%             case {'Gpc','Svm'}
%                 matfname = [basedir 'ret' MT{mi} ds 'Accuracy.mat'];
%                 if exist(matfname,'file') ~= 2
%                     return;
%                 end
%                 load(matfname, 'Acc');                
%                 eval(['AccCell.' MT{mi} '= Acc;']);
                
            otherwise
                error('Wrong ModelType!');
        end
    end
    
% end

end

