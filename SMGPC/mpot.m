function pot = mpot(hyper_w)

% log posterior probability (up to an additive constant)
%
% pot = mpot(vectheta)
%
% vectheta  : vector of hyperparameters

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


%fprintf(1,'\n Potential\n')
%fprintf(1,'===========\n')

% Multiple class potential for the independent
% covariance structure.

% Multiple class Gaussian Process:
% Use the following format for the covariance function:
% Sigma =     class1       class2  ..       class m
%         data1...datan  
%			  data1...datan
%					   data1...datan
% etc..
% that is, the matrix is organised such that the larger scale
% is the classes, and within each submatrix,
% is the covariance matrix between the datapoints;

global model
global ybin prob y x_all makepredflag m jitter
global invSxTVEC  yeta B invS4 invS5 sinvSxTVEC

th = 10;				% threshold values before exp
a_thresh = 100;


ntr = model.N;

switch model.gType
    case 'smcgplvm'     %For SLLGPLVM
        [ hyper, w, hyperR ] = parseParam( hyper_w, model );
        if isfield(model, 'trainModel') && strcmp(model.trainModel, 'seperate')
            x_tr = w;
        else
            x_tr = model.X*w;
        end
    case 'mgpgplvm'     %For GPGPLVM
        [ hyper, w, hyperR ] = parseParam( hyper_w, model );
        x_tr = w;
                
        if strcmp(model.trainModel, 'combined')
%             model.modelR.y = x_tr;
%             model.modelR = gpExpandParam(model.modelR, hyperR');

            optionsGP = model.modelR.options;
            model.modelR = gpCreate(size(model.X0,2), model.p, model.X0, x_tr, optionsGP);
            model.modelR.options = optionsGP;
            model.modelR = gpExpandParam(model.modelR, hyperR');
        end  
    case 'msaegp'       %For Mutil-SAEGP
        if strcmp(model.trainModel, 'combined')
            [ hyperL, hyperR, hyper, x_tr ] = parseParamForSAEGP( hyper_w, model );
            model.modelL = fgplvmExpandParam(model.modelL, [x_tr(:)' hyperL']);
            model.modelR = gpCreate(model.D, model.p, model.X0, x_tr, model.optionsR);
            model.modelR = gpExpandParam(model.modelR, hyperR');
        else
              %for seperate scheme
        end        
    otherwise
        error('Unrecognized gType!');
end


mntr = m*ntr;				% m - # classes, ntr - # datapoints

% These are the parameters for the covariance function
Theta = threshold(vec2mitheta(hyper,m),th);

% initialization of yeta and pye
noiseproc = getnoise_sp(full(yeta),m);

pye = minvg(yeta);

% set up prior covariance matrix B

B=zeros(mntr,mntr);
Bno_bias=zeros(mntr,mntr);

o = size(Theta,2);		% # parameters in the covariance function
tnp = size(Theta,1)*o;		% 	dimension of gradient vector.

% Compute Kernel Matrix

% for ci = 1:m;
%   D = zeros(ntr,ntr);
%   a = threshold(exp(Theta(ci,1)),a_thresh);
%   bias = exp(Theta(ci,o));		% bias defined by last component
% 
% %   The definition of the kernel function
% %   d = (x1-x2).^2;
% %   C(x1,x2) = scale.*exp(-0.5.*(w(1)*d(1) + w(2)*d(2) + ....) + bias
% %            + jitter.^2*delta(x1,x2)
%   for in_mcomp = 2:o-1
%     k = in_mcomp;	
%     epsi = exp(Theta(ci,k));
%     oo = ones(ntr,1); ot = ones(1,ntr);
%     xv = x_tr(k-1,:)';      
%     xxv = xv.*xv;
%     C = xxv*ot + oo*xxv'-2.*xv*xv';
%     D = D + epsi.*C;
%   end
%   [D,tflag] = threshold(D,th);
%   Bno_bias(1+(ci-1)*ntr:ci*ntr,1+(ci-1)*ntr:ci*ntr) = a.*exp(-0.5.*D);
%   B(1+(ci-1)*ntr:ci*ntr,1+(ci-1)*ntr:ci*ntr) =...
%       Bno_bias(1+(ci-1)*ntr:ci*ntr,1+(ci-1)*ntr:ci*ntr) + bias.*ones(ntr,ntr);
% end


for ci = 1:m
    model.kern.variance = exp(Theta(ci,1));
    model.kern.inputScales = exp(Theta(ci,2:o-1));
    model.kern.bias = exp(Theta(ci,o));
    
    B(1+(ci-1)*ntr:ci*ntr,1+(ci-1)*ntr:ci*ntr) = ...
        setKernCompute(model.kern, x_tr);
    Bno_bias(1+(ci-1)*ntr:ci*ntr,1+(ci-1)*ntr:ci*ntr) =...
        B(1+(ci-1)*ntr:ci*ntr,1+(ci-1)*ntr:ci*ntr) - model.kern.bias.*ones(ntr,ntr);
end


B = B + eye(mntr).*jitter.^2;  % stabilize the covariance matrix
B=sparse(B);


% find the mode.

pye = minvg(yeta);
toln = 0.00000001;

[yeta,pye,noiseproc,sinvSxTVEC,invSxTVEC]=getmode(sinvSxTVEC,yeta,ybin,toln,B,m,ntr);

mv = reshape(yeta,ntr,m);
ybp = ybin-pye;

ldS3 = ldetS3(ntr,m,pye,B);
lev = 0.5.*yeta'*(ybin+pye) -sum(log(sum(exp(mv)'))) -0.5*ldS3;
% lev = 0.5.*yeta'*(-ybp+2*ybin) -sum(log(sum(exp(mv)'))) -0.5*ldS3;

