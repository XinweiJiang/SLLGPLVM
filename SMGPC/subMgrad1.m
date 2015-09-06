function [dnlK0] = subMgrad1(m, ntr, invS5, ybp, FP, diagF)
 
mntr = m*ntr;
dnlK0 = zeros(mntr, mntr);

 for ci = 1:m
     for i = 1+ntr*(ci-1):ntr*ci
      for j = 1+ntr*(ci-1):ntr*ci
          if ci == m && i == ntr*m && j == ntr*m
              sprintf('hello');
          end
          temp = smgpCreateFormatMatrix( i, j, ybp );
          dfdKmn = invS5*temp;
          dnlK0(i, j) = diagF'*dfdKmn - 2.*trFPA(FP,dfdKmn,ntr,m);
      end
    end
 end
end

