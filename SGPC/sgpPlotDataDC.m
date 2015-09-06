function [] = sgpPlotDataDC( ds, nKnn )
%SGPPLOTDATADC Summary of this function goes here
%   Detailed explanation goes here

if nargin == 2
    sgpReKnnDC(ds, 'Fgplvm', nKnn );
    sgpReKnnDC(ds, 'SgplvmOri', nKnn);
    sgpReKnnDC(ds, 'Sllgplvm', nKnn);
end

% sgpGetOtherResultDC( ds, 'Gpgplvm', 'Gpc' );
% sgpGetOtherResultDC( ds, 'SgplvmOri', 'Knn' );
% sgpGetOtherResultDC( ds, 'Fgplvm', 'Init' );
% plotAccRateDC(ds, sgpGetAccuracyDC( ds));
% 
% sgpGetOtherResultDC( ds, 'SgplvmOri', 'Ori' );
% sgpGetOtherResultDC( ds, 'Fgplvm', 'Init' );
% plotAccRateDC(ds, sgpGetAccuracyDC( ds));
% 
% sgpGetOtherResultDC( ds, 'Gpgplvm', 'Knn' );
% sgpGetOtherResultDC( ds, 'SgplvmOri', 'Knn' );
% sgpGetOtherResultDC( ds, 'Fgplvm', 'NoInit' );
% plotAccRateDC(ds, sgpGetAccuracyDC( ds));

sgpGetOtherResultDC( ds, 'Gpgplvm', 'Gpc' );
sgpGetOtherResultDC( ds, 'SgplvmOri', 'Ori' );
sgpGetOtherResultDC( ds, 'Fgplvm', 'NoInit' );
plotAccRateDC(ds, sgpGetAccuracyDC( ds));

% sgpGetOtherResultDC( ds, 'Gpgplvm', 'Gpc' );
% sgpGetOtherResultDC( ds, 'SgplvmOri', 'Ori' );
% sgpGetOtherResultDC( ds, 'Fgplvm', 'Init' );
% plotAccRateDC(ds, sgpGetAccuracyDC( ds));



end