if makepredflag == 1			% global variables for makepred
  invS4 = invIpSN(ntr,m,pye,B);
  invS5 = sparse(noiseproc)*invS4;
end

pot = -lev -mlnptheta(Theta);

if strcmp(model.gType, 'mgpgplvm') && strcmp(model.trainModel, 'combined')
%     hyperR = gpExtractParam(model.modelR);
%     [f0, g0] = gpObjectiveGradient(hyperR, model.modelR);
%     pot = pot + f0;

    hyperR = gpExtractParam(model.modelR);
    [f0, g0] = gpObjectiveGradient(hyperR, model.modelR);

     %regulization for hyperparameters of GPR &/ GPC
    f1 = 0;g1 = zeros(size(g0'));
    if model.priorForGpHyper == 1
        [f1, g1] = sgpLikelihoodGradientForHyperParam(hyperR);    
    end
    f2 = 0;g2 = zeros(length(hyper), 1);
    if model.priorForGpcHyper == 1
        [f2, g2] = sgpLikelihoodGradientForHyperParam(hyper);
    end

    pot = pot + f0 + f1 + f2;
elseif strcmp(model.gType, 'msaegp') && strcmp(model.trainModel, 'combined')
    fL = - fgplvmLogLikelihood(model.modelL);
    [fR, ghR] = gpObjectiveGradient(hyperR, model.modelR);

    pot = fL + fR + pot;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ld = ldetS3(nn,m,pye,B)

% S = inv(Sig) + diag(Pi)

f = 0;
h = zeros(nn,nn);
BB = zeros(nn,nn);
for c =1:m				% loop over the classes
  P = getPmat(c,pye,nn);		
  BB = B(1+(c-1)*nn:c*nn, 1+(c-1)*nn:c*nn); % get the covariance matrix  

  A = eye(nn) + BB*P;
  [trl, AL,AU] = trlog(A);
  f = f + trl;
  if length(find(diag(AL) == 0)) ==0
    h = h + P*invAxB(AL,AU,BB)*P;  
  else
%    fprintf(1,'\nzero on diag of L\n')	% don't yet understand why this can happen
    h = h + P*(A\BB)*P;
  end
  
end

ld = f + trlog(eye(nn) - h);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function lnptheta = mlnptheta(mtheta)

% assume that the hyperprior distribution is gaussian with fixed mean and
% variance for each hyperparameter. This means that the log prob of the
% hyperprior distn is simply a scaled sum of squares.

global mean_prior var_prior

lnptheta = -0.5*sum(sum(((mtheta - mean_prior).^2)./var_prior));


