function Acc  = sgp1VsRestReClassify( ds ,nKnn, basedir )
%SGP1VSRESTRECLASSIFY Summary of this function goes here
%   Detailed explanation goes here
nMinus = 0;
switch ds
    case 'IonosphereNC'
        LoopArr = [20:20:200];
        nStep = 20;
        LatentDimArr = [3,5,9,11,15];
        nTeArr = 351-LoopArr;
    case 'OilNC'
        LoopArr = [30:30:300];
        nStep = 30;
%         LatentDimArr = [2,5,9];
        LatentDimArr = [1];
        nTeArr = 1000-LoopArr;
    case 'VehicleNC'
        LoopArr = [20:20:200];
        nStep = 20;
        LatentDimArr = [5,9,15];
        nTeArr = 846-LoopArr;
    case 'Usps0To4NC'
        LoopArr = [25:25:200];
        nStep = 25;
%         nMinus = 4;
        LatentDimArr = [5];
        nTeArr = 2308*ones(1,length(LoopArr));
    otherwise
        error(['unrecognized dataset name: ' ds]);
end

if nargin < 3
    basedir = ['..\Result\mat\' ds '\'];
end

if nargin < 2
    nKnn = 10;
end

Acc = [];

for iii = LatentDimArr
    for nnn = LoopArr

        matfname = [basedir 'demSllgplvm1VsRest' ds 'Tr' num2str(nnn) 'Te' num2str(nTeArr(nnn/nStep-nMinus)) 'L' num2str(iii) '.mat'];
        if exist(matfname,'file') ~= 2
            continue;
        end
        load(matfname, 'Distances', 'y', 'yy');

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
                yyit = y(idx(1:nShort,ii));
                [yyi(ii,1), yyi(ii,2)] = mode(yyit);
            end
            indexYY = find(yyi(:,1) ~= 1);
            yyi(indexYY,2) = 0;
            retYY(i) = find(yyi(:,2) == max(yyi(:,2)), 1, 'first');

%             MaxD = max(DXi(1:nTrEachClass,:),[],1);
%             retYY(i) = find(MaxD==max(MaxD));
        end
        
        result = retYY - yy;
        res = tabulate(result)
        retAcc = res(find(res(:,1)==0),3);

        Acc = [Acc; [iii size(y,1) size(yy,1) retAcc]];
        save(matfname, 'retAcc','-append');
        
        clear( 'Distances', 'y', 'yy');
    end
end

filename = ['retSllgplvm1VsRest' ds 'Accuracy' ];
save(filename, 'Acc');

end

