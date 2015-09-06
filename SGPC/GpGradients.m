function [f, df] = GpGradients(logtheta, covfunc, x, A,B,C)


if ischar(covfunc), covfunc = cellstr(covfunc); end % convert to cell if needed
[D, n] = size(x);
if eval(feval(covfunc{:})) ~= size(logtheta, 1)
  disp(eval(feval(covfunc{:})));
  disp(size(logtheta, 1));
  error('Error: Number of parameters do not agree with covariance function');
end

K = feval(covfunc{:}, logtheta, x');    % compute training set covariance matrix

%iKx = inv(K);
l = chol(K,'lower');
iKx = l'\(l\eye(n));
iSigma = kron(eye(D),iKx);
L = chol(B+iSigma,'lower');     % cholesky factorization of the covariance
beta = solve_chol(L',iSigma);
% beta = transpose(L)\(L\iSigma);

f = D*sum(log(diag(l))) + sum(log(diag(L))) - transpose(C)*beta*kron(eye(D),K)*C/2+A/2;

df = zeros(size(logtheta));       % set the size of the derivative vector
temp = transpose(beta)*C*transpose(C)*beta;
for i = 1:length(df)
  alpha = kron(eye(D), feval(covfunc{:}, logtheta, x', i));  
  df(i) = sum(sum((iSigma-iSigma*beta-temp).*alpha))/2;
end

% disp('本次迭代结束!');