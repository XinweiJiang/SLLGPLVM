// function dfdKmn0 = smgpCreateFormatMatrix( indM, indN, ybp )
// %SMGPCCREATEFORMATMATRIX Summary of this function goes here
// %   Detailed explanation goes here
// 
// mntr = length(ybp);
// K = sparse(mntr, mntr);
// 
// K(indM, indN) = 1;
// K(indN, indM) = 1;
// 
// dfdKmn0 = K*ybp;
// 
// end

#include "mex.h" 
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) 
{
    double *inData; 
    double *outData; 
    int M,N; 
    int indM,indN; 
    
    indM=mxGetScalar(prhs[0]); 
    indN=mxGetScalar(prhs[1]); 
    inData=mxGetPr(prhs[2]); 
    M=mxGetM(prhs[2]); 
    N=mxGetN(prhs[2]); 
    plhs[0]=mxCreateDoubleMatrix(M,1,mxREAL); 
    outData=mxGetPr(plhs[0]);        
    
    if(N != 1)
        mexErrMsgTxt("The third input must be colmun vector!");
    
    outData[indM-1] = inData[indN-1];
    outData[indN-1] = inData[indM-1];
}