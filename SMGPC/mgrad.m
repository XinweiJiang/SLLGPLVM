function dnlHpW = mgrad(hyper_w)

% gradient of the log probability
%
% grad = mgrad(vectheta)
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

global model
global ybin x_all jitter m	% general data and cov. mat parameters
global yeta invSxTVEC sinvSxTVEC	% global to start mode search at old points
global vec_mean_prior vec_var_prior;	% these are for the hyperprior distribution

th = 10;				% threshold value before exp
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


grad = zeros(length(hyper), 1);
tr = zeros(length(hyper), 1);

%fprintf(1,'\n Gradient\n'); fprintf(1,'==========\n')

Theta = threshold(vec2mitheta(hyper,m),th);	% covariance function parameters

noiseproc = getnoise_sp(full(yeta),m);	% initalise the noise process
pye = minvg(yeta);

% set up the covariance matrix:
mntr = m*ntr;
B=zeros(mntr,mntr);
Bno_bias=zeros(mntr,mntr);
o = size(Theta,2);		% 	# parameters in the covariance function
tnp = size(Theta,1)*o;		% 	dimension of gradient vector.

% Compute Kernel Matrix

% B0=zeros(mntr,mntr);
% Bno_bias0=zeros(mntr,mntr);
% for ci = 1:m;
%   D = zeros(ntr,ntr);
%   a = threshold(exp(Theta(ci,1)),a_thresh);
%   bias = exp(Theta(ci,o));	% bias defined by last component
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
%   Bno_bias0(1+(ci-1)*ntr:ci*ntr,1+(ci-1)*ntr:ci*ntr) = a.*exp(-0.5.*D);  
%   B0(1+(ci-1)*ntr:ci*ntr,1+(ci-1)*ntr:ci*ntr) =...
%       Bno_bias0(1+(ci-1)*ntr:ci*ntr,1+(ci-1)*ntr:ci*ntr) + bias.*ones(ntr,ntr);
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

B = B + eye(mntr).*jitter.^2;		% stabilize B
B = sparse(B);

% find the mode

noiseloop=0;
%fprintf(1,'Grad Pot noiseloop: \n');
pyeold = ones(mntr,1);

pye = minvg(yeta);
dim = length(pye);
toln = 0.00000001;

[yeta,pye,noiseproc,sinvSxTVEC,invSxTVEC]=getmode(sinvSxTVEC,yeta,ybin,toln,B,m,ntr);

% (I+KW)^{-1}
invS4 = invIpSN(ntr,m,pye,B);

% (W^{-1}+K)^{-1}
invS5 = noiseproc*invS4;
% y-\pi
ybp = ybin-pye;

mpye = full(reshape(pye,ntr,m));

FB = full(Bno_bias);
SB = sparse(B);

% (K^{-1}+W)^{-1}
invS4xB = invS4*SB;			% bit expensive

% (W^{-1}+K)^{-1}
noiseprocxinvS4 = noiseproc*invS4;
Pmat = getmPmat(pye,ntr);

% (K^{-1}+W)^{-1}*\pi
FP = invS4xB*Pmat;

% dL / df
diagF = diag(invS4xB);

