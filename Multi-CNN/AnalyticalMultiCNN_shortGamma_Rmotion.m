%% Simulation of the Analytical model of Multi-CNN
clear all;close all;clc;
Ravl=30;
TrainSamplesPercentage=0.8;
load('VObjects.mat');

LSize=length(VObjects);

%%Fitting Rmotion and RateNoTextureExcept1stFrame for 3DCNN
QPreg=40;
% Ravl=5; %% target bitrate must be changed
% TrainSamplesPercentage=0.20; %% percentage of the samples to be used for training

Lreg=find(VObjects(1).QP==QPreg);

for cnt=1:length(VObjects)
    MVCNN_Vec(cnt)=VObjects(cnt).Classified(Lreg);
end
%TrainSamplesPercentage=0.05; %% percentage of the samples to be used for training
TestSamplesPercentage=1-TrainSamplesPercentage;
NSample=length(VObjects);
NSampleTrain=floor(NSample*TrainSamplesPercentage);
NSampleTest=floor(NSample*TestSamplesPercentage);
IndexALL=randperm(NSample,NSample);
IndexTrain=IndexALL(1:NSampleTrain);
IndexTest=IndexALL(NSampleTrain+1:NSampleTest);

clear X X01 y X3DCNN;
%%%=======================================================================================
%% Training of 3DCNN
for cnt1=1:length(IndexTrain)
    X3DCNN(cnt1,1)=VObjects(IndexTrain(cnt1)).Rate(Lreg);
    X3DCNN(cnt1,2)=VObjects(IndexTrain(cnt1)).RateMotion(Lreg);
    X3DCNN(cnt1,3)=VObjects(IndexTrain(cnt1)).RateNoTextureExcept1stFrame(Lreg);
end

%%mean of Rmotion of training set
meuRmotion=mean(X3DCNN(:,2));
maxRateMotion=max(X3DCNN(:,2));
%%Normalization
X3DCNNz(:,1)=X3DCNN(:,1)-mean(X3DCNN(:,1));
X3DCNNz(:,2)=X3DCNN(:,2)-mean(X3DCNN(:,2));
X3DCNNz(:,3)=X3DCNN(:,3)-mean(X3DCNN(:,3));

X013DCNN(:,1)=(X3DCNNz(:,1)-min(X3DCNNz(:,1)))./(max(X3DCNNz(:,1))-min(X3DCNNz(:,1)));
X013DCNN(:,2)=(X3DCNNz(:,2)-min(X3DCNNz(:,2)))./(max(X3DCNNz(:,2))-min(X3DCNNz(:,2)));
X013DCNN(:,3)=(X3DCNNz(:,3)-min(X3DCNNz(:,3)))./(max(X3DCNNz(:,3))-min(X3DCNNz(:,3)));

%% using fitnlm or mnrfit
modelfun = @(b,x)(b(1) + b(2)*x(:,1));
beta0 = randn(2,1);
opts = statset('TolFun',1e-40);
mdl3DCNN = fitnlm(X3DCNN(:,2),X3DCNN(:,3),modelfun,beta0,'Options',opts);

%%%=======================================================================================
%% Training of 2DCNN
FPS=25;
Tav=160;
IndexQP=Lreg;
for cnt1=1:LSize
    X2DCNN_ALL(cnt1,1)=VObjects(cnt1).Rate(Lreg); %%%Original Rate
    X2DCNN_ALL(cnt1,2)=VObjects(cnt1).RateMotion(Lreg);
    L=length(VObjects(cnt1).FrameRateTotalNoTexture(IndexQP,:));
    if L>59
        bits_Frames_2_60=sum(VObjects(cnt1).FrameRateTotalNoTexture(IndexQP,2:60))/FPS;
    else
        bits_Frames_2_60=sum(VObjects(cnt1).FrameRateTotalNoTexture(IndexQP,2:L))*(60/L)/FPS;
    end
    bits_1stFrames=(VObjects(cnt1).FrameRateTotalOrig(IndexQP,1)/FPS);
    bits_2D=bits_1stFrames+bits_Frames_2_60;
    time_2D=(Tav/FPS);
    X2DCNN_ALL(cnt1,3)=bits_2D/time_2D;
