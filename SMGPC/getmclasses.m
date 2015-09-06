function [in, mout]=getmclasses(filename,col,coding)

% gets classification data from a file
%
% [inputs, class]=getmclasses(filename,col,rows,coding)
%
% filename  : name of file to read
% col       : col takes the form [ 1 1 1 0 ... 1 0 2 0]
%           : 1 indicates that that column is to be used as an attribute
%           : 0 if not
%           : 2 indicates that that column is a class label
%
% coding    : redundant
%
% (If there is only a single 2 in the col variable, then an integer class
% label is assumed. Otherwise, each column with a 2 is interpreted as a
% column of the 1-of-m coding scheme.)
%

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

fid = fopen(filename, 'r');

l= length(col);
sp  = fscanf(fid, '%f ',[l,inf]);
i=1;
j=1;
k=1;
while i <= l
  if col(i)==1
    in(j,:) = sp(i,:);
    j=j+1;
  end
  if col(i)==2
    out(k,:) = sp(i,:);
    k = k + 1;
  end
  i = i + 1;
end

fclose(fid);

% now convert the output to a 1-of-m coding
m = max(out,1);		% # classes if integer coding used

if size(out,1) == 1
  if strcmp(coding,'2cl-01') ==1
    out = out + 1;
  end  
  mout = dec21ofm(out,m)';
else
  mout  = out;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function o = dec21ofm(d,m)

% takes a decimal number and converts to a 1-of-m coding scheme.
% eg. 3 -> [ 0 0 1 ], for 3 classes.
% eg. 3 -> [ 0 0 1 0 0 ] for 5 classes.

p = length(d);

o = zeros(p,m);
for i =1:p
  o(i,d(i))=1;
end


