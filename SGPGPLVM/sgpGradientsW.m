function gW = sgpGradientsW( model, gZ )
%SGPGRADIENTSW Summary of this function goes here
%   Detailed explanation goes here

N = model.N;
X = model.X0;
gW = zeros(size(X,2), size(gZ,2));

for i=1:N
    gW = gW + sgpOuterProduct(X(i,:), gZ(i,:));
end

end

