clear all

Len_train = 3000;
Len_test = 1000;
Len_init = 100;

load('NARMA10data');

para.resSize = 388;
para.Nres = 50;
para.theta = 1/8;
para.model = 'Neuron';

sk = SCR_par(u(1:Len_train+Len_test),para); %% eRNR


%% training
reg = 1e-10; 
target = data(Len_init+2:Len_train+1)';
trainingState = sk(:,Len_init+1:Len_train);
warning('off');
Wout = (target*trainingState' / (trainingState*trainingState' + reg*eye(para.resSize*para.Nres)))';
%% Testing

testTarget = data(Len_train+1:Len_test+Len_train+1);

testingStates = sk(:,Len_train+1:Len_test+Len_train);

output = testingStates'*Wout; 


%% Result

NRMSE = sqrt(mean((output(Len_init+1:end)-testTarget(Len_init+2:end)).^2)./var(testTarget(Len_init+2:end)));
disp(['NRMSE = ' num2str(NRMSE)])

figure(1);
plot(testTarget(2:end), 'b' );
hold on;
plot( output', 'r' );
hold off;
axis tight;
title(['NARMA10 prediction   NRMSE=' num2str(NRMSE)]);
legend('Ground truth', 'Prediction');