end

X2DCNN=X2DCNN_ALL(IndexTrain,:);

%%Normalization
X2DCNNz(:,1)=X2DCNN(:,1)-mean(X2DCNN(:,1));
X2DCNNz(:,2)=X2DCNN(:,2)-mean(X2DCNN(:,2));
X2DCNNz(:,3)=X2DCNN(:,3)-mean(X2DCNN(:,3));

X012DCNN(:,1)=(X2DCNNz(:,1)-min(X2DCNNz(:,1)))./(max(X2DCNNz(:,1))-min(X2DCNNz(:,1)));
X012DCNN(:,2)=(X2DCNNz(:,2)-min(X2DCNNz(:,2)))./(max(X2DCNNz(:,2))-min(X2DCNNz(:,2)));
X012DCNN(:,3)=(X2DCNNz(:,3)-min(X2DCNNz(:,3)))./(max(X2DCNNz(:,3))-min(X2DCNNz(:,3)));

%% using fitnlm or mnrfit
modelfun = @(b,x)(b(1) + b(2)*x(:,1));
beta0 = randn(2,1);
opts = statset('TolFun',1e-40);
mdl2DCNN = fitnlm(X2DCNN(:,2),X2DCNN(:,3),modelfun,beta0,'Options',opts);

%%%=======================================================================================
%% Training of Spatioal CNN
FPS=25;
Tav=160;
IndexQP=Lreg;
for cnt1=1:LSize
    XSPCNN_ALL(cnt1,1)=VObjects(cnt1).Rate(Lreg); %%%Original Rate
    XSPCNN_ALL(cnt1,2)=VObjects(cnt1).RateMotion(Lreg);
    bits_1stFrames=(VObjects(cnt1).FrameRateTotalOrig(IndexQP,1)/FPS);
    time_2D=(Tav/FPS);
    XSPCNN_ALL(cnt1,3)=bits_1stFrames/time_2D;
end

XSPCNN=XSPCNN_ALL(IndexTrain,:);

%%Normalization
XSPCNNz(:,1)=XSPCNN(:,1)-mean(XSPCNN(:,1));
XSPCNNz(:,2)=XSPCNN(:,2)-mean(XSPCNN(:,2));
XSPCNNz(:,3)=XSPCNN(:,3)-mean(XSPCNN(:,3));

X01SPCNN(:,1)=(XSPCNNz(:,1)-min(XSPCNNz(:,1)))./(max(XSPCNNz(:,1))-min(XSPCNNz(:,1)));
X01SPCNN(:,2)=(XSPCNNz(:,2)-min(XSPCNNz(:,2)))./(max(XSPCNNz(:,2))-min(XSPCNNz(:,2)));
X01SPCNN(:,3)=(XSPCNNz(:,3)-min(XSPCNNz(:,3)))./(max(XSPCNNz(:,3))-min(XSPCNNz(:,3)));

%% using fitnlm or mnrfit
modelfun = @(b,x)(b(1) + b(2)*x(:,1));
beta0 = randn(2,1);
opts = statset('TolFun',1e-40);
mdlSPCNN = fitnlm(XSPCNN(:,2),X01SPCNN(:,3),modelfun,beta0,'Options',opts);

