function k = setKernDiagGradX(kern, x)

% SETKERNDIAGGRADX Compute the gradient of the  kernel wrt X.

%%%%%%'rbf', 'bias', 'white'
switch kern.type
   case 'covSEiso'
       fhandle = str2func(['rbf' 'KernDiagGradX']);
       k = fhandle(kern, x);
   case 'covLINone'
       fhandle = str2func(['lin' 'KernDiagGradX']);
       k = fhandle(kern, x);
       fhandle = str2func(['bias' 'KernDiagGradX']);
       k = k+fhandle(kern, x);
   case 'covSEard'
       fhandle = str2func(['rbfard2' 'KernDiagGradX']);
       k = fhandle(kern, x);    
   case 'covLINard'
       fhandle = str2func(['linard2' 'KernDiagGradX']);
       k = fhandle(kern, x);
   case 'covMulitRbfArd'
        fhandle = str2func(['rbfard2white' 'KernDiagGradX']);
        k = fhandle(kern, x);
   case 'covMulitLinArd'
        fhandle = str2func(['linardwhite' 'KernDiagGradX']);
        k = fhandle(kern, x);
   otherwise
    error('Unknown data set requested.')
end
end
