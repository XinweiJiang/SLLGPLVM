function [x, options, errlog, pointlog, scalelog] = scg(f, x, options, gradf, varargin)
%SCG	Scaled conjugate gradient optimization.
%
%	Description
%	[X, OPTIONS] = SCG(F, X, OPTIONS, GRADF) uses a scaled conjugate
%	gradients algorithm to find a local minimum of the function F(X)
%	whose gradient is given by GRADF(X).  Here X is a row vector and F
%	returns a scalar value. The point at which F has a local minimum is
%	returned as X.  The function value at that point is returned in
%	OPTIONS(8).
%
%	[X, OPTIONS, ERRLOG, POINTLOG, SCALELOG] = SCG(F, X, OPTIONS, GRADF)
%	also returns (optionally) a log of the error values after each cycle
%	in ERRLOG, a log of the points visited in POINTLOG, and a log of the
%	scale values in the algorithm in SCALELOG.
%
%	SCG(F, X, OPTIONS, GRADF, P1, P2, ...) allows additional arguments to
%	be passed to F() and GRADF().     The optional parameters have the
%	following interpretations.
%
%	OPTIONS(1) is set to 1 to display error values; also logs error
%	values in the return argument ERRLOG, and the points visited in the
%	return argument POINTSLOG.  If OPTIONS(1) is set to 0, then only
%	warning messages are displayed.  If OPTIONS(1) is -1, then nothing is
%	displayed.
%
%	OPTIONS(2) is a measure of the absolute precision required for the
%	value of X at the solution.  If the absolute difference between the
%	values of X between two successive steps is less than OPTIONS(2),
%	then this condition is satisfied.
%
%	OPTIONS(3) is a measure of the precision required of the objective
%	function at the solution.  If the absolute difference between the
%	objective function values between two successive steps is less than
%	OPTIONS(3), then this condition is satisfied. Both this and the
%	previous condition must be satisfied for termination.
%
%	OPTIONS(9) is set to 1 to check the user defined gradient function.
%
%	OPTIONS(10) returns the total number of function evaluations
%	(including those in any line searches).
%
%	OPTIONS(11) returns the total number of gradient evaluations.
%
%	OPTIONS(14) is the maximum number of iterations; default 100.
%
%	See also
%	CONJGRAD, QUASINEW
%

%	Copyright (c) Christopher M Bishop, Ian T Nabney (1996, 1997)

%       This code forms part of the Netlab library, available from 
%       http://www.ncrg.aston.ac.uk/ 

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


%  Set up the options.
if length(options) < 18
  error('Options vector too short')
end

if(options(14))
  niters = options(14);
else
  niters = 100;
end

display = options(1);
gradcheck = options(9);

% Set up strings for evaluating function and gradient
f = fcnchk(f, length(varargin));
gradf = fcnchk(gradf, length(varargin));

nparams = length(x);

%  Check gradients
if (gradcheck)
  feval('gradchek', x, f, gradf, varargin{:});
end

sigma0 = 1.0e-4;
fold = feval(f, x, varargin{:});	% Initial function value.
options(10) = options(10) + 1;		% Increment function evaluation counter.
grad = feval(gradf, x, varargin{:});	% Initial gradient.
options(11) = options(11) + 1;		% Increment gradient evaluation counter.
srch = - grad;				% Initial search direction.
success = 1;
lambda = 1.0;				% Initial scale parameter.
lambdamin = 1.0e-15; 
lambdamax = 1.0e100;
n = 1;					% n counts number of iterations.
nsuccess = 0;				% nsuccess counts number of successes.
xval = x;

% Main optimization loop.
while (n <= niters)

  % Calculate first and second directional derivatives.
  if (success == 1)
    mu = srch*grad';
    if (mu >= 0)
      srch = - grad;
      mu = srch*grad';
    end
    kappa = srch*srch';
    sigma = sigma0/sqrt(kappa);
    x = xval + sigma*srch;
    gplus = feval(gradf, x, varargin{:});
    options(11) = options(11) + 1; 
    gamma = (srch*(gplus' - grad'))/sigma;
  end

  % Increase effective curvature and evaluate step size alpha.
  delta = gamma + lambda*kappa;
  if (delta <= 0) 
    delta = lambda*kappa;
    lambda = lambda - gamma/kappa;
  end
  alpha = - mu/delta;
  
  % Calculate the comparison ratio.
  x = xval + alpha*srch;
  fnew = feval(f, x, varargin{:});
  options(10) = options(10) + 1;
  rho = 2*(fnew - fold)/(alpha*mu);
  if (rho  >= 0)
    success = 1;
  else
    success = 0;
  end

  % Update the parameters to new location.
  if (success == 1)
    xval = xval + alpha*srch;
    nsuccess = nsuccess + 1;
    fnow = fnew;
  else
    fnow = fold;
  end
  x = xval;

  if nargout >= 3
    % Store relevant variables
    errlog(n) = fnow;		% Current function value
    if nargout >= 4
      pointlog(n,:) = x;	% Current position
      if nargout >= 5
	scalelog(n) = lambda;	% Current scale parameter
      end
    end
  end    
  if display > 0
    fprintf(1, 'Cycle %4d  Error %11.6f  Scale %e\n', n, fold, lambda);
  end

  if (success == 1)
    % Test for termination

    if (max(abs(alpha*srch)) < options(2) & max(abs(fnew-fold)) < options(3))
      options(8) = fnew;
      return;

    else
      % Update variables for new position
      fold = fnew;
      gold = grad;
      grad = feval(gradf, x, varargin{:});
      options(11) = options(11) + 1;
    end
  end

  % Adjust lambda according to comparison ratio.

  if (rho < 0.25)
    lambda = 4.0*lambda;
    if (lambda > lambdamax)
      lambda = lambdamax;
    end
  end
  if (rho > 0.75)
    lambda = 0.5*lambda;
    if (lambda < lambdamin)
      lambda = lambdamin;
    end
  end

  % Re-compute search direction using Hestenes-Steifel formula, or re-start 
  % in direction of negative gradient after nparams steps.

  if (nsuccess == nparams)
    srch = -grad;
    nsuccess = 0;
  else
    if (success == 1)
      beta = (gold - grad)*grad'/mu;
      srch = - grad + beta*srch;
    end
  end
  n = n + 1;
end

% If we get here, then we haven't terminated in the given number of 
% iterations.

options(8) = fold;
if (options(1) >= 0)
  disp('Warning: Maximum number of iterations has been exceeded');
end

