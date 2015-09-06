function [mean_pred] = final_pred(filename, reject, gsmp, parvec)

% calculate the final predictions of the mean of the softmax
% 
% [mean_pred] = final_pred(filename, reject, gsmp, parvec)
%
% filename : prefix of files that store the means and covariances
% reject   : number of initial accepted samples to be rejected
% gsmp     : number of samples in the Gaussian Softmax average
% parvec   : description vector

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

% [m ntr nte ntrte] = unpak(parvec);
% 
% fidm= fopen([filename '.eta'], 'r');  % stored means
% fidv = fopen([filename,'.var'], 'r'); % stored covariance matrices
% 
% % Calculate the average outputs over the samples
% 
% av = zeros(ntrte,m);
% means = fscanf(fidm,'%f', [m*ntrte,inf]);    % matrix of the GP eta predictions
% t = size(means,2);			% number of theta values.
% 
% for i=1+reject:t
%   % loop over the MCMC points
%   % get the mean of the gaussian:
%   mvecs = deaugyout(means(:,i),m,ntr,nte);	% de-augment the vector
% 
%   for n = 1:ntrte;				% loop over the datapoints
% %    fprintf(1,'Hyperparameter sample = %d, datapoint = %d\n',i,n)
%     % get the mean and covarince matrix for each datapoint.  
%     mvec = mvecs(n,:);
%     covmat = fscanf(fidv,'%f',[m,m]);
%     av(n,:) = av(n,:) + msigint(mvec',covmat,gsmp)';
%   end
% end

global N_Split Outfile

[m ntr nte ntrte] = unpak(parvec);

if nte > N_Split
    av = [];
    for j = 1:ceil(nte/N_Split)
        fname = [Outfile num2str(j) '.ml'];
        fidm= fopen([fname '.eta'], 'r');  % stored means
        fidv = fopen([fname,'.var'], 'r'); % stored covariance matrices

        % Calculate the average outputs over the samples
        nBeg = (j-1)*N_Split+1;
        nEnd = j*N_Split;
        if nEnd > nte
            nEnd = nte;
        end
        nte0 = nEnd-nBeg+1;
        ntrte0 = nte0+ntr;
        av0 = zeros(ntrte0,m);
        means = fscanf(fidm,'%f', [m*ntrte0,inf]);    % matrix of the GP eta predictions
        t = size(means,2);			% number of theta values.

        for i=1+reject:t
          % loop over the MCMC points
          % get the mean of the gaussian:
          mvecs = deaugyout(means(:,i),m,ntr,nte0);	% de-augment the vector

          for n = 1:ntrte0;				% loop over the datapoints
        %    fprintf(1,'Hyperparameter sample = %d, datapoint = %d\n',i,n)
            % get the mean and covarince matrix for each datapoint.  
            mvec = mvecs(n,:);
            covmat = fscanf(fidv,'%f',[m,m]);
            av0(n,:) = av0(n,:) + msigint(mvec',covmat,gsmp)';
          end
        end
        
        if j ~= 1
            av0 = av0(ntr+1:size(av0,1), :);
        end

        av = [av; av0];
        fclose(fidm);
        fclose(fidv);
        delete([fname '.eta'], [fname,'.var']);
    end
    delete([filename '.smp']);
else
    fidm= fopen([filename '.eta'], 'r');  % stored means
    fidv = fopen([filename,'.var'], 'r'); % stored covariance matrices

    % Calculate the average outputs over the samples

    av = zeros(ntrte,m);
    means = fscanf(fidm,'%f', [m*ntrte,inf]);    % matrix of the GP eta predictions
    t = size(means,2);			% number of theta values.

    for i=1+reject:t
      % loop over the MCMC points
      % get the mean of the gaussian:
      mvecs = deaugyout(means(:,i),m,ntr,nte);	% de-augment the vector

      for n = 1:ntrte;				% loop over the datapoints
    %    fprintf(1,'Hyperparameter sample = %d, datapoint = %d\n',i,n)
        % get the mean and covarince matrix for each datapoint.  
        mvec = mvecs(n,:);
        covmat = fscanf(fidv,'%f',[m,m]);
        av(n,:) = av(n,:) + msigint(mvec',covmat,gsmp)';
      end
    end

    fclose(fidm);
    fclose(fidv);
end

mean_pred = av./(t-reject);		% prediction after mean pi space

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function s  = msigint(m,C,gsmp)

% m is the mean vector, C the covariance matrix. This routine calculates the
% integral over a gaussian of a softmax function by sampling methods.

av = zeros(size(m,1),size(m,2));
for j = 1:gsmp
  y = mdgauss_smp(m,C);			% get a sample from the gaussian
  av = av + softmax(y);
end

s = av./gsmp;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function s  = softmax(y,i)

% returns the vector of softmax values, with components y(i)/sum(y(j))

s = exp(y)./sum(exp(y));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function d = deaugyout(vec,m,ntr,nte)

% global # classes and # training and test points

% augmented yeta vectors are stored in the form
% class1:train_points, class2:train_points, class1:test, class2:test ....
% want to return this in the form

% class1:train, class2:train
% class1:test , class2:test

d = zeros(ntr+nte,m);

trainbit = vec(1:m*ntr);
testbit = vec(m*ntr+1:length(vec));

d(1:ntr,:) = reshape(trainbit,ntr,m);
d(ntr+1:ntr+nte,:) = reshape(testbit,nte,m);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s=mdgauss_smp(mean,S)

% S is the covariance matrix

A = jitChol(S)';

n=length(mean);

if size(mean,2)>size(mean,1)
  mean = mean';
end

z=randn(n,1);

s=mean+A*z;
