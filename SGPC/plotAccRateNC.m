function [] = plotAccRateNC(ds, AccCell)
% Data structure of AccCell:
% 
% AccCell.{Fgplvm/SgplvmOri/Sllgplvm/Gpc/Svm}. = [latentdim    training number    testing number    accuracy]
%                                                  1              100                1440             80.2
%                                                  1              120                1420             82.2
%                                                  ...            ...                ...              ...


BASEPATH = 'R:';
MARKERLABELS = char('^','+','o','square','v','x','*','.','diamond','pentagram','hexagram');
COLORLABLES = [[0,0,0]; [0 0 1];[1 0 0]; [0 1 0]; [1 0 1]; [0 1 1]; [0.8 0 0.8]; [0 0.5 0.5];[0.5 0.5 0]; [0.5 0.5 0.5]; [0.2 0 0.2]];
nCounter = 0;

switch ds
    case 'IonosphereNC'
%         DimArr = [3,5,9,11,15];
        DimArrLDA = [];
        DimArrFgplvm = [11];%11
        DimArrSgplvm = [11];%11
        DimArrSllgplvm = [5];
        DimArrSllgplvm1VsRest = [];
        DimArrSllgplvmGpc = [11];
        DimArrSllgplvm1VsRestGpc = [11];
        DimArrSllgplvmGpc = [];
        DimArrGpgplvm = [15];
        DimArrGpgplvmGpc = [];
        DimArrSlltpslvm = [];
    case 'OilNC'
%         DimArr = [2,5,9];
        DimArrLDA = [2];
        DimArrFgplvm = [9];
        DimArrSgplvm = [9];
        DimArrSllgplvm = [9];
        DimArrSllgplvm1VsRest = [];
        DimArrSllgplvmGpc = [];
        DimArrGpgplvm = [9];
        DimArrGpgplvmGpc = [];
        DimArrSlltpslvm = [9,10];
    case 'WineNC'
%         DimArr = [2,5,9];
        DimArrLDA = [2];
        DimArrFgplvm = [10];
        DimArrSgplvm = [10];
        DimArrSllgplvm = [5];
        DimArrSllgplvm1VsRest = [];
        DimArrSllgplvmGpc = [];
        DimArrGpgplvm = [5];
        DimArrGpgplvmGpc = [];
        DimArrSlltpslvm = [9,10];
    case 'VehicleNC'
%         DimArr = [5,9,15];
        DimArrLDA = [2,3,5,9,11,13,15];
        DimArrFgplvm = [5];
        DimArrSgplvm = [5,9,15];
        DimArrSllgplvm = [5];
        DimArrSllgplvm1VsRest = [];
        DimArrSllgplvmGpc = [];
        DimArrGpgplvm = [15];
        DimArrGpgplvmGpc = [];
        DimArrSlltpslvm = [9,10];
    case 'Usps0To4NC'
%         DimArr = [2,5,9,15];
        DimArrLDA = [4];
        DimArrFgplvm = [9];
        DimArrSgplvm = [5];
        DimArrSllgplvm = [];
        DimArrSllgplvm1VsRest = [5];
        DimArrSllgplvmGpc = [];
        DimArrGpgplvm = [10];
        DimArrGpgplvm1VsRest = [10];
        DimArrGpgplvmGpc = [];
        DimArrSlltpslvm = [];
    case 'GisetteNC'
%         DimArr = [3,5,9,11,15];
        DimArrLDA = [1];
        DimArrFgplvm = [9];
        DimArrSgplvm = [15];
        DimArrSllgplvm = [5];
        DimArrSllgplvm1VsRest = [];
        DimArrSllgplvmGpc = [];
        DimArrGpgplvm = [5];
        DimArrGpgplvmGpc = [];
        DimArrSlltpslvm = [9,10];
    otherwise
        error(['unrecognized dataset name: ' ds]);
end

figure1 = figure();
axes1 = axes('Parent',figure1);
box(axes1,'on');
hold(axes1,'all');
xlabel('Number of Training Samples');ylabel('Classification Accuracy Rate(%)');

