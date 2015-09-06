function o = sgpOuterProduct( x, y )
%SGPOUTERPRODUCT Summary of this function goes here
%   Detailed explanation goes here

%Check the column vectors x and y
if size(x,1) ~= 1 || size(y,1) ~= 1
    error('The dimension of the input vector for outerproduct evaluation is not 1.');
end

o = x'*y;

end