for cm = 1:m
  sbnoiseprocxinvS4  = noiseprocxinvS4(1+(cm-1)*ntr:cm*ntr,1+(cm-1)*ntr:cm*ntr);
  for in_mcomp = 1:o
    k = in_mcomp;	% 		which component in m
    dB = zeros(mntr,mntr);
    dnB = zeros(ntr,ntr);      
    
    if strcmp(model.kern.type,'covMulitRbfArd')
        if in_mcomp == 1
          dnB = Bno_bias(1+(cm-1)*ntr:cm*ntr,1+(cm-1)*ntr:cm*ntr);
          dB(1+(cm-1)*ntr:cm*ntr,1+(cm-1)*ntr:cm*ntr)=dnB;
        elseif in_mcomp == o;
          bias = exp(Theta(cm,o));	% 	bias defined by last component
          dnB = ones(ntr,ntr).*bias;
          dB(1+(cm-1)*ntr:cm*ntr,1+(cm-1)*ntr:cm*ntr) =dnB; 
        else      
          hw = -0.5.*exp(Theta(cm,k));
          oo = ones(ntr,1); ot = ones(1,ntr);
          xv = x_tr(:,k-1); xxv = xv.*xv;
          C = xxv*ot + oo*xxv'-2.*xv*xv';
          dnB = hw.*FB(1+(cm-1)*ntr:cm*ntr,1+(cm-1)*ntr:cm*ntr).*C;
          dB(1+(cm-1)*ntr:cm*ntr,1+(cm-1)*ntr:cm*ntr) = dnB;
        end    
    elseif strcmp(model.kern.type,'covMulitLinArd')
        if in_mcomp == 1
          dnB = Bno_bias(1+(cm-1)*ntr:cm*ntr,1+(cm-1)*ntr:cm*ntr);
          dB(1+(cm-1)*ntr:cm*ntr,1+(cm-1)*ntr:cm*ntr)=dnB;
        elseif in_mcomp == o;
          bias = exp(Theta(cm,o));	% 	bias defined by last component
          dnB = ones(ntr,ntr).*bias;
          dB(1+(cm-1)*ntr:cm*ntr,1+(cm-1)*ntr:cm*ntr) =dnB; 
        else      
          hw = -0.5.*exp(Theta(cm,k));
          oo = ones(ntr,1); ot = ones(1,ntr);
          xv = x_tr(:,k-1); xxv = xv.*xv;
          C = xxv*ot + oo*xxv'-2.*xv*xv';
          dnB = hw.*C;
          dB(1+(cm-1)*ntr:cm*ntr,1+(cm-1)*ntr:cm*ntr) = dnB;
        end  
    else
        error('unrecognized kernel!');
    end
        
    dB=sparse(dB);
    
    % Compute df/d\theta_j
    %   A = (W^{-1}+K)^{-1}*dB*(y-\pi) = W((I+KW)^{-1})*dB*(y-\pi) = W*invS4*dB*(y-\pi)
    A=invS5*(dB*ybp);
    
%     mA = full(reshape(A,ntr,m));
%     Amat = getmPmat(A,ntr);
%     dN = zeros(mntr,mntr); dN = diag(A.*(1-2*pye));
%     for ci = 1:m;
%       for cj = 1:ci;
%         if ci~=cj
%           dN(1+ntr*(ci-1):ntr*ci,1+ntr*(cj-1):ntr*cj)=-diag(mpye(:,ci).*mA(:,cj) + mpye(:,cj).*mA(:,ci));
%           dN(1+ntr*(cj-1):ntr*cj,1+ntr*(ci-1):ntr*ci)=-diag(mpye(:,ci).*mA(:,cj) + mpye(:,cj).*mA(:,ci));     
%         end
%       end
%     end  
%     dN = sparse(dN);
   
    comp = in_mcomp + (cm-1)*o;

    noiseproc = sparse(noiseproc);
    grad(comp)=ybp'*dB*ybp;

    % diagF = diag((K^{-1}+W)^{-1})
    % FP = (K^{-1}+W)^{-1}*\pi
    % A = (W^{-1}+K)^{-1}*dB*(y-\pi) = W((I+KW)^{-1})*dB*(y-\pi)
    % sbnoiseprocxinvS4 = [(W^{-1}+K)^{-1}]_m
    tr(comp)=diagF'*A - 2.*trFPA(FP,A,ntr,m)+trAB(sbnoiseprocxinvS4,dnB);
  end					% end of component loop
end

grad = 0.5.*(-grad+tr) - mgradlnptheta(hyper);






%-------- gradients w.r.t. the coefficient W for the model Z = X*W -----%

