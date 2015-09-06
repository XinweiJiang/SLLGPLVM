function [] = plotAccRateDC(ds, AccCell)
% Data structure of AccCell:
% 
% AccCell.{Fgplvm/SgplvmOri/Sllgplvm} = [latentdim    training number    testing number    accuracy]
%                                         1              100                1440             80.2
%                                         ...            ...                ...              ...

BASEPATH = 'R:';
figure1 = figure();
axes1 = axes('Parent',figure1,'XTick',[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15]);
box(axes1,'on');
hold(axes1,'all');
xlabel('Dimension of Latent Space');ylabel('Classification Accuracy Rate(%)');

if nargin < 2
    load(['retFgplvm' ds 'Accuracy.mat'], 'Acc');
else
    Acc = AccCell.Fgplvm;
end
plot(Acc(:,1),Acc(:,4),'DisplayName','Fgplvm','MarkerSize',8,'Marker','^','LineWidth',1,'LineStyle',':','Color',[0,0,0],'Parent',axes1);
% hold on;

if nargin < 2
    load(['retSgplvmOri' ds 'Accuracy.mat'], 'Acc');
else
    Acc = AccCell.SgplvmOri;
end
plot(Acc(:,1),Acc(:,4),'DisplayName','Sgplvm','MarkerSize',8,'Marker','square','LineWidth',1,'LineStyle','--','Color',[0,0,1],'Parent',axes1);
% hold on;

if nargin < 2
    load(['retSllgplvm' ds 'Accuracy.mat'], 'Acc');
else
    Acc = AccCell.Sllgplvm;
end
plot(Acc(:,1),Acc(:,4),'DisplayName','Sllgplvm','MarkerSize',8,'Marker','o','LineWidth',1,'Color',[0,1,0],'Parent',axes1);


% if nargin < 2
%     load(['retSlltpslvm' ds 'Accuracy.mat'], 'Acc');
% else
%     Acc = AccCell.Slltpslvm;
% end
% plot(Acc(:,1),Acc(:,4),'DisplayName','Slltpslvm','MarkerSize',8,'Marker','+','LineWidth',1,'Color',[1,0,0],'Parent',axes1);


if nargin < 2
    load(['retGpgplvm' ds 'Accuracy.mat'], 'Acc');
else
    Acc = AccCell.Gpgplvm;
end
plot(Acc(:,1),Acc(:,4),'DisplayName','DoubleGPLVM','MarkerSize',8,'Marker','v','LineWidth',1,'LineStyle','--','Color',[1,0,0],'Parent',axes1);


legend1 = legend(axes1,'show');
set(legend1,'Location','SouthEast','FontSize',8);
xlim([1 Acc(size(Acc,1),1)]) ;
set(gca,'XTick',[1 :1 :Acc(size(Acc,1),1)]) 

print('-depsc2','-tiff', '-loose', '-r600', [BASEPATH '/cer_' ds])