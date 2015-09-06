function mprintf(fid,datatype,mat)

% print out the matrix mat to a file
%
% mprintf(fid,datatype,mat)
%
% fid      : file identifier
% datatype : eg '%f'
% mat      : matrix

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

format = '';
for i = 1:size(mat,2);
format = [format,datatype,' '];
end

for i = 1:size(mat,1);
  fprintf(fid,[format,'\n'],mat(i,:));
end


