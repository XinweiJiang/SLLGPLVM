function n2 = dist21( X, XX )
%DIST21 Summary of this function goes here
%   Detailed explanation goes here

n2 = dist2(X, XX);
[m,n] = size(n2);
if m==n
    n2 = n2-diag(diag(n2));
    n2 = n2+diag(ones(size(n2,1),1));
end

% for those values are 0, we set them to 1 to avoid the log(0) error
if length(find(n2<1e-5)) > 0
    vecN2 = n2(:);
    idx = find(vecN2 < 1e-5);
    vecN2(idx) = 1;
    n2 = reshape(vecN2, m, n);
end

end

