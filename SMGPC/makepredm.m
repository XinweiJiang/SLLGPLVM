function [yout, SS] = makepredm(vectheta,x_tr,ntr,nte,x_all,m,jitter,B,invSxTVEC,invS4,invS5)

% find the mean and covariace matrix of the Gaussian 
% for the predictive activations

%            Matlab code for Gaussian Processes for Classification:
%                      GPCLASS version 0.2  10 Nov 97
%       Copyright (c) David Barber and Christopher K I Williams (1997)

%    This program is free software; you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation; either version 2 of the License, or
%    any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program; if not, write to the Free Software
%    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

global model

ntot = ntr + nte;

th = 100;				% threshold value before exp
a_thresh = 100;

Theta = threshold(vec2mitheta(vectheta,m),th);

Q = zeros(m*ntr,m*nte);
Shat = zeros(m*nte,m*nte);
K = zeros(m*(ntr+nte),m*ntr);
NQ = zeros(m*ntr,m*nte);
NShat = zeros(m*nte,m*nte);

o = size(Theta,2);		% # parameters in the covariance function
tnp = size(Theta,1)*o;		% 	dimension of gradient vector.

for ci = 1:m;
  % get the right covariance parameters for these classes:
  hw = -0.5.*exp(Theta(ci,2:size(Theta,2)-1));
  a = threshold(exp(Theta(ci,1)),a_thresh);
  bias = exp(Theta(ci,o));
  
  D = zeros(ntot,ntot);
  if strcmp(model.kern.type,'covMulitRbfArd')
      for in_mcomp = 2:o-1
        k = in_mcomp;	
        epsi = exp(Theta(ci,k));
        oo = ones(ntot,1); ot = ones(1,ntot);
        xv = x_all(k-1,:)';      
        xxv = xv.*xv;
        C = xxv*ot + oo*xxv'-2.*xv*xv';
        D = D + epsi.*C;    
      end
      [D,tflag] = threshold(D,th);
      BBB = a.*exp(-0.5.*D) + ones(ntot,ntot).*bias + eye(ntot).*jitter.^2;
  elseif strcmp(model.kern.type,'covMulitLinArd')
      for in_mcomp = 2:o-1
        k = in_mcomp;	
        epsi = exp(Theta(ci,k));
        oo = ones(ntot,1); ot = ones(1,ntot);
        xv = x_all(k-1,:)';      
        xxv = xv.*xv;
        C = xxv*ot + oo*xxv'-2.*xv*xv';
        D = D + epsi.*C;    
      end
      [D,tflag] = threshold(D,th);
      BBB = a.*D + ones(ntot,ntot).*bias + eye(ntot).*jitter.^2;
  end
  QQ = BBB(1:ntr,ntr+1:ntot);
  SShat = BBB(ntr+1:ntot,ntr+1:ntot);
  
  for i = 1:nte
    for j = 1:ntr
      x=x_all(:,ntr+i)-x_tr(:,j);  xx=x.*x;
      qji = a * exp(hw*xx);
     
      Q(j+(ci-1)*ntr,i+(ci-1)*nte) = qji;
    end
    for j = 1:i	
      x=x_all(:,ntr+i)-x_all(:,ntr+j); xx=x.*x;
      Shatij = a * exp(hw*xx);
      Shat(i+(ci-1)*nte,j+(ci-1)*nte) = Shatij;
      Shat(j+(ci-1)*nte,i+(ci-1)*nte) = Shatij;
    end
  end
  NShat(1+(ci-1)*nte:ci*nte,1+(ci-1)*nte:ci*nte) = SShat;
  NQ(1+(ci-1)*ntr:ci*ntr,1+(ci-1)*nte:ci*nte) = QQ;
end					% end of class loop

K(1:m*ntr,:)=B;				% B is global from mclasspot
K(m*ntr+1:m*(ntr+nte),:)=Q';		% don't need to redfine this bit of K


NK = zeros(m*ntot,m*ntr);
NK(1:m*ntr,:)=B;			% B is global from mclasspot
NK(m*ntr+1:m*(ntr+nte),:)=NQ';		% don't need to redfine this bit of NK

AA = invS4*B;
BB = invS4*Q;
CC = Shat - Q'*invS5*Q;

K = sparse(K);
yout = K * invSxTVEC;
yout = full(yout);

SS = zeros(ntot,ntot);
SS(1:m*ntr,1:m*ntr) = AA;

SS(1:m*ntr,m*ntr+1:m*ntot) = BB;
SS(m*ntr+1:m*ntot,1:m*ntr) = BB';
SS(m*ntr+1:m*ntot,m*ntr+1:m*ntot) = CC;

%%% (actually, we only need to return the diagonals of the submatrices)
% 
% if length(find(eig(SS)<0))>0
%   disp('found some negative eigenvalues of the covariance matrix !!')
%   keyboard
% end
