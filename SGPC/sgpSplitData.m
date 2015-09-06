function [ SplitedX,SplitedY,SplitedXX,SplitedYY ] = sgpSplitData( x,y,xx,yy )
%SGPSPLITDATA Summary of this function goes here
%   Detailed explanation goes here

% Split data with 1-vs-rest scheme
if size(y,2) > 1
    y = smgpTransformLabel( y );
    yy = smgpTransformLabel( yy );
end

yU = unique(y);
nClass = length(yU);
[nTr,nDim] = size(x);
nTe = length(yy);
% SplitedX = zeros(nTr, nDim, nClass);
% SplitedY = zeros(nTr, 1, nClass)-1;
% SplitedXX = zeros(nTe, nDim, nClass);
% SplitedYY = zeros(nTe, 1, nClass)-1;
SplitedX = cell(1, nClass);
SplitedY = cell(1, nClass);
SplitedXX = cell(1, nClass);
SplitedYY = cell(1, nClass);

for i = 1:nClass
    SX = zeros(nTr, nDim);
    SY = zeros(nTr, 1)-1;
    SXX = zeros(nTe, nDim);
    SYY = zeros(nTe, 1)-1;
    
    indexTr1 = find(y==yU(i));
    indexTr2 = find(y~=yU(i));
    indexTe1 = find(yy==yU(i));

    SX(1:length(indexTr1),:) = x(indexTr1,:);
    SX(length(indexTr1)+1:nTr,:) = x(indexTr2,:);
    SY(1:length(indexTr1),:) = ones(length(indexTr1),1);
    
    SXX(1:nTe,:) = xx;
    SYY(indexTe1,:) = ones(length(indexTe1),1);
    
    SplitedX{i} = SX;
    SplitedY{i} = SY;
    SplitedXX{i} = SXX;
    SplitedYY{i} = SYY;

%     SplitedXX(1:length(indexTe1),:, i) = xx(indexTe1,:);
%     SplitedXX(length(indexTe1)+1:nTe,:, i) = xx(indexTe2,:);
%     SplitedYY(1:length(indexTe1),:, i) = ones(length(indexTe1),1);
end
end

