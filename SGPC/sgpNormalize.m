function [ xx ] = sgpNormalize( x, varargin )
%SGPNORMALIZE Summary of this function goes here
%   Detailed explanation goes here
% 
% varargin:
%     0(default) : x-mean(x)
%     1 : min-max normalization
%     2 : z-score normalization
%     3 : std


[n, d] = size(x);
xx = zeros(n, d);
bias = mean(x);
nVar = length(varargin);

if nVar == 0 || (nVar == 1 && varargin{1} == 0)
    for i = 1:d
      xx(:, i) = x(:, i) - bias(i);
    end
elseif nVar == 1
    switch(varargin{1})
        case 1
            origBias = mean(x, 1);
            origScale = 1./sqrt(var(x, 1));
            xx = x - repmat(origBias, size(x, 1), 1);
%             testfeatures = testfeatures - repmat(origBias, size(testfeatures, 1), 1);
            xx = xx.*repmat(origScale, size(xx, 1), 1);
%             testfeatures = testfeatures.*repmat(origScale, size(testfeatures, 1), 1);
        case 2
            for i = 1:d
                minXi = min(x(:,i));
                maxXi = max(x(:,i));
                xx(:, i) = (x(:, i) - minXi)./(maxXi - minXi);
            end
        case 3
            for i = 1:d
                stdXi = std(x(:,i), 1);
                xx(:, i) = (x(:, i) - bias(i))./stdXi;
            end
        otherwise
            error('Wrong parameters for function sgpNormalize');
    end
else
    error('Wrong parameters for function sgpNormalize');
end



end

