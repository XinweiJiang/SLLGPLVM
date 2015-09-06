function vhmc_class = vhmcm(sample_no,L,reject,ssize,w,filename,grad_fn,potential)

% VHMC   'Vanilla' Hybrid Monte Carlo
%        VHMC(SAMPLE_NO,TRAJ_LENGTH,REJECT_FIRST,STEP_SIZE,INITIAL_STATE,
%             FILENAME,GRAD_FUNCTION,POTENTIAL,TESTCHAINFLAG)
%        returns SAMPLE_NO samples (and prints to FILENAME.vhmc.smp)
%        
%        SAMPLE_NO = total number of samples, excluding rejected
%        TRAJ_LENGTH =  trajectory length
%        REJECT_FIRST = number of initial states to reject
%        STEP_SIZE = step size for dynamic update
%        INITIAL_STATE = inital chain state
%        INITIAL_STATE ='+' takes intial state from last of FILENAME.vhmc.smp
%        - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
%        FILENAME: samples stores in '<filename>.vhmc.smp'
%        Log file of sample statistics in '<filename>.vhmc.log'
%        Diagnostic of samples in '<filename>.vhmc.diag'
%        GRAD_FUNCTION: name of routine to find gradient of POTENTIAL
%        POTENTIAL: name of the potential routine
%        ------------------------------------------------------------
%
%        follow the procedure outlined in R.Neal TR CRG-TR-93-1 pg 78
% 
%        Momenta: zero mean, unit covariance gaussian samples (ie unit mass)
%        Stochastic iteration: complete replacement of momentum variables
%        Dynamic iteration: Leapfrog
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


global m makepredflag
global x_tr ntr nte x_all jitter B invSxTVEC invS4 invS5 % needed for makepred only

q = w;

fiddiag = fopen([filename '.vhmc.diag'], 'w'); % open diagnostic file

q_counter=0;				% set accepted state counter to 0
a_counter=0;				% set total number of iterations to 0
a=0;

while q_counter<sample_no+reject	% main loop

  q_counter=q_counter+1;		% update number of stored states
  p=randn(1,size(q,2));			% Replace all momenta
    
  epsilon=ssize+ssize.*randn(1).*0.1;	% Set leapfrog step size + fluctuation
  
  phat=p;					% initialise dynamic trajectory
  qhat=q;
  
  % first iteration to boot frog: 
  phat = phat-0.5.*epsilon.*feval(grad_fn,qhat);
  qhat = qhat+epsilon.*phat;
  pot_old = feval(potential,q);
  Hold=pot_old+0.5.*p*p';
  
  % frogging with full leaps
  for i=1:L-1
    phat = phat-epsilon.*feval(grad_fn,qhat);
    qhat = qhat+epsilon.*phat;
  end
  
  phat = phat-0.5.*epsilon.*feval(grad_fn,qhat); % last frog half leap

  % test this candidate state:
  if q_counter>reject;
    makepredflag =1;			% gets also invSxXVEC at candidate
  else
    makepredflag =0;
  end
    
  pot_new = feval(potential,qhat);
  Hnew=pot_new+0.5.*phat*phat'; 
  
  A=min(1, exp(-(Hnew-Hold)));		% Acceptance ratio
  a_counter=a_counter+1;			% total # iterations counter
  a(a_counter)=A;			% store acceptance levels
  fprintf(fiddiag, 'acceptance ratio(%d) = %f\n', a_counter,A); % (diagnostic)
  avA = sum(a)./a_counter;		% average acceptance ratio(diagnostic)
  fprintf(fiddiag, 'Av acc. ratio(%d) = %f\n', a_counter,avA); % (diagnostic)

  
  if rand(1) < A;				% accept the candidate?
    q=qhat;				% set the new chain state
    p=phat;
    Hold = Hnew; pot_old = pot_new;
    
    % calculate the posterior if this candidate is accepted, otherwise new posterior = old posterior
    if q_counter>reject;	
      [neweta,news] = feval('makepredm',q,x_tr,ntr,nte,x_all,m,jitter,B,invSxTVEC,invS4,invS5);
    end
    
    fprintf(fiddiag, 'accepted:');	% (diagnostics)
  else
    if q_counter == reject		% in case we do not accept the first stored example
      makepredflag =1;
      pot_dummy = feval(potential,q);
      makepredflag =0;
      [neweta,news] = feval('makepredm',q,x_tr,ntr,nte,x_all,m,jitter,B,invSxTVEC,invS4,invS5);
    end
    fprintf(fiddiag, 'REJECTED:');
  end
  
  
  if q_counter>reject;			% store samples on file
    sample(q_counter-reject,:)=q; 
    putmclass([filename '.vhmc'],neweta,news,m); % save av gp eta in file
    fprintf(fiddiag, '[stored]:\n');	% (diagnostics)
    fprintf(fiddiag, '\n');
    putnewsample(filename,q); % 	append to file    
    
  end
  % (diagnostics):
  fprintf(fiddiag, 'potential = %f\n', pot_old);
  fprintf(fiddiag, '\n--------------------\n');	% (diagnostics)
  
end					% end of main while loop

fclose(fiddiag);

putvhmclog(filename,sample,L,reject,ssize,avA);

vhmc_class=sample;				% return samples

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function putvhmclog(filename, sample,L,reject,ssize,avA)

% stores in FILNAME.vhmc.log statistics of the VHMC algorithm

fidlogw = fopen([filename '.vhmc.log'], 'w'); % open write to log file

nsamples = size(sample,1);

dsamples = size(sample,2);

fprintf(fidlogw, 'Log file for VHMC for file: %s\n',filename);
fprintf(fidlogw, 'Total number of samples in this file = %d\n', nsamples);
fprintf(fidlogw, 'Dimension of each sample = %d\n', dsamples);
fprintf(fidlogw, 'Samples in this file generated using:\n');
fprintf(fidlogw, 'Trajectory length = %d\n', L);
fprintf(fidlogw, 'Rejected first  %d samples \n', reject);
fprintf(fidlogw, 'Step size, epsilon = %d\n', ssize);
fprintf(fidlogw, 'Average acceptace ratio = %f\n', avA);

fclose(fidlogw);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function putnewsample(filename, sample)

% PUTNEWSAMPLE  
% PUTNEWSAMPLE(FILENAME, SAMPLE)
% stores in FILNAME.vhmc.smp the sample
       
fidw = fopen([filename '.vhmc.smp'], 'a'); % open to write to samples file

fprintf(fidw, '%f ', sample);		% write to samples file
fprintf(fidw, '\n');

fclose(fidw);