% %-----------------------   Plot results from GPC   -------------------
% Acc = [];
% if nargin < 2
%     load(['retGpc' ds 'Accuracy.mat'], 'Acc');
% end
% 
% if isfield(AccCell, 'Gpc') && ~isempty(AccCell.Gpc)
%     Acc = AccCell.Gpc;
%     nCounter = nCounter + 1;
%     Acci = Acc;
%     plot(Acci(:,1),Acci(:,3),'DisplayName','Gpc','MarkerSize',8,'Marker',MARKERLABELS(nCounter),'LineWidth',1,'LineStyle','-.','Color',COLORLABLES(nCounter,:),'Parent',axes1);
% end
% 
% 
% %-----------------------   Plot results from SVM   -------------------
% Acc = [];
% if nargin < 2
%     load(['retSvm' ds 'Accuracy.mat'], 'Acc');
% end
% 
% if isfield(AccCell, 'Svm') && ~isempty(AccCell.Svm)
%     Acc = AccCell.Svm;
%     nCounter = nCounter + 1;
%     Acci = Acc;
%     plot(Acci(:,1),Acci(:,3),'DisplayName','Svm','MarkerSize',8,'Marker',MARKERLABELS(nCounter),'LineWidth',1,'LineStyle','--','Color',COLORLABLES(nCounter,:),'Parent',axes1);
% end

%-----------------------   Plot results from FGPLVM   ---------------------
Acc = [];
if nargin < 2
    load(['retFgplvm' ds 'Accuracy.mat'], 'Acc');
end

if isfield(AccCell, 'Fgplvm') && ~isempty(AccCell.Fgplvm)
    Acc = AccCell.Fgplvm;
    for i = DimArrFgplvm
        nCounter = nCounter + 1;
        Acci = Acc(find(Acc(:,1)==i),:);
        plot(Acci(:,2),Acci(:,4),'DisplayName',['Fgplvm(d=' num2str(i) ')'],'MarkerSize',8,'Marker',MARKERLABELS(nCounter),'LineWidth',1,'LineStyle',':','Color',COLORLABLES(nCounter,:),'Parent',axes1);
    end
end

    
%-----------------------   Plot results from SGPLVM   ---------------------
Acc = [];
if nargin < 2
    load(['retSgplvmOri' ds 'Accuracy.mat'], 'Acc');
end

if isfield(AccCell, 'SgplvmOri') && ~isempty(AccCell.SgplvmOri)
    Acc = AccCell.SgplvmOri;
    for i = DimArrSgplvm
        nCounter = nCounter + 1;
        Acci = Acc(find(Acc(:,1)==i),:);
        plot(Acci(:,2),Acci(:,4),'DisplayName',['Sgplvm(d=' num2str(i) ')'],'MarkerSize',8,'Marker',MARKERLABELS(nCounter),'LineWidth',1,'LineStyle','--','Color',COLORLABLES(nCounter,:),'Parent',axes1);
    end
end


%-----------------------   Plot results from GPGPLVM   -------------------
Acc = [];
if nargin < 2
    load(['retGpgplvm' ds 'Accuracy.mat'], 'Acc');
end

if isfield(AccCell, 'Gpgplvm') && ~isempty(AccCell.Gpgplvm)
    Acc = AccCell.Gpgplvm;
    for i = DimArrGpgplvm
        nCounter = nCounter + 1;
        Acci = Acc(find(Acc(:,1)==i),:);
        plot(Acci(:,2),Acci(:,4),'DisplayName',['DoubleGPLVM(d=' num2str(i) ')'],'MarkerSize',8,'Marker',MARKERLABELS(nCounter),'LineWidth',1,'Color',COLORLABLES(nCounter,:),'Parent',axes1);
    end
end

%-----------------------   Plot results from GPGPLVM (1 vs Rest)   -------------------
Acc = [];
if nargin < 2
    load(['retGpgplvm1VsRest' ds 'Accuracy.mat'], 'Acc');