%figure
%plot(X3DCNN(:,2),X3DCNN(:,3),'ro');
%figure
%plot(X2DCNN(:,2),X2DCNN(:,3),'bx');
%figure
%plot(XSPCNN(:,2),XSPCNN(:,3),'ms');
%%%=======================================================================================
%Fitting Source Feature to Gama Distribution using only the training set
%(IndexTrain)
QP1=QPreg;
cnt2=1;cnt3=1;cnt4=1;cnt5=1;cnt6=1;cnt7=1;
L1=find(VObjects(1).QP==QP1);
for cnt1_I=1:length(IndexTrain)
    cnt1=IndexTrain(cnt1_I);
    if VObjects(cnt1).Classified_3D_Fusion(L1)==1
        VObjectsQP1_3D(cnt2)=VObjects(cnt1);
        X_QP1_3D_Rm(cnt2,:)=VObjects(cnt1).RateMotion;
        X_QP1_3D_Rcrop(cnt2,:)=VObjects(cnt1).RateNoTextureExcept1stFrame;
        cnt2=cnt2+1;
    else
        VObjectsNotQP1_3D(cnt3)=VObjects(cnt1);
        X_NotQP1_3D_Rm(cnt3,:)=VObjects(cnt1).RateMotion;
        X_NotQP1_3D_Rcrop(cnt3,:)=VObjects(cnt1).RateNoTextureExcept1stFrame;
        cnt3=cnt3+1;
    end
    
    if VObjects(cnt1).Classified_2D_Fusion(L1)==1
        VObjectsQP1_2D(cnt4)=VObjects(cnt1);
        X_QP1_2D_Rm(cnt4,:)=VObjects(cnt1).RateMotion;
        X_QP1_2D_Rcrop(cnt4,:)=VObjects(cnt1).RateNoTextureExcept1stFrame;
        cnt4=cnt4+1;
    else
        VObjectsNotQP1_2D(cnt5)=VObjects(cnt1);
        X_NotQP1_2D_Rm(cnt5,:)=VObjects(cnt1).RateMotion;
        X_NotQP1_2D_Rcrop(cnt5,:)=VObjects(cnt1).RateNoTextureExcept1stFrame;
        cnt5=cnt5+1;
    end
    
    if VObjects(cnt1).Classified_Spatial(L1)==1
        VObjectsQP1_Spatial(cnt6)=VObjects(cnt1);
        X_QP1_Spatial_Rm(cnt6,:)=VObjects(cnt1).RateMotion;
        X_QP1_Spatial_Rcrop(cnt6,:)=VObjects(cnt1).RateNoTextureExcept1stFrame;
        cnt6=cnt6+1;
    else
        VObjectsNotQP1_Spatial(cnt7)=VObjects(cnt1);
        X_NotQP1_Spatial_Rm(cnt7,:)=VObjects(cnt1).RateMotion;
        X_NotQP1_Spatial_Rcrop(cnt7,:)=VObjects(cnt1).RateNoTextureExcept1stFrame;
        cnt7=cnt7+1;
    end
end

%%% pdf fitting
close all;
QP=QPreg;
opt='ALL';
type='Gamma';
X_QP1_Rm=[X_QP1_3D_Rm; X_NotQP1_3D_Rm];
[pd_ALL,xfit_All,yfit_All,xm_All,ym_All]=fit_CNN_ACC(X_QP1_Rm(:,L1),type,QP,opt);


%%%Modeling assuming RSP is the average rate of test samples
ACC_3DCNN=0.88;
ACC_2DCNN=0.855;
ACC_SPCNN=0.805;
RSP=mean(XSPCNN(:,3));
cnt=0;
for Rmotion_Lamda=[inf 30 20 10 0]
    cnt=cnt+1;
    %Rmotion_Lamda=30;
    Rmotion_Zeta=inf;
    AccG1(cnt)=(ACC_3DCNN-ACC_2DCNN)*gamcdf(Rmotion_Lamda,pd_ALL.a,pd_ALL.b)+(ACC_2DCNN-ACC_SPCNN)*gamcdf(Rmotion_Zeta,pd_ALL.a,pd_ALL.b)+ACC_SPCNN;
    b3D=mdl3DCNN.Coefficients.Estimate(1);a3D=mdl3DCNN.Coefficients.Estimate(2);
    b2D=mdl2DCNN.Coefficients.Estimate(1);a2D=mdl2DCNN.Coefficients.Estimate(2);
    bSP=RSP;aSP=0;
    A=(b3D-b2D)*gamcdf(Rmotion_Lamda,pd_ALL.a,pd_ALL.b)+(b2D-bSP)*gamcdf(Rmotion_Zeta,pd_ALL.a,pd_ALL.b)+bSP;
    B=((a3D-a2D)*gamcdf(Rmotion_Lamda,pd_ALL.a+1,pd_ALL.b)+(a2D)*gamcdf(Rmotion_Zeta,pd_ALL.a+1,pd_ALL.b))*(pd_ALL.a/pd_ALL.b);
    RG1(cnt)=A+B;
