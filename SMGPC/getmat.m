function samples = getmat(filename,m,n,skip)

% read elements from FILENAME into an MxN matrix
% if M is missing, all the file is read.

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


fidr = fopen(filename, 'r');

if nargin == 3
  skip = n;
end

if nargin == 2
  skip = 0;
end



% skip the first skip lines of the file
for i=1:skip
  chuck = fgetl(fidr);
end

if nargin == 4  
  samples = (fscanf(fidr, '%f', [n, m]))'; % get samples
else
  samples = (fscanf(fidr, '%f', [m, inf]))'; % get samples
end  

fclose(fidr);
