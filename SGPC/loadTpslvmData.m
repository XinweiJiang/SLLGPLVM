function [ x,y,xx,yy ] = loadTpslvmData( ds, param )
%LOADIONOSPHERE Summary of this function goes here
%   Detailed explanation goes here

xx = [];yy = [];
switch ds
    case {'Oil','OilFT'}
        if nargin < 2 || param < 1
            param = 200;
        end
        [x, y] = lvmLoadData('oil');
        % x = sgpNormalize( x );
        [ x, y ] = smgpSort( x, y );
        if param < 1000
            [ x, y, xx, yy ] = sgpDivTrainTestData( x, y, param, 3 );   
        end
    case {'OilNC'}
        [x, y] = lvmLoadData('oil');
        % x = sgpNormalize( x );
        [ x, y ] = smgpSort( x, y );
        [ x, y, xx, yy ] = sgpDivTrainTestData( x, y, param, 1000 );     
    case 'IrisFT'
        [x, y] = loadData('iris.modified.data');
        x = sgpNormalize( x );
        [ x, y ] = smgpSort( x, y );
    case 'SwissrollFT'
        if nargin < 2 || param < 1
            param = 100;
        end
        [x, y] = loadSwissroll(param);
        % x = sgpNormalize( x );
        [ x, y ] = smgpSort( x, y );
    case 'TeapotsFT'
        load('teapots100.mat');
        x = double(teapots')./255;
        y = ones(size(x,1),1);
    case 'Coil'
        load('Coil20.mat');
        x = double(data{1})./255;
        y = ones(size(x,1),1);
    case 'UmistFace1'
        if nargin < 2 || param < 1
            param = 1;
        end
        load('umistface_112x92.mat');
        x = []; y = [];
        for i = 1:param
            x = [x; double(datacell{i})./255];
            y = [y; i*ones(size(datacell{i},1),1)];
        end
    case 'UmistFace2'
        if nargin < 2 || param < 1
            param = 2;
        end
        load('umistface_112x92.mat');
        x = []; y = [];
        for i = 1:param
            x = [x; double(datacell{i})./255];
            y = [y; i*ones(size(datacell{i},1),1)];
        end    
    case 'UmistFace5'
        if nargin < 2 || param < 1
            param = 5;
        end
        load('umistface_112x92.mat');
        x = []; y = [];
        for i = 1:param
            x = [x; double(datacell{i})./255];
            y = [y; i*ones(size(datacell{i},1),1)];
        end
    case {'Vowels'}
        if nargin < 2 || param < 1
            param = 100;
        end
        load('Vowels');
        [ x, y ] = smgpSort( x, y );
        [ x, y, xx, yy ] = sgpDivTrainTestData( x, y, param, 1 );
        xx = x(1:4,:);yy = y(1:4,:);
    case 'Usps5And3DC'
        [x, y, xx, yy] = loadBinaryUSPS(3,5);
        xx = [x(51:717,:); xx];
        yy = [y(51:717,:); yy];
        x1 = x(1:50,:);x2 = x(718:767,:);
        x=[x1;x2];
        y1 = y(1:50,:);y2 = y(718:767,:);
        y=[y1;y2];
        clear x1 x2 y1 y2;
    case 'WineDC'
        [ x,y ] = loadData( 'wine.data' );
        [ x, y ] = smgpSort( x, y );
        [ x, y, xx, yy ] = sgpDivTrainTestData( x, y, 30, 1000 );
    case 'WineNC'
        [ x,y ] = loadData( 'wine.data' );
        [ x, y ] = smgpSort( x, y );
        [ x, y, xx, yy ] = sgpDivTrainTestData( x, y, param, 1000 );
    case 'IonosphereNC'
        [ x,y ] = loadData( 'ionosphere.modified.data' );
        [ x, y ] = smgpSort( x, y );
        x = sgpNormalize( x );
        [ x, y, xx, yy ] = sgpDivTrainTestData( x, y, param, 1000 );
    case 'Usps0To4NC'
        dataLabels = [0,1,2,3,4];
        [ x,y,xx,yy ] = loadMultiUSPS( dataLabels, param, 500 );
    case 'GisetteNC'
        load('Gisette_Scale.mat');
        [ x, y, xx0, yy0 ] = sgpDivTrainTestData( x, y, param, 1000 );
    otherwise
        load(ds);
end


fprintf('\n------------------------------------------------------------\n');
fprintf('Dataset: %s; \nNum: %d; Dim: %d; Class: %d', ds,size(x,1),size(x,2),length(unique(y)));
fprintf('\n------------------------------------------------------------\n');
end

