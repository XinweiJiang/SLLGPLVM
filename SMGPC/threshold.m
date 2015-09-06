function [out,flag] = threshold(inp,cutoff)

% THRESHOLD
% THRESHOLD(inp, cutoff)
% sets to cutoff any values in inp that are absolutely larger than
% cutoff
% inp is any matrix

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

t1 = size(inp,1);
t2 = size(inp,2);

t = reshape(inp,1,t1.*t2);

lplus = find(t>cutoff);
lminus = find(t<-cutoff);


if (length(lplus)>0)  | (length(lminus) >0)
  t(:,lplus) = ones(1,length(lplus)).*cutoff;
  t(:,lminus) = ones(1,length(lminus)).*cutoff;
  flag = 1;
else
  flag = 0;
end

out = reshape(t,t1,t2);
