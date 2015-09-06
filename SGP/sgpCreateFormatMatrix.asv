function o = sgpCreateFormatMatrix( i, x )
%SGPCREATEFORMATMATRIX Summary of this function goes here
%   Detailed explanation goes here

if size(x, 2) ~= 1
    error('sgpCreateFormatMatrix Needs column vector!');
end

N = size(x, 1);
o = zeros(N, N);

o(i, :) = x';
o(:, i) = x;

end

