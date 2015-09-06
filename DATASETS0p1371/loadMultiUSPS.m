function [ x,y,xx,yy ] = loadMultiUSPS( classLabels, nTr, nTe )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% classLabels : the vector cosisting of the sorted class labels like [0;1;2;3;4;...;9]
% nTr : the number of training data in each class
% nTe : the number of testing data in each class
% x : training X
% y : training Y with 1-of-m encode scheme labels
% xx: testing X
% yy: trsting Y

x = [];y = [];xx = []; yy = [];
if size(classLabels,2) > 1
    classLabels = classLabels';
end
nClass = length(classLabels);
oddSign = 0;

% for odd class number, add one class manually
if mod(nClass,2) == 1
    classLabels = [classLabels;0];
    nClass = nClass+1;
    oddSign = 1;
end    
eyeC = eye(nClass);

for ci=1:2:nClass
    [xi, yi0, xxi, yyi0] = loadBinaryUSPS(classLabels(ci), classLabels(ci+1));
    
    nI = size(xi,1);    
    nJ = size(xxi,1); 
    yi = zeros(nI, nClass);
    yyi = zeros(nJ, nClass);
    
    indeces = find(yi0 == 1);
    yi(indeces,:) = repmat(eyeC(ci,:), length(indeces), 1);
    indeces = find(yi0 == -1);
    yi(indeces,:) = repmat(eyeC(ci+1,:), length(indeces), 1);
    indeces = find(yyi0 == 1);
    yyi(indeces,:) = repmat(eyeC(ci,:), length(indeces), 1);
    indeces = find(yyi0 == -1);
    yyi(indeces,:) = repmat(eyeC(ci+1,:), length(indeces), 1);
    
    if nTr < 1
        nTr = nI;
    end
    if nTe < 1
        nTe = nJ;
    end
    if nTr > floor(nI./2)
        nTr = floor(nI./2);
    end
    if nTe > floor(nJ./2)
        nTe = floor(nJ./2);
    end    
    
    x = [x;xi(1:nTr,:);xi(nI-nTr+1:nI,:)];
    y = [y;yi(1:nTr,:);yi(nI-nTr+1:nI,:)];
    xx = [xx;xxi(1:nTe,:);xxi(nJ-nTe+1:nJ,:)];
    yy = [yy;yyi(1:nTe,:);yyi(nJ-nTe+1:nJ,:)];
end

if oddSign == 1
    indeces = find(y(:,nClass) == 0);
    x = x(indeces,:);
    y = y(indeces,1:nClass-1);
    indeces = find(yy(:,nClass) == 0);
    xx = xx(indeces,:);
    yy = yy(indeces,1:nClass-1);
end

end

