function out = sgpReshapeGradientK( dfdKmn ,n )
%SGPRESHAPEGRADIENTK Summary of this function goes here
%   Detailed explanation goes here

N = size(dfdKmn, 1);
out = zeros(N, N);

for i = 1:N
    for j = 1:N
        out(i,j) = dfdKmn(n, i, j);
    end
end


end

