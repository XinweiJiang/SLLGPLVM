function [] = plotAndImageZ(ds, X, Y, O, strFileName, isAutoClose, isLine)

BASEPATH = 'R:/';
% MARKERLABELS = char('*','+','o','square','diamond','v','x','.','pentagram','hexagram');
MARKERLABELS = char('.','+','o','square','diamond','v','x','*','pentagram','hexagram');
COLORLABLES = [[1 0 0]; [0 0 1]; [0 1 0]; [0.5 0.5 0]; [1 0 1]; [0 1 1]; [0.8 0 0.8]; [1 0.5 0.5]; [0 0.5 0.5]; [0.5 0.5 0.5]];
% COLORLABLES = [[0.7 0.7 0.7]; [1 0 0]; [0 0 1]; [0.5 0.5 0]; [1 0 1]; [0 1 1]; [0.8 0 0.8]; [1 1 1]; [0 0.5 0.5]; [0.5 0.5 0.5]];
MARKERSIZE = 10;
LSTYLE = '-'; %'none'
LWIDTH = 1;%1

if size(X,2) > 4
    return;
end

if nargin < 7
    isLine = 1;
end

switch ds
    case {'Teapots','TeapotsFT'}
        SCALE = 0.04;BASEIDX = 0;MODNUM = 6;
        S = [76,101,3];
        ROTATEDEGREE = 180;
    case 'Coil'
        SCALE = 0.45;BASEIDX = 0;MODNUM = 5;
        S = [128,128];
        ROTATEDEGREE = 180;
    case {'Face','FaceFT','FaceSmile','FaceSad'}
        SCALE = 0.3;BASEIDX = 0;MODNUM = 10;
        S = [20,28];
        ROTATEDEGREE = 90;
    case 'Hand'
        SCALE = 0.2;BASEIDX = 2;MODNUM = 15;
        S = [60,64];
        ROTATEDEGREE = 180;
    case 'IsomapFace'
        SCALE = 0.8;BASEIDX = 0;MODNUM = 13;
        S = [64,64];
        ROTATEDEGREE = 180;
    case {'Usps0To4','Usps0To4NC','Usps5And3'}
        SCALE = 0.2;BASEIDX = 0;MODNUM = 10;
        S = [16,16];
        ROTATEDEGREE = 90;
    case {'UmistFace','UmistFace1','UmistFace2','UmistFace3','UmistFace5'}
        SCALE = 0.15;BASEIDX = 1;MODNUM = 5;
        S = [112,92];
        ROTATEDEGREE = 180;
    otherwise
        SCALE = 0.2;BASEIDX = 0;MODNUM = 4;
        S = [128,128];
        ROTATEDEGREE = 180;
end
YPROP = S(2)/S(1)/2;

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
if size(X,2) == 3
    hold on;
    pAxes = axes('Visible','off');
    hold on;
end
axis equal;

