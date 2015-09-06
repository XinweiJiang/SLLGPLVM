function [ hyper, w, hyperR ] = parseParam( hyper_w, model )
%PHASEPARAM Summary of this function goes here
%   Detailed explanation goes here

startVal = 1;
endVal = model.kern.length; 
hyper = reshape(hyper_w(startVal:endVal), model.kern.length, 1);
hyperR = [];
startVal = endVal+1;

switch model.gType
    case 'smcgplvm'     %For SLLGPLVM
        if isfield(model, 'trainModel') && strcmp(model.trainModel, 'seperate')
            endVal = endVal +  model.N*model.p;
            w = reshape(hyper_w(startVal:endVal), model.N, model.p);
        else
            endVal = endVal +  model.D*model.p;
            w = reshape(hyper_w(startVal:endVal), model.D, model.p);
        end
        
    case 'mgpgplvm'     %For GPGPLVM
        endVal = endVal +  model.N*model.p;
        w = reshape(hyper_w(startVal:endVal), model.N, model.p);
        
        if strcmp(model.trainModel, 'combined')           
            startVal = endVal+1;
            endVal = endVal + model.modelR.kern.nParams;
            hyperR = reshape(hyper_w(startVal:endVal), model.modelR.kern.nParams, 1);  
        end
    otherwise
        error('Unrecognized gType!');
end

