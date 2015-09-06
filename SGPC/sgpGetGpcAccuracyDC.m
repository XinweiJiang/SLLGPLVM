function AccAll = sgpGetGpcAccuracyDC( DATASOURCE,ModelType )
%SGPGETACCURACY Summary of this function goes here
%   Detailed explanation goes here

if nargin < 2 || strcmp(ModelType,'')
%     MT = {'Fgplvm','SgplvmOri','Sllgplvm','Gpgplvm','Slltpslvm'};
    MT = {'Gpgplvm','Gpgplvm1VsRest'};
else
    MT = {ModelType};
end

switch DATASOURCE
    case 'Usps5And3DC'
        nTr = 100;
        nTe = 1440;
    case 'WineDC'
        nTr = 90;
        nTe = 88;
    otherwise
        error(['unrecognized dataset name: ' DATASOURCE]);
end

AccAll = [];

PriorForGpHyper = [1];        % place Gaussian prior over hyperparameters of GP?
            PriorForGpcHyper = [0,1];       % place Gaussian prior over hyperparameters of GPC?
            KernCell = {{'rbfard','white','bias'},{'linard','white','bias'},{'rbf','white','bias'},...
                        {'lin','white','bias'},{'polyard','white','bias'},{'mlpard','white','bias'},...
                        {'poly','white','bias'},{'mlp','white','bias'},{'rbfard','linard','white','bias'},...
                        {'rbfard','rbf','white','bias'},{'rbfard','lin','white','bias'},{'linard','rbf','white','bias'},...
                        {'linard','lin','white','bias'}};

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
                        
                        for mi = [1:length(MT)]

                            Acc = [];
                            AccGpc = [];

                            for iii = [1:15]

                        %         matfname = [basedir 'dem' MT{mi} ds 'Tr' num2str(nTr) 'Te' num2str(nTe) 'L' num2str(iii) '.mat'];
                        %         if strcmp(MT{mi},'Gpgplvm')
                                    matfname = ['dem' MT{mi} ds 'Tr' num2str(nTr) 'Te' num2str(nTe) 'L' num2str(iii) 'C.mat'];
                        %         end
                                if exist(matfname,'file') ~= 2
                                    continue;
                                end
                                load(matfname, 'latentDim','retAcc', 'y', 'yy', 'dataSetName');
                                if exist('retAccCell','var')
                                    Acc = [Acc; [latentDim size(y,1) size(yy,1) retAccCell.Knn]];
                                    AccGpc = [AccGpc; [latentDim size(y,1) size(yy,1) retAccCell.Gpc]];
                                else
                                    Acc = [Acc; [latentDim size(y,1) size(yy,1) retAcc]];
                                    AccGpc = [AccGpc; [latentDim size(y,1) size(yy,1) 0]];
                                end
                                clear('latentDim','retAcc', 'y', 'yy', 'dataSetName');
                            end

                            filename = ['ret' MT{mi} ds 'GpcAccuracy' ];
                            save(filename, 'AccGpc');
                        end

                        end
                    end
                end
            end

end

