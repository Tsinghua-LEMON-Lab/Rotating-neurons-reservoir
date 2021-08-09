function [States] = SCR_par(data,para)

resSize = para.resSize;
Nres = para.Nres;
theta = para.theta;

rand( 'seed', 42 );
for i  = 1:Nres
    signal = round(rand(resSize,1))*2 - 1;
    Win(:,i) = (zeros(resSize,1)+1) .* signal; %r=0.5
    
end




SimulationTime = theta*length(data);

maskLen = 1;
R1 = 100e3;
R2 = 1000e3;

C  = 10e-6;
Is = 25e-9;



x = (0:theta:theta*(length(data)-1))';

scalling = 0.05;

for j = 1:Nres
    dataMask = data'.*Win(:,j)*scalling;
    for i = 1:length(dataMask)
        dataShifted(:,(i-1)+1,j) = circshift(dataMask(:,i),-i+1)-0.1;
    end
end

y = zeros(resSize,length(data));

for i = 1:Nres
    simIn(i) = Simulink.SimulationInput(para.model);
    simIn(i) =setVariable(simIn(i),'R1',R1);
    simIn(i) =setVariable(simIn(i),'R2',R2);
    simIn(i) =setVariable(simIn(i),'theta',theta);
    simIn(i) =setVariable(simIn(i),'C',C);
    simIn(i) =setVariable(simIn(i),'Is',Is);
    simIn(i) =setVariable(simIn(i),'x',x);
    simIn(i) =setVariable(simIn(i),'SimulationTime',SimulationTime);
    simIn(i) =setVariable(simIn(i),'dataIN',dataShifted(:,:,i)');
    
end
if(Nres == 1)
    out = sim(simIn);
else
    out = parsim(simIn);
end
% y(:,:,i) = out.dataOUT(2:end,:)';
%%
for i = 1:Nres
    y = out(i).dataOUT(2:end,:)';
    for t = 1:length(data)
        yout1(:,t,i) = circshift(y(:,t),t-1);
    end
end
States = reshape(permute(yout1,[3,1,2]),Nres*resSize,length(data));
end

