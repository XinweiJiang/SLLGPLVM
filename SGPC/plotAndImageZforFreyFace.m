function [] = plotAndImageZforFreyFace(X,nEachClass)

BASEPATH = 'R:/';
figure1 = figure; 
% hAxes = axes('NextPlot','add'); 

SCALEX = 0.3;
SCALEY = SCALEX*28/10;

% subplot(1,3,1);
axes1 = axes('Parent',figure1,'ZColor',[1 0 0],'YTick',zeros(1,0),...
    'YDir','reverse',...
    'YColor',[1 0 0],...
    'XColor',[1 0 0],...
    'Position',[0.350418410041835 -0.00452488687782803 0.0627615062761469 1.00226244343891],...
    'Layer','top');
box(axes1,'on');
hold(axes1,'all');
for i = 1:13
    d0=imrotate(reshape(X((i-1)*nEachClass+1,:),20,28),270);
    image(d0,'Parent',axes1,'XData',[0  2*SCALEX],'YData',[(i-1)*SCALEY i*SCALEY],'CDataMapping','scaled');
end
colormap('gray');
set(gca,'ytick',[]);
axis image;
hold off;

% subplot(1,3,2);
axes2 = axes('Parent',figure1,'ZColor',[0 0 1],'YTick',zeros(1,0),...
    'YDir','reverse',...
    'YColor',[0 0 1],...
    'XColor',[0 0 1],...
    'Position',[0.437238493723847 0.00226244343891403 0.0638075313807533 0.995475113122174],...
    'Layer','top');
box(axes2,'on');
hold(axes2,'all');
for i = 1:14
    j = i+13;
    d0=imrotate(reshape(X((j-1)*nEachClass+1,:),20,28),270);
    image(d0,'Parent',axes2,'XData',[0  2*SCALEX],'YData',[(i-1)*SCALEY i*SCALEY],'CDataMapping','scaled');
end
colormap('gray');
set(gca,'ytick',[]);
axis image;
hold off;

% subplot(1,3,3);
axes3 = axes('Parent',figure1,'ZColor',[0 1 0],'YTick',zeros(1,0),...
    'YDir','reverse',...
    'YColor',[0 1 0],...
    'XColor',[0 1 0],...
    'Position',[0.523012552301235 0 0.0554393305439518 0.997737556561109],...
    'Layer','top');
box(axes3,'on');
hold(axes3,'all');
for i = 1:15
    j = i+27;
    d0=imrotate(reshape(X((j-1)*nEachClass+1,:),20,28),270);
    image(d0,'Parent',axes3,'XData',[0  2*SCALEX],'YData',[(i-1)*SCALEY i*SCALEY],'CDataMapping','scaled');
end
colormap('gray');
set(gca,'ytick',[]);
axis image;
hold off;

print(figure1,'-depsc2','-tiff', '-loose', '-r600', [BASEPATH 'dv_FreyFaceBar'])

end
