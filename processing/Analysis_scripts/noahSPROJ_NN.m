
% get index of data conditions
HighComp_index = find(allData.trialinfo(:,2)==5);
B_index = find(allData.trialinfo(:,2)==6);
C_index = find(allData.trialinfo(:,2)==7);
D_index = find(allData.trialinfo(:,2)==8);

% locate data by condition
A = allData.trial{1,A_index};
B = allData.trial{1,B_index};
C = allData.trial{1,C_index};
D = allData.trial{1,D_index};

% A = hAhM
% B = lAhM
% C = hAlM
% D = lAlM

% plot it
figure
hold on
grid on
plot(A(:,:),(1:14),'b+')
plot(B(:,:),(1:14),'g+')
plot(C(:,:),(1:14),'r+')
plot(D(:,:),(1:14),'m+')

% encode clusters a and c as one class, and b and d as another
%a = -1; c = -1; b = 1; d = 1; %across attention
a = 1; c = -1; b = 1; d = -1; %across memory

% define inputs (combine sample from all 4 classes)
P = [A B C D];
% define targets
T = [
    repmat(a,1,length(A))...
    repmat(b,1,length(B))...
    repmat(c,1,length(C))...
    repmat(d,1,length(D))...
    ];
% view inputs/outputs
% [P' T']

%% Neural Network

% create the nn
net = feedforwardnet([5 3]);

% train net
net.divideParam.trainRatio = 60; % training set (%)
net.divideParam.valRatio = 20; % validation set (%)
net.divideParam.testRatio = 20; % test set (%)

% train a neural network 
[net, tr, Y, E]  = train(net,P,T);

% show the network
view(net)

%% plot network performance

figure(2)
hold on
grid on
plot(T','linewidth',2)
plot(Y','r--')
legend('Targets','Network Response','location','best')

%% plot classification resutl for the complete input space

% generate a grid
span = -1:.005:2;
[P1,P2] = meshgrid(span,span);
pp = [P1(:) P2(:)]';

% simulate neural network on a grid
aa = net(pp);

% translate output into [-1,1]
%aa = -1 + 2*(aa>0);

% plot classification regions
figure(1)
mesh(P1,P2,reshape(aa,length(span),length(span))-5);
colormap cool
