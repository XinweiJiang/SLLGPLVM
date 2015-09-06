function putmclass(filename, vec, S, m)

% Stores in FILNAME.eta the values of the averages of the  multiclass
% variables, and in FILENAME.var, the covariance elements
% of the class labels. It is arranged so that we first store the mean and
% covariance values for the first example, then the second, etc.
%
% putmclass(filename, vec, S, m)

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


fidweta = fopen([filename,'.eta'], 'a'); % open to write to samples file
fidwvar = fopen([filename,'.var'], 'a'); % open to write to samples file

% first write the mean values:
n = length(vec)./m;			% # of data points

fprintf(fidweta, '%f ', vec);         % write to samples file
fprintf(fidweta, '\n');

% now do the covariance matrices:
% need to extract the relevant submatrices from S:

a = zeros(m,m);				% initialise the covariance matrix

for nn=1:n;				% loop over the datapoints
  for ci=1:m;
    for cj =1:ci;			% loop over the classes
      a(ci,cj) = S(nn + (ci-1)*m, nn + (cj-1)*m);
      a(cj,ci) = a(ci,cj);		% symmetrize
    end
  end    
  fprintf(fidwvar, '%f ', a);		% write to samples file
  
  if length(find(eig(a)<0))>0
    disp('found some negative eigenvalues of the covariance matrix !!')
    keyboard
  end
    
  fprintf(fidwvar, '\n');
end

fclose(fidweta);
fclose(fidwvar);


