end

cnt=0;

for Rmotion_Zeta=[inf 30 20 10 0]
    cnt=cnt+1;
    Rmotion_Lamda=0;
    %Rmotion_Zeta=inf;
    %%% For Gama Distribution
    AccG2(cnt)=(ACC_3DCNN-ACC_2DCNN)*gamcdf(Rmotion_Lamda,pd_ALL.a,pd_ALL.b)+(ACC_2DCNN-ACC_SPCNN)*gamcdf(Rmotion_Zeta,pd_ALL.a,pd_ALL.b)+ACC_SPCNN;
    b3D=mdl3DCNN.Coefficients.Estimate(1);a3D=mdl3DCNN.Coefficients.Estimate(2);
    b2D=mdl2DCNN.Coefficients.Estimate(1);a2D=mdl2DCNN.Coefficients.Estimate(2);
    %bSP=mdlSPCNN.Coefficients.Estimate(1);aSP=mdlSPCNN.Coefficients.Estimate(2);
    bSP=RSP;aSP=0;
    A=(b3D-b2D)*gamcdf(Rmotion_Lamda,pd_ALL.a,pd_ALL.b)+(b2D-bSP)*gamcdf(Rmotion_Zeta,pd_ALL.a,pd_ALL.b)+bSP;
    B=((a3D-a2D)*gamcdf(Rmotion_Lamda,pd_ALL.a+1,pd_ALL.b)+(a2D)*gamcdf(Rmotion_Zeta,pd_ALL.a+1,pd_ALL.b))*(pd_ALL.a/pd_ALL.b);
    RG2(cnt)=A+B;
end

cnt=0;

%%%%%% incase using a wrong distribution (Uniform Distribution)
Rmax=meuRmotion*2; %% so that mean of Rmotion of training set is the mean of the uniform [0,Rmax]
cnt=0;
for Rmotion_Lamda=[0:Rmax/5:Rmax]
    for Rmotion_Zeta=[0:Rmax/5:Rmax]
        if ((Rmotion_Lamda<Rmotion_Zeta) && (Rmotion_Lamda<=Rmax)&& (Rmotion_Lamda<=Rmax))
            cnt=cnt+1;
            b3D=mdl3DCNN.Coefficients.Estimate(1);a3D=mdl3DCNN.Coefficients.Estimate(2);
            b2D=mdl2DCNN.Coefficients.Estimate(1);a2D=mdl2DCNN.Coefficients.Estimate(2);
            %bSP=mdlSPCNN.Coefficients.Estimate(1);aSP=mdlSPCNN.Coefficients.Estimate(2);
            bSP=RSP;aSP=0;
            AccU(cnt)=(ACC_3DCNN-ACC_2DCNN)*(Rmotion_Lamda/Rmax)+(ACC_2DCNN-ACC_SPCNN)*(Rmotion_Zeta/Rmax)+ACC_SPCNN;
            A=(b3D-b2D)*(Rmotion_Lamda/Rmax)+(b2D-bSP)*(Rmotion_Zeta/Rmax)+bSP;
            B=((a3D-a2D)*(Rmotion_Lamda^2)/(2*Rmax))+((a2D)*(Rmotion_Zeta^2)/(2*Rmax));
            RU(cnt)=A+B;
        end
    end
end
[BR,I] = sort(RU);
BA=AccU(I);
AccU=BA;RU=BR;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure
plot([RG1 RG2],[AccG1 AccG2],'--bo');
plot([RU],[AccU],':bs');
legend('a_s_p and b_s_p from linear model','a_s_p is derived from average R_F_i_r_s_t_-_F_r_a_m_e','Assuming Uniform Distribution');

