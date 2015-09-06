function []  = sgp1VsRestReName( ds , basedir )
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

if nargin < 2
    basedir = ['..\Result\mat\' ds '\'];
end


for iii = LatentDimArr
    for nnn = LoopArr

        matfname = [basedir 'demSllgplvm1VsRest' ds 'Tr' num2str(nnn) 'Te' num2str(nTeArr(nnn/nStep-nMinus)) 'L' num2str(iii) '.mat'];
        if exist(matfname,'file') ~= 2
            continue;
        end
        load(matfname);
        retYY = yy;x = x_tr;y = out_tr;xx = x_te;yy = out_te;
        clear( 'x_tr', 'out_tr', 'x_te', 'out_te');
        save(matfname);
    end
end

end

