function g = setKernCompute( kern, x, x2 )
%SETKERNGRADX Summary of this function goes here
%   Detailed explanation goes here

%%%%%%'rbf', 'bias', 'white'
switch kern.type
   case 'covSEiso'
       fhandle = str2func(['rbf' 'KernCompute']);
    case 'covMulitRbfArd'
        fhandle = str2func(['rbfard2white' 'KernCompute']);
    case 'covMulitLinArd'
        fhandle = str2func(['linardwhite' 'KernCompute']);
   otherwise
    error('Unknown data set requested.')
end

if nargin < 3
  g = fhandle(kern, x);
else
  g = fhandle(kern, x, x2);
end

