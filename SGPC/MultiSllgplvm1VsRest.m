function [ retAcc ] = MultiSllgplvm1VsRest( dataSetName, x, y, xx, yy, latentDim, Opt )
%MULTISLLGPLVM1VREST Summary of this function goes here
%   Detailed explanation goes here

nKnn = Opt.nKnn;
dataSetNameBin = ['1VsRestPart' dataSetName];

if (size(y,2) > 1)
    y = smgpTransformLabel( y );
    yy = smgpTransformLabel( yy );
end

nClass = length(unique(y));
[nTr,nDim] = size(x);
nTe = length(yy);

% Split data with 1-vs-rest scheme
[ X,Y,XX,YY ] = sgpSplitData( x,y,xx,yy );


% Lunch nClass BinarySllgplvm classifiers
Acc = [];
Distances = cell(1, nClass);
trTime = cputime;
for i = 1:nClass
    xi = X{i};yi = Y{i};xxi = XX{i};yyi = YY{i};
    [retZ, zz, retAcc, distance] = BinarySllgplvm(  dataSetNameBin, xi, yi, xxi, yyi, latentDim, Opt  );
    Acc = [Acc; [retAcc]];
    Distances{i} = distance;
end
trTime = cputime-trTime;

[retYY, DX] = sgp1VsRestClassify( Distances, Y{1}, nKnn);
result = retYY - yy;
res = tabulate(result)
retAcc = res(find(res(:,1)==0),3);

clear( 'X','Y','XX','YY','distance','retZ', 'zz','xi','yi','xxi','yyi');

filename = ['demSllgplvm1VsRest' dataSetName 'Tr' num2str(size(x,1)) 'Te' num2str(size(xx,1)) 'L' num2str(latentDim)];
save([filename]);

end

