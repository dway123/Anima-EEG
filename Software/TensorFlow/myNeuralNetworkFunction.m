function [Y,Xf,Af] = myNeuralNetworkFunction(X,~,~)
%MYNEURALNETWORKFUNCTION neural network simulation function.
%
% Generated by Neural Network Toolbox function genFunction, 09-Apr-2017 20:19:06.
%
% [Y] = myNeuralNetworkFunction(X,~,~) takes these arguments:
%
%   X = 1xTS cell, 1 inputs over TS timesteps
%   Each X{1,ts} = 9xQ matrix, input #1 at timestep ts.
%
% and returns:
%   Y = 1xTS cell of 1 outputs over TS timesteps.
%   Each Y{1,ts} = 2xQ matrix, output #1 at timestep ts.
%
% where Q is number of samples (or series) and TS is the number of timesteps.

%#ok<*RPMT0>

% ===== NEURAL NETWORK CONSTANTS =====

% Input 1
x1_step1.xoffset = [0.1;0.1;0.1;0.1;0.1;0.1;0.1;0.1;0.1];
x1_step1.gain = [2.22222222222222;2.22222222222222;2.22222222222222;2.22222222222222;2.22222222222222;2.22222222222222;2.22222222222222;2.22222222222222;2.22222222222222];
x1_step1.ymin = -1;

% Layer 1
b1 = [-1.6958002101717535;2.2561777317593128;-1.483617378402897;-0.52395534117203368;0.16380599917978492;0.20412150608711857;-0.57516862153326531;-0.93913192531031009;1.4832932765236491;1.8338555844345976];
IW1_1 = [0.89177134679795411 0.62484393589656639 -0.22099083498603111 0.81287195297159109 0.26357937046760704 -1.0070314773873914 0.13313121910919418 -0.43934971555450231 -0.62464376810082445;1.1702770156347135 0.81914685010578159 0.48972874039586689 0.31102706459447244 -0.53900220787459674 0.91841645119922222 0.16177092962313094 -0.23018793224401374 0.055792215444881443;-0.77780679793522456 -0.61487015548749158 -0.90774884441652715 0.091549253296305061 -0.81722742420912686 -0.86753357699032896 -0.041418980115140433 -0.49322377982907178 0.89443594906334767;0.083046417638724002 -0.42335780331197143 -0.14615878354275644 0.042610942619484782 0.68157687631439778 0.25262285356024533 -0.032901421249713764 -1.3880164826291015 -1.0814756088986595;0.071568443118012248 -0.51605452987665112 -0.55816102113453769 0.81490280443424679 -0.53108421875047052 0.87949176704986431 0.68113310437756103 0.76148687916338742 -0.39264119560646327;0.025760204771762052 -0.48084732594140178 0.76603990418354007 0.10613770134757522 0.24835403866946387 -0.71263509618631926 1.0347551890702498 -0.6893993464301289 -0.62673699023521734;-0.20090972575537275 0.15967653595863049 0.66866833655281455 0.48322501372969945 -0.04598737869894428 1.2982411593432226 0.74643609966350288 0.11081654770940574 0.66079739728881259;-0.99768419401341712 0.11582206255316738 0.15308795224591176 0.42625690707751979 0.24937323165837322 0.78910295735225611 0.83818575839397391 0.72763563762702399 -0.47447352365399126;-0.334884013441896 -1.3014053303907596 -0.49972306066617994 -0.28013248029065002 0.54075797665924241 0.74671842526086962 -0.31606996865664616 0.48574037813484738 0.086304436631540374;0.76735362273657803 -0.80532240981872849 -0.0080006186241033655 -0.56892836896748833 -0.38140029769635958 0.33794488576149156 0.84646859769497251 0.34426734644782531 -0.66578484936409055];

% Layer 2
b2 = [-0.86456880094074917;-0.21064525590672564];
LW2_1 = [-0.98660709910732614 -0.89744180228766479 0.73627944216663199 0.14671745102304956 -0.25537897497433054 0.65455211724919204 -0.52001709324296119 0.5399291980560027 0.68948621042132163 -0.30939573985158614;-0.22064443731718064 1.1775727146642936 -0.79875306896747789 -0.87178832079476876 0.14834721952124486 0.27618608399124184 0.83980892575151034 0.12000301014636532 -0.15902032424151899 0.22256846579226697];

% ===== SIMULATION ========

% Format Input Arguments
isCellX = iscell(X);
if ~isCellX, X = {X}; end;

% Dimensions
TS = size(X,2); % timesteps
if ~isempty(X)
    Q = size(X{1},2); % samples/series
else
    Q = 0;
end

% Allocate Outputs
Y = cell(1,TS);

% Time loop
for ts=1:TS
    
    % Input 1
    Xp1 = mapminmax_apply(X{1,ts},x1_step1);
    
    % Layer 1
    a1 = tansig_apply(repmat(b1,1,Q) + IW1_1*Xp1);
    
    % Layer 2
    a2 = softmax_apply(repmat(b2,1,Q) + LW2_1*a1);
    
    % Output 1
    Y{1,ts} = a2;
end

% Final Delay States
Xf = cell(1,0);
Af = cell(2,0);

% Format Output Arguments
if ~isCellX, Y = cell2mat(Y); end
end

% ===== MODULE FUNCTIONS ========

% Map Minimum and Maximum Input Processing Function
function y = mapminmax_apply(x,settings)
y = bsxfun(@minus,x,settings.xoffset);
y = bsxfun(@times,y,settings.gain);
y = bsxfun(@plus,y,settings.ymin);
end

% Competitive Soft Transfer Function
function a = softmax_apply(n,~)
if isa(n,'gpuArray')
    a = iSoftmaxApplyGPU(n);
else
    a = iSoftmaxApplyCPU(n);
end
end
function a = iSoftmaxApplyCPU(n)
nmax = max(n,[],1);
n = bsxfun(@minus,n,nmax);
numerator = exp(n);
denominator = sum(numerator,1);
denominator(denominator == 0) = 1;
a = bsxfun(@rdivide,numerator,denominator);
end
function a = iSoftmaxApplyGPU(n)
nmax = max(n,[],1);
numerator = arrayfun(@iSoftmaxApplyGPUHelper1,n,nmax);
denominator = sum(numerator,1);
a = arrayfun(@iSoftmaxApplyGPUHelper2,numerator,denominator);
end
function numerator = iSoftmaxApplyGPUHelper1(n,nmax)
numerator = exp(n - nmax);
end
function a = iSoftmaxApplyGPUHelper2(numerator,denominator)
if (denominator == 0)
    a = numerator;
else
    a = numerator ./ denominator;
end
end

% Sigmoid Symmetric Transfer Function
function a = tansig_apply(n,~)
a = 2 ./ (1 + exp(-2*n)) - 1;
end