function [retYY, DX] = sgp1VsRestClassify( Distances,out_tr, nKnn )
%SGP1VSRESTCLASSIFY Summary of this function goes here
%   Detailed explanation goes here

nClass = length(Distances);
DX = cell(1,nClass);
[nTr, nTe] = size(Distances{1});
nTrEachClass = nTr/nClass;
retYY = zeros(nTe,1);

for i = 1:nTe
    DXi = zeros(nTr, nClass);
    for j = 1:nClass 
        DXi(:,j) = Distances{j}(:,i);
    end
    DX{i} = DXi;
            
    nShort = min(nTrEachClass, nKnn);
    [sorted, idx] = sort(DXi, 'descend');   
    yyi = zeros(nClass,2);
    for ii = 1:nClass
        yyit = out_tr(idx(1:nShort,ii));
        [yyi(ii,1), yyi(ii,2)] = mode(yyit);
    end
    indexYY = find(yyi(:,1) ~= 1);
    yyi(indexYY,2) = 0;
    retYY(i) = find(yyi(:,2) == max(yyi(:,2)), 1, 'first');
end



end

