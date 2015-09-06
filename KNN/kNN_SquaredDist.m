function [retAcc, resultClass, classes, distance] = kNN_SquaredDist(sampleData, testData, y, yy, k)

% [resultClass, classes] = knn(sampleData, testData, k)
%
% Simple k-Nearest Neighbour algorithm
%
% Example   : sampledata = [1 3 1; 2 1 1; 3 2 2; 0 3 2];
%             testdata=[1 1];
%             k=3;
%             knn(sampledata,testdata,k)

N = size(sampleData,1);  % N is length of data
nTest = size(testData,1);

distance = dist2(sampleData, testData);

nShort = min(N, k);
classes = zeros(nShort, nTest);
resultClass = zeros(nTest,1);

% Sort distances ascending
[sorted, idx] = sort(distance, 'ascend');

% Order classes according to distance and
% choose k first (nearest neighbourhood)
for i = 1:nTest
    classes(:,i) = y(idx(1:nShort, i));

    % Result is classified in class with most neighbours
    resultClass(i) = mode(classes(:,i));
end

retAcc = length(find(resultClass-yy==0))/nTest*100;

% % Plot bars for classes of nearest neighbours
% figure(2);
% hist(classes,[1:max(2,max(sampleData(:,M)))]);
