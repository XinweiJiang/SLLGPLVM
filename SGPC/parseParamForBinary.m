function [ hyper, z, hyperR, SV ] = parseParamForBinary( newloghyper, model )
%PHASEPARAM Summary of this function goes here
%   Detailed explanation goes here

switch model.gType        
    case 'gpgplvm'     %For GPGPLVM
        if strcmp(model.trainModel, 'combined')           
            startVal = 1;
            endVal = model.kern.length; 
            hyper = reshape(newloghyper(startVal:endVal), model.kern.length, 1);
            
            startVal = endVal+1;
            endVal = endVal +  (model.modelR.nSV+1)*model.p;
            z = reshape(newloghyper(startVal:endVal), model.modelR.nSV+1, model.p);
                       
            startVal = endVal+1;
            endVal = endVal +  model.modelR.length;            
            hyperR = reshape(newloghyper(startVal:endVal), model.modelR.length, 1);
            
            startVal = endVal+1;
            endVal = endVal +  model.modelR.nSV*model.D;            
            SV = reshape(newloghyper(startVal:endVal), model.modelR.nSV, model.D);

%             startVal = endVal+1;
%             endVal = endVal + model.N*model.p;
%             z = reshape(newloghyper(startVal:endVal), model.N, model.p);
%             
%             startVal = endVal+1;
%             endVal = endVal + model.modelR.kern.nParams;
%             hyperR = reshape(newloghyper(startVal:endVal), model.modelR.kern.nParams, 1);  
        else
            switch model.trainModelStage        % only for seperate model
                case 2
                    startVal = 1;
                    endVal = model.kern.length; 
                    hyper = reshape(newloghyper(startVal:endVal), model.kern.length, 1);

                    z = [];

                    startVal = endVal+1;
                    endVal = endVal + model.modelR.kern.nParams;
                    hyperR = reshape(newloghyper(startVal:endVal), model.modelR.kern.nParams, 1);  
                case 1
                    hyper = [];

                    startVal = 1;
                    endVal = model.N*model.p;
                    z = reshape(newloghyper(startVal:endVal), model.N, model.p);
                    
                    hyperR = [];
            end
        end
    otherwise
        error('Unrecognized gType!');
end

