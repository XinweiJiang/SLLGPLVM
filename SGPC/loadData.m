function [ x,y ] = loadData( dataSetName )
%LOADIONOSPHERE Summary of this function goes here
%   Detailed explanation goes here

data = load(dataSetName);
[n, d] = size(data);

if strcmp(dataSetName, 'wine.data')
    t = data(1:n, 1);
    data = [data(1:n, 2:d) t];
end

x = data(1:n, 1:d-1);
y = data(1:n, d);

fprintf('\n------------------------------------------------------------\n');
fprintf('Dataset: %s; \nNum: %d; Dim: %d; Class: %d', dataSetName,size(x,1),size(x,2),length(unique(y)));
fprintf('\n------------------------------------------------------------\n');
end

