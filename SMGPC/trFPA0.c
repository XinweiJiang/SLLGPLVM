// function t = trFPA(FP,A,nn,m)
// t=0;
// for c = 1:m
//   d = diag(FP(1+(c-1)*nn:c*nn,1:nn));
//   fe = A(1+(c-1)*nn:c*nn,1);
//   t = t + d'*fe;
// end

#include "mex.h" 
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) 
{
    double *FP, *A; 
    double *outData; 
    int m,nn; 
    int c,i,mn;
    
    FP=mxGetPr(prhs[0]);
    A=mxGetPr(prhs[1]);
    nn=mxGetScalar(prhs[2]); 
    m=mxGetScalar(prhs[3]); 
    plhs[0]=mxCreateDoubleMatrix(1,1,mxREAL); 
    outData=mxGetPr(plhs[0]);   
    mn = m*nn;
    
    for( c=0; c<m; ++c)
    {
        for (i = 0; i < nn; ++i)
            outData[0] = outData[0] + FP[c*nn+i+i*mn]*A[c*nn+i];
    }
}