for i = 1:size(X,1)
    if size(Y, 2) == 1 && length(unique(Y)) == 2
        % binary case
        if size(X,2) == 2
            if Y(i) == 1
                plot(hAxes,X(i,1),X(i,2),'MarkerSize',MARKERSIZE,'Marker',MARKERLABELS(1),'LineWidth',LWIDTH,'LineStyle',LSTYLE,'Color',[1 0 0]);
            else
                plot(hAxes,X(i,1),X(i,2),'MarkerSize',MARKERSIZE,'Marker',MARKERLABELS(2),'LineWidth',LWIDTH,'LineStyle',LSTYLE,'Color',[0 0 1]);
            end
            hold on;
            if mod(BASEIDX+i,MODNUM) == 0
                if length(S) == 2
                    d0=imrotate(reshape(O(i,:),S(1),S(2)),ROTATEDEGREE);
                    image(d0,'XData',[X(i,1)-SCALE X(i,1)+SCALE],'YData',[X(i,2)-SCALE*YPROP X(i,2)+SCALE*YPROP],'CDataMapping','scaled');
                elseif length(S) == 3
                    d0=imrotate(reshape(O(i,:),S(1),S(2),S(3)),ROTATEDEGREE);
                    image(d0,'XData',[X(i,1)-SCALE  X(i,1)+SCALE],'YData',[X(i,2)-SCALE*YPROP X(i,2)+SCALE*YPROP],'CDataMapping','scaled');
                end
                colormap('gray');
            end
            hold on;
        elseif size(X,2) == 1
             if Y(i) == 1
                plot(hAxes,X(i,1),0,'MarkerSize',MARKERSIZE,'Marker',MARKERLABELS(1),'LineWidth',LWIDTH,'LineStyle',LSTYLE,'Color',[1 0 0]);
            else
                plot(hAxes,X(i,1),0,'MarkerSize',MARKERSIZE,'Marker',MARKERLABELS(2),'LineWidth',LWIDTH,'LineStyle','none','Color',[0 0 1]);
             end
        elseif size(X,2) == 3
            if Y(i) == 1
                plot3(X(i,1),X(i,2),X(i,3),'MarkerSize',MARKERSIZE,'Marker',MARKERLABELS(1),'LineWidth',LWIDTH,'LineStyle',LSTYLE,'Color',[1 0 0]);
            else
                plot3(X(i,1),X(i,2),X(i,3),'MarkerSize',MARKERSIZE,'Marker',MARKERLABELS(2),'LineWidth',LWIDTH,'LineStyle',LSTYLE,'Color',[0 0 1]);
            end
            hold on;
            if mod(BASEIDX+i,MODNUM) == 0
                if length(S) == 2
                    d0=imrotate(reshape(O(i,:),S(1),S(2)),ROTATEDEGREE);
                    image(d0,'XData',[X(i,1)-SCALE X(i,1)+SCALE],'YData',[X(i,2)-SCALE*YPROP X(i,2)+SCALE*YPROP],'CDataMapping','scaled');
                elseif length(S) == 3
                    d0=imrotate(reshape(O(i,:),S(1),S(2),S(3)),ROTATEDEGREE);
                    image(d0,'XData',[X(i,1)-SCALE X(i,1)+SCALE],'YData',[X(i,2)-SCALE*YPROP X(i,2)+SCALE*YPROP],'CDataMapping','scaled');
                end
                colormap('gray');
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
                    plot(hAxes,X(i,1),X(i,2),'MarkerSize',MARKERSIZE,'Marker',MARKERLABELS(j),'LineWidth',LWIDTH,'LineStyle',LSTYLE,'Color',COLORLABLES(j,:));
                    break;
                end
            end
            hold on;
            if mod(BASEIDX+i,MODNUM) == 0
                if length(S) == 2
                    d0=imrotate(reshape(O(i,:),S(1),S(2)),ROTATEDEGREE);
                    image(d0,'XData',[X(i,1)-SCALE X(i,1)+SCALE],'YData',[X(i,2)-SCALE*YPROP X(i,2)+SCALE*YPROP],'CDataMapping','scaled');
                elseif length(S) == 3
                    d0=imrotate(reshape(O(i,:),S(1),S(2),S(3)),ROTATEDEGREE);
                    image(d0,'XData',[X(i,1)-SCALE  X(i,1)+SCALE],'YData',[X(i,2)-SCALE*YPROP X(i,2)+SCALE*YPROP],'CDataMapping','scaled');
                end
                colormap('gray');
            end
            hold on;
        elseif size(X,2) == 1
            for j = 1:m
                if Y(i, j) == 1
                    plot(hAxes,X(i,1),0,'MarkerSize',MARKERSIZE,'Marker',MARKERLABELS(j),'LineWidth',LWIDTH,'LineStyle',LSTYLE,'Color',COLORLABLES(j,:));
                    break;
                end
            end
        elseif size(X,2) == 3
            for j = 1:m
                if Y(i, j) == 1
%                     plot3(hAxes,X(i,1),X(i,2),X(i,3),'Marker',MARKERLABELS(j),'Color',COLORLABLES(j,:));
                    plot3(X(i,1),X(i,2),X(i,3),'MarkerSize',MARKERSIZE,'Marker',MARKERLABELS(j),'Color',COLORLABLES(j,:),'LineWidth',LWIDTH,'LineStyle',LSTYLE);
                    hold on;
                    break;
                end
            end
            hold on;
            if mod(BASEIDX+i,MODNUM) == 0
                if length(S) == 2
                    d0=imrotate(reshape(O(i,:),S(1),S(2)),ROTATEDEGREE);
                    image(d0,'Parent',pAxes,'XData',[X(i,1)-SCALE X(i,1)+SCALE],'YData',[X(i,2)-SCALE*YPROP X(i,2)+SCALE*YPROP],'CDataMapping','scaled');
                elseif length(S) == 3
                    d0=imrotate(reshape(O(i,:),S(1),S(2),S(3)),ROTATEDEGREE);
                    image('Parent',pAxes,d0,'XData',[X(i,1)-SCALE X(i,1)+SCALE],'YData',[X(i,3)-SCALE*YPROP X(i,3)+SCALE*YPROP],'CDataMapping','scaled');
                end
                colormap('gray');
            end
            hold on;
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
if isLine
    if size(X,2) == 2
        plot(X(:,1),X(:,2),'MarkerSize',MARKERSIZE,'Marker','.','LineWidth',LWIDTH,'LineStyle',LSTYLE,'Color',[0.6 0 0]);
    elseif size(X,2) == 3
        plot3(X(:,1),X(:,2),X(:,3),'MarkerSize',MARKERSIZE,'Marker','.','LineWidth',LWIDTH,'LineStyle',LSTYLE,'Color',[0 0 0]);
        xlabel('Z1');ylabel('Z2');zlabel('Z3');
        grid on;
    end
end
% axis image;
% view(0,90);
hold off;

print(h0,'-depsc','-tiff', '-loose', '-r600', [BASEPATH 'dv_' strFileName])

if nargin > 3 
    if isAutoClose == 1
        close(h0);
    end
end
