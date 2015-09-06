#include "mex.h" 
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) 
{
    double *outData,*inData0,*inData1; 
    int k,t,m,n;
    
    inData0=mxGetPr(prhs[0]);
    inData1=mxGetPr(prhs[1]);
    m=mxGetM(prhs[0]); 
    n=mxGetN(prhs[0]); 
    plhs[0] = mxCreateDoubleMatrix(m,1,mxREAL);
    outData = mxGetPr(plhs[0]);     
    
    for(k = 0; k < n; ++k)
    {
        outData[0] = outData[0] + inData0[k]*inData1[k];
        mexPrintf("%f\t%f\n",inData0[k], inData1[k]);
    }
//     for(k = 0; k < m; ++k)
//     {
//         for(t = 0; t < n; ++t)
//             outData[k] +=  inData0[t*m+k]*inData1[t];
//      }
}