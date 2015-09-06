function [] = plotErrRateNC(ds, AccCell)
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
    case 'HouseNC'
%         DimArr = [3,5,9,11,15];
%         DimArrFgplvm = [11];
        DimArrSgplvm = [2];
        DimArrSllgplvm = [1];
        DimArrGpgplvm = [2];
    otherwise
        error(['unrecognized dataset name: ' ds]);
end

figure1 = figure();
axes1 = axes('Parent',figure1);
box(axes1,'on');
hold(axes1,'all');
xlabel('Number of Training Samples');ylabel('RMSE');

    
%-----------------------   Plot results from SGPLVM   ---------------------
Acc = [];
if nargin < 2
    load(['retSgplvmOri' ds 'Error.mat'], 'Acc');
else
    Acc = AccCell.SgplvmOri;
end

for i = DimArrSgplvm
    nCounter = nCounter + 1;
    Acci = Acc(find(Acc(:,1)==i),:);
    plot(Acci(:,2),Acci(:,4),'DisplayName',['Sgplvm(d=' num2str(i) ')'],'MarkerSize',8,'Marker',MARKERLABELS(nCounter),'LineWidth',1,'LineStyle','--','Color',COLORLABLES(nCounter,:),'Parent',axes1);
end



%-----------------------   Plot results from SLLGPLVM   -------------------
Acc = [];
if nargin < 2
    load(['retSllgplvm' ds 'Error.mat'], 'Acc');
else
    Acc = AccCell.Sllgplvm;
end

for i = DimArrSllgplvm
    nCounter = nCounter + 1;
    Acci = Acc(find(Acc(:,1)==i),:);
    plot(Acci(:,2),Acci(:,4),'DisplayName',['Sllgplvm(d=' num2str(i) ')'],'MarkerSize',8,'Marker',MARKERLABELS(nCounter),'LineWidth',1,'Color',COLORLABLES(nCounter,:),'Parent',axes1);
end


%-----------------------   Plot results from GPGPLVM   -------------------
Acc = [];
if nargin < 2
    load(['retGpgplvm' ds 'Error.mat'], 'Acc');
else
    Acc = AccCell.Sgpgplvm;
end

for i = DimArrGpgplvm
    nCounter = nCounter + 1;
    Acci = Acc(find(Acc(:,1)==i),:);
    plot(Acci(:,2),Acci(:,4),'DisplayName',['DoubleGPLVM(d=' num2str(i) ')'],'MarkerSize',8,'Marker',MARKERLABELS(nCounter),'LineWidth',1,'Color',COLORLABLES(nCounter,:),'Parent',axes1);
end



%-----------------------   Plot results from GPR   -------------------
Acc = [];
if nargin < 2
    load(['retGpr' ds 'Error.mat'], 'Acc');
else
    Acc = AccCell.Gpr;
end

nCounter = nCounter + 1;
Acci = Acc;
plot(Acci(:,1),Acci(:,3),'DisplayName','Gpr','MarkerSize',8,'Marker',MARKERLABELS(nCounter),'LineWidth',1,'LineStyle','-.','Color',COLORLABLES(nCounter,:),'Parent',axes1);




%-----------------------   Plot results from SVR   -------------------
Acc = [];
if nargin < 2
    load(['retSvr' ds 'Error.mat'], 'Acc');
else
    Acc = AccCell.Svr;
end

nCounter = nCounter + 1;
Acci = Acc;
plot(Acci(:,1),Acci(:,3),'DisplayName','Svr','MarkerSize',8,'Marker',MARKERLABELS(nCounter),'LineWidth',1,'LineStyle','--','Color',COLORLABLES(nCounter,:),'Parent',axes1);



legend1 = legend(axes1,'show');
set(legend1,'Location','NorthEast','FontSize',8);
xlim([Acc(1,1) Acc(size(Acc,1),1)]) ;

print('-depsc2','-tiff', '-loose', '-r600', [BASEPATH '/cer_' ds])