dnlK = (-ybp*ybp' + 2.*invS5 - diag(diag(invS5)))/2;
dnlK0 = zeros(mntr, mntr);

for ci = 1:m
    for i = 1+ntr*(ci-1):ntr*ci
      for j = 1+ntr*(ci-1):ntr*ci
          dfdKmn = invS5*smgpCreateFormatMatrix( i, j, ybp );
          dnlK0(i, j) = diagF'*dfdKmn - 2.*trFPA(FP,dfdKmn,ntr,m);
      end
    end
end

dnlK = dnlK + 0.5.*dnlK0;


gZ = zeros(model.N, model.p);

for ci = 1:m
    model.kern.variance = exp(Theta(ci,1));
    model.kern.inputScales = exp(Theta(ci,2:o-1));
    model.kern.bias = exp(Theta(ci,o));
    
    gKZ = setKernGradX(model.kern, x_tr, x_tr);
    gKZ = gKZ*2;
    dgKZ = setKernDiagGradX(model.kern, x_tr);
    for i = 1:ntr        
       gKZ(i, :, i) = dgKZ(i, :);
    end
    
    gK = dnlK(1+ntr*(ci-1):ntr*ci,1+ntr*(ci-1):ntr*ci);
    gZ0 = zeros(model.N, model.p);
    %%% Compute Gradients with respect to X %%%
    ind = gpDataIndices(model, 1);
    counter = 0;
    for i = ind
       counter = counter + 1;
       for j = 1:model.p
         gZ0(i, j) = gZ0(i, j) + gKZ(ind, j, i)'*gK(:, counter);
       end
    end
    
    gZ = gZ + gZ0;
end


switch model.gType
    case 'smcgplvm'     %For SLLGPLVM
        if isfield(model, 'trainModel') && strcmp(model.trainModel, 'seperate')
            dnlW = gZ;
        else
            dnlW = sgpGradientsW( model, gZ );
        end
        
        dnlHpW = [grad; dnlW(:)];
        
    case 'mgpgplvm'     %For GPGPLVM
        gZ00 = model.modelR.invK_uu*model.modelR.y;                
        gZ1= gZ+gZ00;
            
        if strcmp(model.trainModel, 'combined')
%             hyperR = gpExtractParam(model.modelR);
%             [f0, g0] = gpObjectiveGradient(hyperR, model.modelR);

            hyperR = gpExtractParam(model.modelR);
            [f0, g0] = gpObjectiveGradient(hyperR, model.modelR);

             %regulization for hyperparameters of GPR &/ GPC
            f1 = 0;g1 = zeros(size(g0'));
            if model.priorForGpHyper == 1
                [f1, g1] = sgpLikelihoodGradientForHyperParam(hyperR);    
            end
            f2 = 0;g2 = zeros(size(grad));
            if model.priorForGpcHyper == 1
                [f2, g2] = sgpLikelihoodGradientForHyperParam(hyper);
            end  

            dnlHpW = [grad+g2;gZ1(:);g0'+g1];
        else
            dnlHpW = [grad;gZ1(:)];
        end
    case 'msaegp'
       if strcmp(model.trainModel, 'combined')
            gzhL = - fgplvmLogLikeGradients(model.modelL);
            startVal = 1;
            endVal = model.N*model.p;
            gzL = reshape(gzhL(startVal:endVal), model.N, model.p);   
            startVal = endVal+1;
            endVal = endVal+model.modelL.kern.nParams; 
            ghL = reshape(gzhL(startVal:endVal), model.modelL.kern.nParams, 1);

            [fR, ghR] = gpObjectiveGradient(hyperR, model.modelR);
            gzR = model.modelR.invK_uu*model.modelR.y;       
            ghR = reshape(ghR, model.modelR.kern.nParams, 1);

            gzU = gZ;
            ghU = grad;

            gZ = gzL + gzR + gzU;

            dnlHpW = [ghL; ghR; ghU; gZ(:)];
       else
           %for seperate scheme
       end
    otherwise
        error('Unrecognized gType!');
end

if model.isTranspose == 1
    dnlHpW = dnlHpW';
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function g = mgradlnptheta(theta)

global vec_mean_prior vec_var_prior

g = -(theta-vec_mean_prior)./vec_var_prior;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function t = trFPA(FP,A,nn,m)

t=0;
for c = 1:m
  d = diag(FP(1+(c-1)*nn:c*nn,1:nn));
  fe = A(1+(c-1)*nn:c*nn,1);
  t = t + d'*fe;
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function P = getmPmat(pye,nn)

m = size(pye,1)./nn;

P = zeros(m*nn,nn);

for c = 1:m
  P(1+(c-1)*nn:c*nn,1:nn) = getPmat(c,pye,nn);
end

P = sparse(P);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function t= trAB(A,B)

A = full(A); B = full(B');

ts = size(A,1)*size(A,2);
a = reshape(A,ts,1);
b = reshape(B,ts,1);

t = a'*b;
end



