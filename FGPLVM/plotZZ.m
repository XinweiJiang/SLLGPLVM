function [] = plotZZ(model, strFileName)

for i = 1:size(model.Z,1)
    if i ~= 1
%         axisHand = gca;
%         nextPlot = get(axisHand, 'nextplot');
%         set(gca, 'nextplot', 'add');
hold all;
    end
    if model.Y(i) == 1
        plot(model.Z(i,1),model.Z(i,2),'Marker','+','LineWidth',4,'LineStyle','none','Color',[1 0 0]);
    else
        plot(model.Z(i,1),model.Z(i,2),'Marker','.','LineWidth',4,'LineStyle','none','Color',[0 0 1]);
    end
end

% plot(model.Z(1:100,:),'Marker','.','LineWidth',2,'LineStyle','none','Color',[0 0 1]);legend();
% hold;
% plot(model.Z(1:50,:),'Marker','+','LineWidth',2,'LineStyle','none','Color',[1 0 0]);legend();
% 
% mylegend = legend('Class 5','Class 3');
% set(mylegend,'Location','NorthWest');
title('Z');

strFilePath = strcat('R:/dv_', strFileName);

print('-depsc2','-tiff', '-loose', '-r600', strFilePath)