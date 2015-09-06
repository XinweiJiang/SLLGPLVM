function in = invAxB(AL,AU,B)

% computes inv(A)*B, given L,U decomposition of A

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


y = lufwd(AL,B);

in = luback(AU,y);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = lufwd(L,y)

n = size(y,1);
x = zeros(n,size(y,2));

x(1,:) = y(1,:)./L(1,1);

for i = 2:n
  x(i,:) = (y(i,:) - L(i,1:i-1)*x(1:i-1,:))./L(i,i);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = luback(U,y)

n = size(y,1);
x = zeros(n,size(y,2));

x(n,:) = y(n,:)./U(n,n);

for i = n-1:-1:1
  x(i,:) = (y(i,:) - U(i,i+1:n)*x(i+1:n,:))./U(i,i);
end