end

if isfield(AccCell, 'Gpgplvm1VsRest') && ~isempty(AccCell.Gpgplvm1VsRest)
    Acc = AccCell.Gpgplvm1VsRest;
    for i = DimArrGpgplvm1VsRest
        nCounter = nCounter + 1;
        Acci = Acc(find(Acc(:,1)==i),:);
        plot(Acci(:,2),Acci(:,4),'DisplayName',['DoubleGPLVM(d=' num2str(i) ')'],'MarkerSize',8,'Marker',MARKERLABELS(nCounter),'LineWidth',1,'Color',COLORLABLES(nCounter,:),'Parent',axes1);
    end
end

%-----------------------   Plot results from GPGPLVM   -------------------
Acc = [];
if nargin < 2
    load(['retGpgplvmGpc' ds 'Accuracy.mat'], 'Acc');
end

if isfield(AccCell, 'GpgplvmGpc') && ~isempty(AccCell.GpgplvmGpc)
    Acc = AccCell.GpgplvmGpc;
    for i = DimArrGpgplvmGpc
        nCounter = nCounter + 1;
        Acci = Acc(find(Acc(:,1)==i),:);
        plot(Acci(:,2),Acci(:,4),'DisplayName',['Sgpgplvm-GPC(d=' num2str(i) ')'],'MarkerSize',8,'Marker',MARKERLABELS(nCounter),'LineWidth',1,'Color',COLORLABLES(nCounter,:),'Parent',axes1);
    end
end


%-----------------------   Plot results from SLLGPLVM   -------------------
Acc = [];
if nargin < 2
    load(['retSllgplvm' ds 'Accuracy.mat'], 'Acc');
end

if isfield(AccCell, 'Sllgplvm') && ~isempty(AccCell.Sllgplvm)
    Acc = AccCell.Sllgplvm;
    for i = DimArrSllgplvm
        nCounter = nCounter + 1;
        Acci = Acc(find(Acc(:,1)==i),:);
        plot(Acci(:,2),Acci(:,4),'DisplayName',['Sllgplvm(d=' num2str(i) ')'],'MarkerSize',8,'Marker',MARKERLABELS(nCounter),'LineWidth',1,'Color',COLORLABLES(nCounter,:),'Parent',axes1);
    end
end


%-----------------------   Plot results from SLLGPLVM (1 Vs Rest)   -------------------
Acc = [];
if nargin < 2
    load(['retSllgplvm1VsRest' ds 'Accuracy.mat'], 'Acc');
end

if isfield(AccCell, 'Sllgplvm1VsRest') && ~isempty(AccCell.Sllgplvm1VsRest)
    Acc = AccCell.Sllgplvm1VsRest;
    for i = DimArrSllgplvm1VsRest
        nCounter = nCounter + 1;
        Acci = Acc(find(Acc(:,1)==i),:);
        plot(Acci(:,2),Acci(:,4),'DisplayName',['Sllgplvm(d=' num2str(i) ')'],'MarkerSize',8,'Marker',MARKERLABELS(nCounter),'LineWidth',1,'Color',COLORLABLES(nCounter,:),'Parent',axes1);
    end
end


%-----------------------   Plot results from SLLGPLVM   -------------------
Acc = [];
if nargin < 2
    load(['retSllgplvmGpc' ds 'Accuracy.mat'], 'Acc');
end

if isfield(AccCell, 'SllgplvmGpc') && ~isempty(AccCell.SllgplvmGpc)
    Acc = AccCell.SllgplvmGpc;
    for i = DimArrSllgplvmGpc
        nCounter = nCounter + 1;
        Acci = Acc(find(Acc(:,1)==i),:);
        plot(Acci(:,2),Acci(:,4),'DisplayName',['Sllgplvm-Gpc(d=' num2str(i) ')'],'MarkerSize',8,'Marker',MARKERLABELS(nCounter),'LineWidth',1,'Color',COLORLABLES(nCounter,:),'Parent',axes1);
    end
