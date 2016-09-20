function [resultClass, classes, distance, voteMatrix] = kNN(sampleData, testData, k, model)

% [resultClass, classes] = knn(sampleData, testData, k)
%
% Simple k-Nearest Neighbour algorithm
%
% Example   : sampledata = [1 3 1; 2 1 1; 3 2 2; 0 3 2];
%             testdata=[1 1];
%             k=3;
%             knn(sampledata,testdata,k)

N = size(sampleData,1);  % N is length of data
M = size(sampleData,2);  % M is index for class
nTest = size(testData,1);

if strcmp(model.gType, 'smcgplvm') || strcmp(model.gType, 'smclnngplvm') || strcmp(model.gType, 'smcgplvmgp') || strcmp(model.gType, 'mgpgplvm') || strcmp(model.gType, 'smctpslvm') || strcmp(model.gType, 'msaegp')
    nClass = model.M;
else
    nClass = 1;
end

if nargout > 3
    voteMatrix = zeros(nClass, nTest, nClass);
end

distance = zeros(N, nTest, nClass);

% Calculate euclidean distance for each sample
%distance = dist2(sampleData(1:N, 1:(M-1)), reshape(testData,1,M-1));
if strcmp(model.gType, 'smcgplvm') || strcmp(model.gType, 'smclnngplvm') || strcmp(model.gType, 'smcgplvmgp') || strcmp(model.gType, 'mgpgplvm') || strcmp(model.gType, 'msaegp')
    Theta = vec2mitheta(model.kern.hyper,model.M);
    o = size(Theta,2);		% 	# parameters in the covariance function
    for ci = 1:model.M
        model.kern.variance = exp(Theta(ci,1));
        model.kern.inputScales = exp(Theta(ci,2:o-1));
        model.kern.bias = exp(Theta(ci,o));

        distance(:,:,ci) = setKernCompute(model.kern, sampleData(1:N, 1:(M-1)), testData);
    end
elseif strcmp(model.gType, 'smctpslvm')
    Theta = vec2mitheta(model.kern.hyper,model.M);
    o = size(Theta,2);		% 	# parameters in the covariance function
    for ci = 1:model.M
        model.kern.bias = Theta(ci,o);

        distance(:,:,ci) = setKernCompute(model.kern, sampleData(1:N, 1:(M-1)), testData);
    end
elseif strcmp(model.gType, 'smgpgplvm') || strcmp(model.gType, 'autoencodergp')        
    distance(:,:,1) = kernCompute(model.modelL.kern, sampleData(1:N, 1:(M-1)), testData);
elseif strcmp(model.gType, 'autoencodernn')        
    distance(:,:,1) = dist2(sampleData(1:N, 1:(M-1)), testData);
else
    [distance0, distance(:,:,1)] = feval(model.kern.covfunc{:}, model.kern.hyper, sampleData(1:N, 1:(M-1)), testData);
end

nShort = min(N, k);
classes = zeros(nShort, nTest, nClass);
resultClass = zeros(nTest, nClass);
    
% Sort distances ascending
for ci = 1:nClass
    %Since RBF kernel is used, meaning the closer points have smaller value, so we have to sort distance in descending order
    [sorted, idx] = sort(distance(:,:,ci), 'descend');   

    % Order classes according to distance and
    % choose k first (nearest neighbourhood)
    for i = 1:nTest
        classes(:,i,ci) = sampleData(idx(1:nShort, i), M);

        % Result is classified in class with most neighbours
        resultClass(i,ci) = mode(classes(:,i,ci));
        
        if nargout > 3
            res = tabulate(classes(:,i,ci));
            voteMatrix(res(:,1), i, ci) = res(:,2);
        end
        %tabulate(classes(:,i));
        %pause
    end
end



% % Plot bars for classes of nearest neighbours
% figure(2);
% hist(classes,[1:max(2,max(sampleData(:,M)))]);
