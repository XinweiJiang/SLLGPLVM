function hyper_w = driverm(data,col,outfile,DATAPATH,gx_tr,out_tr,x_te,out_te,meth,options,hyper_w,hmcopt,gmean_prior,gvar_prior,jitter2)

% Main driver program
% calls the SCG and/or HMC routines

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

global model N_Split Outfile
global x_tr ntr nte ybin x_all m
global ntrte jitter yeta
global mean_prior var_prior vec_mean_prior vec_var_prior
%global invS4 invS5 B invSxTVEC sinvSxTVEC

jitter = jitter2;			% so that matlab doesn't complain
x_tr = gx_tr; mean_prior = gmean_prior; var_prior = gvar_prior;

Outfile = outfile;
filename=[DATAPATH,data,'.dat'];

vec_mean_prior = mtheta2vec(mean_prior);
vec_var_prior = mtheta2vec(var_prior);

fileprefix = outfile;
potential = 'mpot';
gradpot = 'mgrad';
makeclasspred= 'makepredm';

npc = model.p +2;		% number of parameters per class

m = size(out_tr,2);			% # classes
ntr = size(x_tr,1);			% number of training points
nd = size(x_tr,2);			% number of input dimensions
nte = size(x_te,1);			% # test points
ntrte = ntr + nte;			% # train & test points
% x_all = zeros(ntr + nte, nd);
% x_all(1:ntr,:) = x_tr; x_all(ntr+1:ntrte,:) = x_te;

% targets in 1-of-m format:
mybin_trte = zeros(ntr + nte,1);
mybin_tr = out_tr;				% train targets
  
mybin_trte(1:ntr,1:m) = out_tr;			% all targets
mybin_trte(ntr+1:ntr+nte,1:m) = out_te;

% reshape the multi-class 1-of-m into augmented vectors:
ybin = augvec(mybin_tr);		% training targets

invSxTVEC = sparse(m*ntr,1); sinvSxTVEC = invSxTVEC; % global variables
yeta = zeros(m*ntr,1);


% Maximum (penalised) likelihood search
% =====================================
if (strcmp(meth,'ml') == 1) | (strcmp(meth,'ml_hmc') == 1)
  
  makepredflag = 0;			% no need for unnecessary evaluations

  if options(9)==1
    options(9) =0 ;			% don't use the scg gradient check
    fprintf(1,'Gradient Check:')
    grad_num = numgrad(hyper_w,potential)
    grad_ana = feval(gradpot,(hyper_w))
    fprintf(1,'Mean square deviation for each component = %f',...
      sqrt(mean((grad_num-grad_ana).^2)))
  end
  
  optim = str2func(model.optimiser);
  
  if strcmp(func2str(optim), 'minimize')
      % Carl Rasmussen's minimize function 
      model.isTranspose = 0;
      hyper_w = optim(hyper_w, 'smgpcLikelihoodGradients', options(14));
    else
      % SCG style optimization.
      model.isTranspose = 1;
      hyper_w = optim(potential,hyper_w',options,gradpot);
  end

%   if isfield(model, 'gType') && (strcmp(model.gType, 'gpgplvm') || strcmp(model.gType, 'mgpgplvm'))
%       fname = [outfile,'.ml'];
% 
%       [ model.kern.hyper, x0, hyperR ] = parseParam( hyper_w, model );
%       fid_w = fopen([fname,'.smp'],'w');	% store ML parameters to a file
%       mprintf(fid_w,'%f',hyper_w); fclose(fid_w);
% 
%       makepredflag = 1;
%       dummie = feval(potential,hyper_w);	% 	set global variables for makeclasspred
%       makepredflag = 0;
%       
%       x_te = x_te';x_tr = x_tr';
% 
%       if nte > N_Split
%           for i = 1:ceil(size(x_te,2)/N_Split)
%               nBeg = (i-1)*N_Split+1;
%               nEnd = i*N_Split;
%               if nEnd > size(x_te,2)
%                   nEnd = size(x_te,2);
%               end
%               x_te0 = x_te(:, nBeg:nEnd);
% 
%               nte0 = size(x_te0,2);
%               x_all0 = zeros(nd, ntr + nte0);
%               x_all0(:,1:ntr) = x_tr; 
%               x_all0(:,ntr+1:ntr+nte0) = x_te0;
%               [mlout0,mlss0] = feval(makeclasspred,model.kern.hyper,x_tr,ntr,nte0,x_all0,m,jitter,B,invSxTVEC,invS4,invS5); % make predictions
%               fname = [outfile num2str(i) '.ml'];
%               putmclass(fname,mlout0,mlss0,m);	% store the predictive gaussians
%           end
%       else
%           [mlout,mlss] = feval(makeclasspred,model.kern.hyper,x_tr,ntr,nte,x_all,m,jitter,B,invSxTVEC,invS4,invS5); % make predictions
%           putmclass(fname,mlout,mlss,m);	% store the predictive gaussians
%       end
%    end
end					% end Max Llhood


% % Hybrid Monte Carlo Markov Chain Sampling
% % ========================================
% if (strcmp(meth,'hmc') == 1) | (strcmp(meth,'ml_hmc') == 1)  
%   fprintf(1,'\nHMC Sampling....please wait\n\n')
%   no_samples = hmcopt(1);
%   traj_length = hmcopt(2);
%   burn_in = hmcopt(3);
%   step_size = hmcopt(4);
%   
%   samples=vhmcm(no_samples,traj_length,burn_in,step_size,w,...
%     fileprefix,gradpot,potential);
%   
% end
      
      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function v = mtheta2vec(mtheta)

% convert the matrix repn of theta to a vector:
% 0 -2 -2 -2 -2
% 0 -2 -2 -2 -2
% 0 -2 -2 -2 -2
% goes to
% 0 -2 -2 -2 -2 0 -2 -2 -2 -2 0 -2 -2 -2 -2

global m 

s = size(mtheta,1)*size(mtheta,2);
v = reshape(mtheta',s,1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function deltaf = numgrad(x,fn)

% numerical gradient

nparams = length(x);

epsilon = 1.0e-3;
xorig = x;
deltaf = zeros(size(x));
for i = 1:nparams
  x(i) = xorig(i) + epsilon;
  fplus = feval(fn,x);
  x(i) = xorig(i) - epsilon;
  fminus = feval(fn,x);
  deltaf(i) = 0.5*(fplus - fminus)/epsilon;
  x(i) = xorig(i);
end






