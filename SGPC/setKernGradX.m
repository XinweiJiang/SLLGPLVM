function g = setKernGradX( kern, x, x2 )
%SETKERNGRADX Summary of this function goes here
%   Detailed explanation goes here

%%%%%%'rbf', 'bias', 'white'
switch kern.type
    case 'covSEiso'
       fhandle = str2func(['rbf' 'KernGradX']);
       g = fhandle(kern, x, x2);
    case 'covLINone'
       fhandle = str2func(['lin' 'KernGradX']);
       g = fhandle(kern, x, x2);
       fhandle = str2func(['bias' 'KernGradX']);
       g = g+fhandle(kern, x, x2);
    case 'covSEard'
       fhandle = str2func(['rbfard2' 'KernGradX']);
       g = fhandle(kern, x, x2);    
   case 'covLINard'
       fhandle = str2func(['linard2' 'KernGradX']);
       g = fhandle(kern, x, x2);
    case 'covMulitRbfArd'
        fhandle = str2func(['rbfard2white' 'KernGradX']);
        g = fhandle(kern, x, x2);
    case 'covMulitLinArd'
        fhandle = str2func(['linardwhite' 'KernGradX']);
        g = fhandle(kern, x, x2);
   otherwise
    error('Unknown data set requested.')
end

end

