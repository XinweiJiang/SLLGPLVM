function dfdKmn0 = smgpCreateFormatMatrix( indM, indN, ybp )
%SMGPCCREATEFORMATMATRIX Summary of this function goes here
%   Detailed explanation goes here

mntr = length(ybp);
K = sparse(mntr, mntr);

K(indM, indN) = 1;
K(indN, indM) = 1;

dfdKmn0 = K*ybp;

end

