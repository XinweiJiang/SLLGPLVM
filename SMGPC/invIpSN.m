function A = invIpSN(ntr,m,pye,B)

% find the inverse of the matrix I + Sig*N
%
% S = inv(Sig) + diag(Pi)
% N is the "noise" matrix

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

for c =1:m				% loop over the classes
% get the Pi matrix
  P = getPmat(c,pye,ntr);
% get the covariance matrix  
  BB = B(1+(c-1)*ntr:c*ntr, 1+(c-1)*ntr:c*ntr);
  IS = inv(eye(ntr)+BB*P)*BB;
  IBS = inv(eye(ntr)+BB*P);
  ISP = IS*P;
  IIS(1+(c-1)*ntr:c*ntr, 1+(c-1)*ntr:c*ntr) = IS;
  IIBS(1+(c-1)*ntr:c*ntr, 1+(c-1)*ntr:c*ntr) = IBS;
  IISP(1+(c-1)*ntr:c*ntr, 1:ntr) = ISP;  
  PP(1+(c-1)*ntr:c*ntr, 1:ntr) = P;  
end

PP = sparse(PP);
IIBS = sparse(IIBS);
IISP = sparse(IISP);

A = IIBS + IISP*inv(eye(ntr)-PP'*IISP)*(IIBS'*PP)';
  