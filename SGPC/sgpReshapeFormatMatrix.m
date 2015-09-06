function o = sgpReshapeFormatMatrix( T, m, n )
%SGPRESHAPEFORMATMATRIX Summary of this function goes here
%   Detailed explanation goes here

N = size(T,1);
o = zeros(N,1);

for i = 1:N
    o(i,1) = T(m,n,i);
end

end

