clear all

Len_train = 3000;
Len_test = 1000;
Len_init = 100;

load('NARMA10data');

%%%  eRNR parameters
N = 400;
rand( 'seed', 42 );
Win = (zeros(N,1)+1) .* (round(rand(N,1))*2 - 1); 
tau_r = 1/8;
tau_n = 1;
C  = 10e-6;
R1 = tau_n/C;
R2 = 1000e3;
Is = 25e-9;
gama = 0.05;
%%%

SimulationTime = tau_r*(Len_train+Len_test);
x = (0:tau_r:tau_r*((Len_train+Len_test)-1))';


dataMask = u(1:Len_train+Len_test)'.*Win*gama;
for i = 1:length(dataMask) %% pre-neuron rotation
   dataShifted(:,(i-1)+1:(i-1)+1) = circshift(dataMask(:,i),-i+1)-0.1;
end

theta=tau_r;
dataIN = dataShifted';

sim('Neuron.slx'); %% dynamic neuron
ak = dataOUT(2:end,:)';

sk = zeros(N,(Len_train+Len_test));
for t = 1:(Len_train+Len_test) %% post-neuron rotation
    sk(:,t) = circshift(ak(:,t),t-1);
end


%% training
ahead = 1;

reg = 1e-10;  % regularization coefficient
target = data(Len_init+1+ahead:Len_train+ahead)';
trainingState = sk(:,Len_init+1:Len_train);

Wout = (target*trainingState' / (trainingState*trainingState' + reg*eye(N)))';

%% Testing

testTarget = data(Len_train+1+ahead:Len_test+Len_train+ahead);

testingStates = sk(:,Len_train+1:Len_test+Len_train);

output = testingStates'*Wout; 

%% Result
NRMSE = sqrt(mean((output(Len_init+1:end)-testTarget(Len_init+1:end)).^2)./var(testTarget(Len_init+1:end)));
disp(['NRMSE = ' num2str(NRMSE)])

figure(1);
plot(testTarget(1:end), 'b' );
hold on;
plot( output', 'r' );
hold off;
axis tight;
title(['NARMA10 prediction   NRMSE=' num2str(NRMSE)]);
legend('Ground truth', 'Prediction');