%R1,Acc1 : Rmotion_Lamda=[inf 30 20 10 0], Rmotion_Zeta=inf
%R2,Acc2 : Rmotion_Lamda=0, Rmotion_Zeta=[inf 30 20 10 0]
%SSize : size of training sample
SSize=length(IndexTrain)
file=strcat('AnalyticalMultiCNNRmotion_',num2str(TrainSamplesPercentage*100),'.mat');
if exist(file, 'file')
    load(file);
    L=size(R1M,1);
    R1M=[R1M ;RG1];
    R2M=[R2M ;RG2];
    Acc1M=[Acc1M ;AccG1];
    Acc2M=[Acc2M ;AccG2];
    SSizeM=[SSizeM;SSize];
else
    R1M=RG1;R2M=RG2;Acc1M=AccG1;Acc2M=AccG2;SSizeM=SSize;
end
save(file,'R1M','Acc1M','R2M','Acc2M','SSizeM');

close all;
L=size(R1M,1)

%Ravl=60; %% target bitrate must be changed
L1=ACC_3DCNN-ACC_2DCNN;
L2=ACC_2DCNN-ACC_SPCNN;
L3=a3D-a2D;
L4=b3D-b2D;
L5=a2D-aSP;
L6=b2D-bSP;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55
%%% using nonlinear programing to find optimal values of RL, RH
if true %% using multivariate nonlinear optimization technique to find potimal values of RL and RH
    close all;
    Alpha=pd_ALL.a;
    Beta=pd_ALL.b;
    save('temp.mat','Alpha','Beta','L3','L4','L5','L6','aSP','Ravl');
    AccNLP = @(RLH) 0.01/((L1*gamcdf(RLH(1),Alpha,Beta)+L2*gamcdf(RLH(2),Alpha,Beta)+ACC_SPCNN));
    
    
    x0=[0 0];
    A = [1 -1];
    b = 0;
    fun = AccNLP;
    nonlcon = @Rbudget;
    %% using Genatic solver
    nvars = 2;    % Number of variables
    LB = [0 0];   % Lower bound
    UB = [1e6 1e6];  % Upper bound
    options = optimoptions('ga','Display','iter','InitialPopulationRange',[0;maxRateMotion]);
    %options = optimoptions('ga','Display','iter','PlotFcn',{@gaplotbestf,@gaplotstopping},'InitialPopulationRange',[0;maxRateMotion]);
    [x,Fval,exitFlag,Output] = ga(fun,nvars,A,b,[],[],LB,UB,nonlcon,options);
    fprintf('The number of generations was : %d\n', Output.generations);
    fprintf('The FunctionTolerance was : %d\n', options.FunctionTolerance);
    fprintf('The ConstraintTolerance was : %d\n', options.ConstraintTolerance);
    fprintf('The number of function evaluations was : %d\n', Output.funccount);
    fprintf('The best function value found was : %g\n', Fval);
    fprintf('The optimal threshold values found were R_L=%g kbps and R_H=%gkbps\n', x(1),x(2));
    
    RL=x(1);
    RH=x(2);
    AccNLP=100*(L1*gamcdf(RL,Alpha,Beta)+L2*gamcdf(RH,Alpha,Beta)+ACC_SPCNN);
    RbudgetNLP=L4*gamcdf(RL,Alpha,Beta)+L6*gamcdf(RH,Alpha,Beta)+L3*(Alpha*Beta)*gamcdf(RL,Alpha+1,Beta)+L5*(Alpha*Beta)*gamcdf(RH,Alpha+1,Beta)+aSP;
    
    %%% get Rbudget and Acc based on NLP RL and RH
    IndexTest=1:length(VObjects);
    for cnt1=1:length(IndexTrain)
        IndexTest(find(IndexTest==IndexTrain(cnt1)))=[];
    end
    
    for cnt1=1:length(IndexTest)
        cnt1Ind=IndexTest(cnt1);
        if VObjects(cnt1Ind).RateMotion(Lreg) <= RL
            bits_1stFrames=(VObjects(cnt1Ind).FrameRateTotalOrig(IndexQP,1)/FPS);
            L=length(VObjects(cnt1Ind).FrameRateTotalNoTexture(IndexQP,:));
            if L>159
                bits_Frames_2_160=sum(VObjects(cnt1Ind).FrameRateTotalNoTexture(IndexQP,2:160))/FPS;
            else
                bits_Frames_2_160=sum(VObjects(cnt1Ind).FrameRateTotalNoTexture(IndexQP,2:L))*(160/L)/FPS;
            end
            bits_1stFrames=(VObjects(cnt1Ind).FrameRateTotalOrig(IndexQP,1)/FPS);
            bits_3D=bits_1stFrames+bits_Frames_2_160;
            time_3D=(Tav/FPS);
            RbugetPractv(cnt1)=bits_3D/time_3D;
            AccPractv(cnt1)=VObjects(cnt1Ind).Classified_3D_Fusion(Lreg);
        elseif VObjects(cnt1Ind).RateMotion(Lreg) <= RH
            bits_1stFrames=(VObjects(cnt1Ind).FrameRateTotalOrig(IndexQP,1)/FPS);
            L=length(VObjects(cnt1Ind).FrameRateTotalNoTexture(IndexQP,:));
            if L>59
                bits_Frames_2_60=sum(VObjects(cnt1Ind).FrameRateTotalNoTexture(IndexQP,2:60))/FPS;
            else
                bits_Frames_2_60=sum(VObjects(cnt1Ind).FrameRateTotalNoTexture(IndexQP,2:L))*(60/L)/FPS;
            end
            bits_1stFrames=(VObjects(cnt1Ind).FrameRateTotalOrig(IndexQP,1)/FPS);
            bits_2D=bits_1stFrames+bits_Frames_2_60;
            time_2D=(Tav/FPS);
            RbugetPractv(cnt1)=bits_2D/time_2D;
            AccPractv(cnt1)=VObjects(cnt1Ind).Classified_2D_Fusion(Lreg);
        else
            bits_1stFrames=(VObjects(cnt1Ind).FrameRateTotalOrig(IndexQP,1)/FPS);
            time_2D=(Tav/FPS);
            RbugetPractv(cnt1)=bits_1stFrames/time_2D;
            AccPractv(cnt1)=VObjects(cnt1Ind).Classified_Spatial(Lreg);
        end
    end
    
    RbugetPract=mean(RbugetPractv);
    AccPract=mean(AccPractv)*100;
    fileNLP=strcat('AnalyticalMultiCNNRmotion_NLP_Ravl',num2str(Ravl),'_',num2str(TrainSamplesPercentage*100),'.mat');
    if exist(fileNLP, 'file')
        load(fileNLP);
        NLPM=[NLPM; Ravl RbudgetNLP AccNLP RbugetPract AccPract RL RH x0 length(IndexTest)];
        %pause(20);
    else
        NLPM=[Ravl RbudgetNLP AccNLP RbugetPract AccPract RL RH x0 length(IndexTest)];
        x0=[RL RH];
        fileInit=strcat('InitialValueRmotion_Ravl',num2str(Ravl),'_',num2str(TrainSamplesPercentage*100),'.mat');
        save(fileInit,'x0');
    end
    fprintf('\n\nTarget Ravl=%g kbps\n', Ravl);
    fprintf('Target Rate Analytical=%g kbps\n', RbudgetNLP);
    fprintf('Target Acc Analytical =%g%% \n', AccNLP);
    fprintf('Target Rate practical=%g kbps\n', RbugetPract);
    fprintf('Target Acc Practical=%g%% \n', AccPract);
    AnsSave=[];
    %AnsSave=input('Save Results [y/n]:','s');
    if isempty(AnsSave)
        AnsSave = 'y';
    end
    if AnsSave == 'y'
        save(fileNLP,'NLPM');
        display('Data Saved');
    end
end