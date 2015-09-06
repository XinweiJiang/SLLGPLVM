function nmat = getnoise_sp(yeta,m)

% set up the "noise" matrix
%
% nmat = getnoise_sp(yeta,m)

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

yeta = threshold(yeta,20);

n = length(yeta)./m;

mvecs = reshape(yeta,n,m);
a = (sum(exp(mvecs)')')*ones(1,m);
pmat = exp(mvecs)./a;

nmat = zeros(m*n,m*n);

for ci = 1:m;
  for cj = 1:ci;	
    nmat(1+(ci-1)*n:ci*n, 1+(cj-1)*n:cj*n) = -diag(pmat(:,ci).*pmat(:,cj));
    nmat(1+(cj-1)*n:cj*n, 1+(ci-1)*n:ci*n) = -diag(pmat(:,ci).*pmat(:,cj));
    if ci==cj
      nmat(1+(ci-1)*n:ci*n, 1+(cj-1)*n:cj*n) = nmat(1+(ci-1)*n:ci*n,1+(cj-1)*n:cj*n) + diag(pmat(:,ci));
    end
  end
end    

nmat = sparse(nmat);
