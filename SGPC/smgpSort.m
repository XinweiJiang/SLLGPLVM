function [ xx, yy ] = smgpSort( x, y )
%SMGPSORT Summary of this function goes here
%   Detailed explanation goes here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% x : NxD matrix
% y : Nxm matrix with y(i,:) = [0,...,0,1,0,...,0] or \subset{1,...,M}
% xx : sorted NxD matrix
% yy : sorted Nxm matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[n, d] = size(x);
m = size(y, 2);
xx = zeros(n,d);
yy = zeros(n,m);

if m == 1
    U = sort(unique(y));
    counter = 1;
    for i = 1:length(U)
        indices = find(y==U(i));
        xx(counter:counter+length(indices)-1, :) = x(indices, :);
        yy(counter:counter+length(indices)-1, :) = y(indices, :);
        counter = counter + length(indices);
    end
else
    nSum0 = sum(y);
    nSum = zeros(m);
    for i = 2:length(nSum)
        nSum(i) = sum(nSum0(1:i-1));
    end
   
    cci = zeros(m,1);

    for i = 1:n
        for j = 1:m
            if y(i, j) == 1
               cci(j) = cci(j)+1;
               xx(cci(j)+nSum(j),:) = x(i,:);
               yy(cci(j)+nSum(j),:) = y(i,:);
            end
        end
    end
end

end

