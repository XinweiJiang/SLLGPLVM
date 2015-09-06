function [ yy ] = smgpTransformLabel( y )
%TRANSFORMLABEL Summary of this function goes here
%   Detailed explanation goes here
% y : n x m matrix with 1-of-m schame or 1,...,m
% yy : 1,...,m or 1-of-m schame
% m : number of class
% n : number of sample

[n, m] = size(y);

if m == 1           %1,...,m to 1-of-m schame
    U = sort(unique(y));%, 'descend');
    nClass  = length(U);
    yy = zeros(n, nClass);
    ceye = eye(nClass);
    
    for i = 1:nClass
        indices = find(y == U(i));
        yy(indices, :) = repmat(ceye(i,:), length(indices), 1);
    end
else
    yy = zeros(n,1);
    
    for i = 1:n
        for j = 1:m
            if y(i,j) == 1
                yy(i) = j;
                break;
            end
        end
    end
    
    U = unique(yy);
    if length(U) == 2
        indices = find(yy == 1);
        yy(indices, :) = repmat([-1], length(indices), 1);
        indices = find(yy == 2);
        yy(indices, :) = repmat([1], length(indices), 1);
    end
        
end

end

