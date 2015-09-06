function [yeta, pye, noiseproc, sinvSxTVEC, invSxTVEC] = getmode(sinvSxTVEC, yeta, ybin, toln,B,m,nn)

% finds the mode of the posterior distribution
%
% [yeta, pye, noiseproc, sinvSxTVEC, invSxTVEC] = getmode(sinvSxTVEC, yeta, ybin, toln,B,m,nn)
%
% sinvSxTVEC    : initial starting point for solution of linear system
% yeta          : initial guess for mode of posterior
% ybin          : training outputs
% toln          : accuracy of mode finding routine
% B             : covariance matrix
% m             : number of classes
% nn            : number of training points
            
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

% W
noiseproc = getnoise_sp(full(yeta),m);

mnn = m*nn;
pyeold = 10.*ones(mnn,1);

%fprintf(1,'Pot noiseloop: ');
noiseloop=0;

% find the mode of the distribution with exponent Psi:
gg = 1;
cgtol = toln./10;

sp_ybin = sparse(ybin);
et_v = zeros(length(sp_ybin),1);

pye = minvg(yeta);

% conjugate gradient methods seem the fastest,

while  (   (mean(abs(pye - pyeold)) > toln) |  (~(noiseloop>1) &...
    ~(mean(abs(pye - pyeold)) > toln) ) )
  
  noiseloop = noiseloop+1;  
%  fprintf(1,'%d ',noiseloop); 
  pyeold=pye; yetaold = yeta; noiseprocold = noiseproc; sinvSxTVECold = sinvSxTVEC;
 
  % the right part of Equation (19): (Wy+(t-\pi))
  b = noiseproc*yeta + ybin - pye; 
  S3 = eye(size(B,2))+noiseproc*B;

  % (I+noiseprec*B)*invSxTVEC = b;
  
  % compute (I+WK)^{-1}(Wy+(t-\pi))
%   [invSxTVEC1, err, its]=pbcg_quad2(b,sinvSxTVEC,50,cgtol,0,B,noiseproc); % noiseproc  

  invSxTVEC = S3\b;
%   invSxTVEC = pinv(S3)*b;
  sinvSxTVEC = invSxTVEC;
%   if its <= 1
%     cgtol = cgtol./10;
%   end  

  % compute equation (19)
  yeta = B*invSxTVEC;
  
%  [yeta,flag] = threshold(yeta,20);	% threshold large entries in eta
  
  pye = minvg(yeta);
  noiseproc = getnoise_sp(full(yeta),m);
  g = -yeta + B*(ybin - pye); gg = g'*g;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [x, err, iter] = pbcg_quad2(b,x,itmax,tol,out,B,noiseproc)

% x = pbcg(A,b,x,itmax,tol,out,B,noiseproc)
% ----------------------------
% Preconditioned Biconjugate Gradient method
% solves linear system Ax = b for general A
% ------------------------------------------
% x : initial guess
% itmax : max # iterations
% iterates while mean(abs(Ax-b)) > tol
% outputs iterative error if out=1
%
% Simplified form of Numerical Recipes: linbcg
% 
% The preconditioned matrix is set to inv(diag(A))

% A defined through A = I + N*B

diagA = ones(size(B,1),1) + (sum(noiseproc.*B))'; % diags of A

cont = 0;
iter = 0;
r = Amul2(x,B,noiseproc);
r = b-r;
rr = r;

znrm = 1;

bnrm = norm(b);
z = r./diagA;

err = norm(Amul2(x,B,noiseproc) - b)./norm(b);

while iter <= itmax
  iter = iter + 1;
  zm1nrm = znrm;
  zz = rr./diagA;
  bknum= z'*rr;
  if iter ==1
    p = z;
    pp = zz;
  else
    bk = bknum./bkden;
    p = bk.*p + z;
    pp = bk.*pp + zz;
  end
  
  bkden = bknum;
  z = Amul2(p,B,noiseproc);
  akden = z'*pp;
  ak = bknum./akden;
  zz = Amul2T(pp,B,noiseproc);
  
  x = x + ak.*p;
  r = r - ak.*z;
  rr = rr - ak.*zz;
  
  z = r./diagA;
  znrm = 1;

  err = mean(abs(r));
%  err = norm(r)./bnrm;
  
  if out == 1
    fprintf(1,'\n iter = %d, err = %f',iter,err)
  end
  
  if err<tol
    break
  end    

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function am = Amul2(d,B,noiseproc)

% performs quickly the matrix vector operation
% (I + N*B)d
% where B is the covariance natrix, and N is the noiseproc matrix.

ee = B*d;

am = d + noiseproc*ee;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function am = Amul2T(d,B,noiseproc)

% performs quickly the matrix vector operation
% (I + B*N)d
% where B is the covariance natrix, and N is the noiseproc matrix.

ee = noiseproc*d;

am = d + B*ee;

