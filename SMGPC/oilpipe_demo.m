% Demo program for 3 classes
% ==========================


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

clear all; close all; st = fclose('all');

GPCPATH  = ['']; % this is where the GP code sits
DATAPATH = ['']; % this is the data directory

path(GPCPATH,path)			% set up the path for GP routines

% Set up the data, including a possible normalisation/scaling

data = 'oilpipe';
filename=[DATAPATH,data,'.dat'];	% this is where the data is

col = [1 0 1 0 1 0 1 0 1 0 1 0 0 0 2 2 2 0 0 ]; % which columns are attributes

% 1 indicates that the attribute is to be included
% 0 indicates that the attribute is not to be included
% 2 indicates that this attribute is a class label
% ( note: if there is more than one 2 in col, then 
%  	it is assumed that the class labels are in
%	the one-of-m class format (eg 0 1 0).
%	A single 2 denotes that the class labels
%	are integers (eg 2). )


rows_tr = [1:40];			% rows of Dataset used for training
rows_te = [41:100];			% rows of Dataset used for testing

% split the data into training and test parts
[in_all, out_all] = getmclasses(filename,col); % get dataset
x_tr_un = in_all(:,rows_tr); out_tr = out_all(:,rows_tr);
x_te_un = in_all(:,rows_te); out_te = out_all(:,rows_te);

out_trte = [out_tr out_te];

% do some scaling: inputs zero median, unit absolute deviation from median
med_xtr = median(x_tr_un');
x_tr = x_tr_un - med_xtr'*ones(1,size(x_tr_un,2));
mean_abs_dev = mean(abs(x_tr'));
x_tr = (1./mean_abs_dev'*ones(1,size(x_tr_un,2))).*x_tr;

x_te = x_te_un - med_xtr'*ones(1,size(x_te_un,2));
x_te = (1./mean_abs_dev'*ones(1,size(x_te_un,2))).*x_te;


outfile = ['oil_results'];		% results filename prefix

meth = 'ml';                % use MAP estimate only
% meth = 'ml_hmc';			% use MAP as inital w for HMC
% other options are meth = 'ml' or meth = 'hmc'

npc = length(find(col==1)) + 2;		% number of parameters per class
rand('state',0);				% set the seed
randn('state',0);

m = 3;					% number of classes
w = rand(1,m*npc);			% initial paramters

parvec = pak(m, length(rows_tr), length(rows_te)); % a vector of useful parameters

% MAP hyperparameter SCG search
options = zeros(1,18);		% Default options vector.
options(1) = 1;			% Display error values
options(14) = 10;		% Number of iterations
options(9) = 1;			% 1 => do a gradient check
 
% HMC options
hmcopt(1) = 10;			% number of retained samples
hmcopt(2) = 10;			% trajectory length
hmcopt(3) = 5;			% burn in
hmcopt(4) = 0.2;		% step size


% Set up the Gaussian hyperprior distributions for the parameters.
% For M independent classes, there are M different sets
% of covariance	parameters to specify.
% For each class, the first component is the scale
% and the last is the bias. 

% scale and bias:
for ci = 1:m
  mean_prior(ci,1) = -3;		% mean scale
  var_prior(ci,1) = 9;			% variance of scale
  mean_prior(ci,npc) = -3;		% mean bias
  var_prior(ci,npc) = 9;		% variance of bias
end

% input attribute hyperparameters:
for ci = 1:m
  mean_prior(ci,2:npc-1)  = -3.*ones(1,npc-2); 
  var_prior(ci,2:npc-1)   = 9.*ones(1,npc-2);
end

jitter = 0.01;				% stabilization of covariance

driverm(data,col,outfile,DATAPATH,x_tr,out_tr,x_te,out_te,meth,...
  options,w,hmcopt,mean_prior,var_prior,jitter)


% Prediction options when using the hyperparameter sample(s)
reject = 0;	% number of hyperparameter samples rejected when predicting
gsmp = 100;	% number of activation samples in softmax posterior average

[m, ntr, nte, ntrte] = unpak(parvec);

[ty_all,tru_all]=max(out_trte);			% correct predictions
tru = tru_all(1,ntr+1:ntrte);

% MAP: 

[meanpred_all] = final_pred([outfile,'.ml'], reject, gsmp, parvec);
[py_all,pred_all]=max(meanpred_all');		% GP predictions
pred = pred_all(1,ntr+1:ntrte);


fprintf(1,'\n\n\nMAP Results\n')
correct_pred = find(pred-tru==0);
wrong_pred = find(pred-tru);
fprintf(1,'test error rate = %f percent\n',100*length(wrong_pred)/nte)

% ARD
fprintf(1,'\nMAP hyperparameters:')
hyp_vec_all = getmat([outfile,'.ml.smp'],m*npc,0);
hyp_mat_all = vec2mitheta(hyp_vec_all,m);
fprintf(1,'\n    class1    class2    class3\n')
hyp_mat_all(:,2:npc-1)'
fprintf(1,'\n covariance scale:\n')
hyp_mat_all(:,1)'
fprintf(1,'\n covariance bias:\n')
hyp_mat_all(:,npc)'

% HMC:

[meanpred_all] = final_pred([outfile,'.vhmc'], reject, gsmp, parvec);
[py_all,pred_all]=max(meanpred_all');		% threshold the predictions
pred = pred_all(1,ntr+1:ntrte);

fprintf(1,'\nHMC Results\n')
correct_pred = find(pred-tru==0);
wrong_pred = find(pred-tru);
fprintf(1,'test error rate = %f percent\n',100*length(wrong_pred)/nte)

% ARD
hyp_vec_all = getmat([outfile,'.vhmc.smp'],m*npc*hmcopt(1),0);
hyp_mat_all = zeros(hmcopt(1),m,npc);
for i = 1:hmcopt(1)
 hyp_mat_all(i,:,:) = vec2mitheta(hyp_vec_all(1,1+(i-1)*m*npc:i*m*npc),m);
end

fprintf(1,'\nmean hyperparameters:')
fprintf(1,'\n    class1    class2    class3\n')
temp = squeeze(mean(hyp_mat_all));
temp(:,2:npc-1)'
fprintf(1,'\n covariance scale:\n')
temp(:,1)'
fprintf(1,'\n covariance bias:\n')
temp(:,npc)'

fprintf(1,'Standard deviation of the hyperparameters:')
fprintf(1,'\n    class1    class2    class\n')
temp2 = squeeze(std(hyp_mat_all));
temp2(:,2:npc-1)'
fprintf(1,'\n covariance scale:\n')
temp2(:,1)'
fprintf(1,'\n covariance bias:\n')
temp2(:,npc)'





