// function [dnlK0] = subMgrad(m, ntr, invS5, ybp, FP, diagF)
// 
// for ci = 1:m
//     for i = 1+ntr*(ci-1):ntr*ci
//       for j = 1+ntr*(ci-1):ntr*ci
//           dfdKmn = invS5*smgpCreateFormatMatrix( i, j, ybp );
//           dnlK0(i, j) = diagF'*dfdKmn - 2.*trFPA(FP,dfdKmn,ntr,m);
//       end
//     end
// end

#include "mex.h" 
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) 
{
    double *invS5,*ybp,*FP,*diagF,*dK,*dfdKmn; 
    mxArray *pDk,*pDfdKmn;
    double *outData; 
    double nDfdf,nTrFPA;
    int m,ntr,mntr; 
    int ci,i,j,k,t,c;
    
    m=mxGetScalar(prhs[0]); 
    ntr=mxGetScalar(prhs[1]); 
    invS5=mxGetPr(prhs[2]); 
    ybp=mxGetPr(prhs[3]); 
    FP=mxGetPr(prhs[4]); 
    diagF=mxGetPr(prhs[5]); 
    mntr = m*ntr;
    plhs[0]=mxCreateDoubleMatrix(mntr,mntr,mxREAL); 
    outData=mxGetPr(plhs[0]);  
    
    for(ci = 0; ci < m; ++ci)
    {
        for(i = ntr*ci; i < ntr*(ci+1); ++i)
        {
            for(j = ntr*ci; j < ntr*(ci+1); ++j)
            {
                // smgpCreateFormatMatrix
                pDk = mxCreateDoubleMatrix(mntr,1,mxREAL);
                dK = mxGetPr(pDk);        
                dK[i] = ybp[j];
                dK[j] = ybp[i];
                
                // dfdKmn = invS5*dK
                pDfdKmn = mxCreateDoubleMatrix(mntr,1,mxREAL);
                dfdKmn = mxGetPr(pDfdKmn);     
                for(k = 0; k < mntr; ++k)
                    for(t = 0; t < mntr; ++t)
                        dfdKmn[k] +=  invS5[t*mntr+k]*dK[t];
                
                // diagF'*dfdKmn
                nDfdf = 0;
                for(k = 0; k < mntr; ++k)
                    nDfdf += diagF[k]*dfdKmn[k];

                // 2.*trFPA(FP,dfdKmn,ntr,m)
                nTrFPA = 0;
                for(c=0; c<m; ++c)
                    for (k = 0; k < ntr; ++k)
                        nTrFPA += FP[c*ntr+k+k*mntr]*dfdKmn[c*ntr+k];
                
                // dnlK0(i, j)
                outData[j*mntr+i] = nDfdf - 2*nTrFPA;
                
                mxDestroyArray(pDk);
                mxDestroyArray(pDfdKmn);
            }
        }
    }
}
