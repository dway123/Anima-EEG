clear all
close all
clc

% Neural Network Classification
%   Mostly from Neural Pattern Recognition App
%   x: input data.
%   t: target output data.

inputfile = 'EricData0502.mat';

load(inputfile);

if exist('x', 'var') && exist('t', 'var')
    fprintf('using x and t from file\n');
elseif exist('x', 'var') || exist('t', 'var')
    fprintf('wtf... probably corrupted file...\n');
else
    fprintf('generating x and t from calm, left, and target\n');
    inputs = cat(1, calm, left, right)';
    calmtarget = repmat([0,1,0],size(calm,1), 1);
    lefttarget = repmat([1,0,0],size(left,1), 1);
    righttarget = repmat([0,0,1],size(right,1), 1);
    targets = cat(1, calmtarget, lefttarget, righttarget)';
    x = inputs;
    t = targets;
end

% Choose a Training Function (doc nntrain for more)
% 'trainbr' takes longer, just using for testing stuff
% 'traingd' gradient descent
% 'traingdx' gradient descent with momentum and adaptive lr
% backpropagation.
% 'trainscg' uses less memory. Suitable in low memory situations, esp for
    % large amounts of weights, said to be 'best' for classification due to
    % doing well with many weights and being fast but may overshoot easily
    % and not good for 
% 'trainlm' for regression (fastest and default, but not for classification...)
% 'trainrp' for huge datasets
trainingFunction = 'trainscg';  % Scaled conjugate gradient backpropagation.

% Create a Pattern Recognition Network
hiddenSizes = [110 80];
network = patternnet(hiddenSizes, trainingFunction);

% Choose Input and Output Pre/Post-Processing Functions
% For a list of all processing functions type: help nnprocess
network.input.processFcns = {'removeconstantrows','mapminmax'};
network.output.processFcns = {'removeconstantrows','mapminmax'};

% Setup Division of Data for Training, Validation, Testing
% For a list of all data division functions type: help nndivide
network.divideFcn = 'dividerand';  % Divide data randomly (seems better than doing so based on blocks, because subject may move during training)
network.divideMode = 'sample';  % Divide up every sample
network.divideParam.trainRatio = 70/100;
network.divideParam.valRatio = 15/100;
network.divideParam.testRatio = 15/100;

% Choose a Performance Function
network.performFcn = 'crossentropy';  % Cross-Entropy

% Choose Plot Functions (doc nnplot for all plot functions)
network.plotFcns = {'plotperform','plottrainstate','ploterrhist', 'plotconfusion', 'plotwb'};

%# of epochs lol
network.trainParam.epochs = 10000;

% Train the Network
[network,tr] = train(network,x,t);
% nntraintool('close')  % to stop seeing the tool...

% Test the Network
y = network(x);
e = gsubtract(t,y);
performance = perform(network,t,y)
tind = vec2ind(t);
yind = vec2ind(y);
percentErrors = sum(tind ~= yind)/numel(tind);

% Recalculate Training, Validation and Test Performance
trainTargets = t .* tr.trainMask{1};
valTargets = t .* tr.valMask{1};
testTargets = t .* tr.testMask{1};
trainPerformance = perform(network,trainTargets,y)
valPerformance = perform(network,valTargets,y)
testPerformance = perform(network,testTargets,y)

% Possible Plots...
%figure, plotperform(tr)
%figure, plottrainstate(tr)
%figure, ploterrhist(e)
%figure, plotconfusion(t,y)
%figure, plotroc(t,y)

% Deployment (save network for later use)
if (true)
    % Generate MATLAB function for neural network for application
    % deployment in MATLAB scripts or with MATLAB Compiler and Builder
    % tools, or simply to examine the calculations your trained neural
    % network performs.
    genFunction(network,'nnFunction2.m');
    y = nnFunction(x);
end