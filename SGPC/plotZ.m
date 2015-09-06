function [] = plotZ(X, Y, strFileName, isAutoClose)

%
%X: design matrix
%Y: class label
%strFileName: filename for eps picture
%isAutoClose: does automatically close the plot?

BASEPATH = '';
MARKERLABELS = char('.','+','o','square','diamond','v','x','*','pentagram','hexagram');
COLORLABLES = [[1 0 0]; [0 1 0]; [0 0 1]; [0.5 0.5 0]; [1 0 1]; [0 1 1]; [0.8 0 0.8]; [0.5 0.5 0.5]; [0 0.5 0.5]; [0.5 0.5 0.5]];
MARKERSIZE = 10;

if size(X,2) > 4
    return;
end

h0 = figure; 
if size(X,2) == 1
    hAxes = axes('NextPlot','add',...           %# Add subsequent plots to the axes,
             'DataAspectRatio',[1 1 1],...  %#   match the scaling of each axis,
             'XLim',[floor(min(X)) ceil(max(X))],...               %#   set the y axis limit,
             'YLim',[0 eps]...             %#   set the x axis limit (tiny!),
              );               %#   and don't use a background color
elseif size(X,2) == 2
    hAxes = axes('NextPlot','add');           %# Add subsequent plots to the axes,
end

for i = 1:size(X,1)
    if size(Y, 2) == 1 && length(unique(Y)) == 2
        % binary case
        if size(X,2) == 2
            if Y(i) == 1
                plot(hAxes,X(i,1),X(i,2),'MarkerSize',MARKERSIZE,'Marker','+','LineWidth',1,'LineStyle','none','Color',[1 0 0]);
            else
                plot(hAxes,X(i,1),X(i,2),'MarkerSize',MARKERSIZE,'Marker','.','LineWidth',1,'LineStyle','none','Color',[0 0 1]);
            end
        elseif size(X,2) == 1
             if Y(i) == 1
                plot(hAxes,X(i,1),0,'MarkerSize',MARKERSIZE,'Marker','+','LineWidth',1,'LineStyle','none','Color',[1 0 0]);
            else
                plot(hAxes,X(i,1),0,'MarkerSize',MARKERSIZE,'Marker','.','LineWidth',1,'LineStyle','none','Color',[0 0 1]);
             end
        elseif size(X,2) == 3
            if Y(i) == 1
                plot3(X(i,1),X(i,2),X(i,3),'MarkerSize',MARKERSIZE,'Marker','+','LineWidth',1,'LineStyle','none','Color',[1 0 0]);
            else
                plot3(X(i,1),X(i,2),X(i,3),'MarkerSize',MARKERSIZE,'Marker','.','LineWidth',1,'LineStyle','none','Color',[0 0 1]);
            end
            hold on;
        end
        
    else
        % multi-class case with 1-of-n encode schame
        m = size(Y, 2);
        if m == 1
            Y = smgpTransformLabel( Y );
            m = size(Y, 2);
        end
        
        if size(X,2) == 2
            for j = 1:m
                if Y(i, j) == 1
                    plot(hAxes,X(i,1),X(i,2),'MarkerSize',MARKERSIZE,'Marker',MARKERLABELS(j),'LineWidth',1,'LineStyle','none','Color',COLORLABLES(j,:));
                    break;
                end
            end
        elseif size(X,2) == 1
            for j = 1:m
                if Y(i, j) == 1
                    plot(hAxes,X(i,1),0,'MarkerSize',MARKERSIZE,'Marker',MARKERLABELS(j),'LineWidth',1,'LineStyle','none','Color',COLORLABLES(j,:));
                    break;
                end
            end
        elseif size(X,2) == 3
            for j = 1:m
                if Y(i, j) == 1
%                     plot3(hAxes,X(i,1),X(i,2),X(i,3),'Marker',MARKERLABELS(j),'Color',COLORLABLES(j,:));
                    plot3(X(i,1),X(i,2),X(i,3),'MarkerSize',MARKERSIZE,'Marker',MARKERLABELS(j),'Color',COLORLABLES(j,:));
                    hold on;
                    break;
                end
            end
        end
        
    end
end

% ylim(hAxes,[0 eps]);
% plot(model.Z(1:100,:),'Marker','.','LineWidth',2,'LineStyle','none','Color',[0 0 1]);legend();
% hold;
% plot(model.Z(1:50,:),'Marker','+','LineWidth',2,'LineStyle','none','Color',[1 0 0]);legend();
% 
% mylegend = legend('Class 5','Class 3');
% set(mylegend,'Location','NorthWest');
title('Z');
if size(X,2) == 3
    xlabel('Z1');ylabel('Z2');zlabel('Z3');
    grid on;
end
% hold off;
print(h0,'-depsc2','-tiff', '-loose', '-r600', [BASEPATH 'dv_' strFileName '.eps'])

if nargin > 3 
    if isAutoClose == 1
        close(h0);
    end
end
