function [] = sgpPlotDataNC( ds, nKnn )
%SGPPLOTDATADC Summary of this function goes here
%   Detailed explanation goes here

if nargin == 2
    sgpReKnnNC(ds, 'Fgplvm', nKnn );
    sgpReKnnNC(ds, 'SgplvmOri', nKnn);
    sgpReKnnNC(ds, 'Sllgplvm', nKnn);
end

% sgpGetOtherResultNC( ds, 'SgplvmOri', 'Knn' );
% sgpGetOtherResultNC( ds, 'Fgplvm', 'Init' );
% plotAccRateNC(ds, sgpGetAccuracyNC( ds));

% sgpGetOtherResultNC( ds, 'SgplvmOri', 'Ori' );
% sgpGetOtherResultNC( ds, 'Fgplvm', 'Init' );
% sgpGetOtherResultNC( ds, 'Gpgplvm', 'Gpc' );
% plotAccRateNC(ds, sgpGetAccuracyNC( ds));

% sgpGetOtherResultNC( ds, 'SgplvmOri', 'Knn' );
% sgpGetOtherResultNC( ds, 'Fgplvm', 'NoInit' );
% plotAccRateNC(ds, sgpGetAccuracyNC( ds));

sgpGetOtherResultNC( ds, 'SgplvmOri', 'Ori' );
sgpGetOtherResultNC( ds, 'Fgplvm', 'NoInit' );
sgpGetOtherResultNC( ds, 'Gpgplvm', 'Knn' );
plotAccRateNC(ds, sgpGetAccuracyNC( ds));


end