end
% 
% 
% %-----------------------   Plot results from SLLGPLVM (1 Vs Rest)   -------------------
% Acc = [];
% if nargin < 2
%     load(['retSllgplvm1VsRestGpc' ds 'Accuracy.mat'], 'Acc');
% end
% 
% if isfield(AccCell, 'Sllgplvm1VsRestGpc') && ~isempty(AccCell.Sllgplvm1VsRestGpc)
%     Acc = AccCell.Sllgplvm1VsRestGpc;
%     for i = DimArrSllgplvm1VsRestGpc
%         nCounter = nCounter + 1;
%         Acci = Acc(find(Acc(:,1)==i),:);
%         plot(Acci(:,2),Acci(:,4),'DisplayName',['Sllgplvm-Gpc(d=' num2str(i) ')'],'MarkerSize',8,'Marker',MARKERLABELS(nCounter),'LineWidth',1,'Color',COLORLABLES(nCounter,:),'Parent',axes1);
%     end
% end


% %-----------------------   Plot results from SLLTPSLVM   -------------------
% Acc = [];
% if nargin < 2
%     load(['retSlltpslvm' ds 'Accuracy.mat'], 'Acc');
% else
%     Acc = AccCell.Slltpslvm;
% end
% 
% for i = DimArrSlltpslvm
%     nCounter = nCounter + 1;
%     Acci = Acc(find(Acc(:,1)==i),:);
%     plot(Acci(:,2),Acci(:,4),'DisplayName',['Slltpslvm(d=' num2str(i) ')'],'MarkerSize',8,'Marker',MARKERLABELS(nCounter),'LineWidth',1,'Color',COLORLABLES(nCounter,:),'Parent',axes1);
% end
% 
% 
%-----------------------   Plot results from LDA   ---------------------
Acc = [];
if nargin < 2
    load(['retLDA' ds 'Accuracy.mat'], 'Acc');
end

if isfield(AccCell, 'LDA') && ~isempty(AccCell.LDA)
    Acc = AccCell.LDA;
    for i = DimArrLDA
        nCounter = nCounter + 1;
        Acci = Acc(find(Acc(:,1)==i),:);
        plot(Acci(:,2),Acci(:,4),'DisplayName',['LDA(d=' num2str(i) ')'],'MarkerSize',8,'Marker',MARKERLABELS(nCounter),'LineWidth',1,'LineStyle',':','Color',COLORLABLES(nCounter,:),'Parent',axes1);
    end
end


%-----------------------   Plot results from GPC   -------------------
if nargin < 2
    load(['retGpc' ds 'Accuracy.mat'], 'Acc');
end

if isfield(AccCell, 'Gpc') && ~isempty(AccCell.Gpc)
    Acc = AccCell.Gpc;
    nCounter = nCounter + 1;
    Acci = Acc;
    plot(Acci(:,1),Acci(:,3),'DisplayName','Gpc','MarkerSize',8,'Marker',MARKERLABELS(nCounter),'LineWidth',1,'LineStyle','-.','Color',COLORLABLES(nCounter,:),'Parent',axes1);
end


%-----------------------   Plot results from SVM   -------------------
if nargin < 2
    load(['retSvm' ds 'Accuracy.mat'], 'Acc');
end

if isfield(AccCell, 'Svm') && ~isempty(AccCell.Svm)
    Acc = AccCell.Svm;
    nCounter = nCounter + 1;
    Acci = Acc;
    plot(Acci(:,1),Acci(:,3),'DisplayName','Svm','MarkerSize',8,'Marker',MARKERLABELS(nCounter),'LineWidth',1,'LineStyle','--','Color',COLORLABLES(nCounter,:),'Parent',axes1);
end

Acc = AccCell.Svm;
legend1 = legend(axes1,'show');
set(legend1,'Location','SouthEast','FontSize',8);
xlim([Acc(1,1) Acc(size(Acc,1),1)]) ;

print('-depsc2','-tiff', '-loose', '-r600', [BASEPATH '/cer_' ds])