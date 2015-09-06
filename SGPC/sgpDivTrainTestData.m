function [ x_tr,y_tr,x_te,y_te ] = sgpDivTrainTestData( x, y, nTr, nTe, xx, yy )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% Input:
%   x : all X
%   y : all Y with 1-of-m encode scheme labels or +1/-1 scheme
%   nTr : number of training samples
%   nTe : number of testing samples
%   x : all test data xx
%   y : all test data yy with 1-of-m encode scheme labels or +1/-1 scheme
% Output
%   x_tr : training X
%   y_tr : training Y
%   x_te: testing X
%   y_te: trsting Y


x_tr = [];y_tr = [];x_te = []; y_te = [];
nClass = size(y,2);

if nargin == 4
    if nClass == 1
    %     U = sort(unique(y), 'descend');
        U = sort(unique(y));
        nClass = length(U);
        nNumofEachClass = zeros(nClass,1);
        for ci = 1:nClass
            nNumofEachClass(ci) = length(find(y == U(ci)));
        end
    else
        nNumofEachClass = sum(y);
    end

    nIndexofEachClass = ones(nClass,1);
    for ci = 2:nClass
        nIndexofEachClass(ci) = nIndexofEachClass(ci-1)+nNumofEachClass(ci-1);
    end

    nTr0 = nTr;
    nTe0 = nTe;
    for ci=1:nClass
        nTr = nTr0;
        nTe = nTe0;
        if nTr > nNumofEachClass(ci)
            warning('too many training samples leads to no testing data!');
            nTr = nNumofEachClass(ci);
        end
        if nTe > nNumofEachClass(ci)-nTr
            nTe = nNumofEachClass(ci)-nTr;
        end

        x_tr = [x_tr;x(nIndexofEachClass(ci):nIndexofEachClass(ci)+nTr-1,:)];
        y_tr = [y_tr;y(nIndexofEachClass(ci):nIndexofEachClass(ci)+nTr-1,:)];

        if nargin == 4
            if nTe < 1
                warning('no testing data, use training data as testing data!');
                x_te = [x_te;x(nIndexofEachClass(ci):nIndexofEachClass(ci)+nTr-1,:)];
                y_te = [y_te;y(nIndexofEachClass(ci):nIndexofEachClass(ci)+nTr-1,:)];
            else
                x_te = [x_te;x(nIndexofEachClass(ci)+nTr:nIndexofEachClass(ci)+nTr+nTe-1,:)];
                y_te = [y_te;y(nIndexofEachClass(ci)+nTr:nIndexofEachClass(ci)+nTr+nTe-1,:)];
            end
        end
    end
end

% if there exists test data xx and yy, then the output test data x_te and
% y_te will be extracted from xx and yy. if nTe is less than 1, x_te = x, y_te = yy 
if nargin == 6
    nClass = size(yy,2);
    
    if nTe < 1
        x_te = xx;
        y_te = yy;
    else
        if nClass == 1
%             U = sort(unique(yy), 'descend');
            U = sort(unique(yy));
            nClass = length(U);
            nNumofEachClass = zeros(nClass,1);
            for ci = 1:nClass
                nNumofEachClass(ci) = length(find(yy == U(ci)));
            end
        else
            nNumofEachClass = sum(yy);
        end

        nIndexofEachClass = ones(nClass,1);
        for ci = 2:nClass
            nIndexofEachClass(ci) = nIndexofEachClass(ci-1)+nNumofEachClass(ci-1);
        end

        nTe0 = nTe;
        for ci=1:nClass
            nTe = nTe0;
            if nTe > nNumofEachClass(ci)
                nTe = nNumofEachClass(ci);
            end

            if nTe > 1
                x_te = [x_te;xx(nIndexofEachClass(ci):nIndexofEachClass(ci)+nTe-1,:)];
                y_te = [y_te;yy(nIndexofEachClass(ci):nIndexofEachClass(ci)+nTe-1,:)];
            end
        end
    end
end

fprintf('Training Data: %d; Testing Data: %d\n',size(y_tr,1), size(y_te,1));
fprintf('----------------------------------------------------------\n');

end

