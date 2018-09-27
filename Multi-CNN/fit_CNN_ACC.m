function [pd,xfit,yfit,xmeasure,ymeasure]=fit_CNN_ACC(ym,type,QP,opt)
%close all;
%ym=X_QP1_3D(:,L1);
figure
%% get data stats
h=histogram(ym,'facealpha',.005,'Normalization','pdf');
kstest(ym);
%h=histogram(ym,'facealpha',.005);

%% get pdf based on data
xmeasure=[h.BinLimits(1):h.BinWidth:(h.BinLimits(2)-h.BinWidth)];
ymeasure=h.Values;

%% fit data to pdf
%type='Normal';
pd = fitdist(ym,type);
%xfit = 0:1:120;
xfit=xmeasure;
yfit = pdf(pd,xfit);

%% Another way to fit distribution
paramEsts = fitdist(ym,'Gamma') ;
[h,p,stats]=chi2gof(ym,'CDF',paramEsts);


%% Kullback-Leibler Divergence between two probability distributions
xfitKL=xfit;
ymeasureKL=ymeasure;
yfitKL=yfit;
I=find(ymeasureKL==0);ymeasureKL(I)=[];yfitKL(I)=[];xfitKL(I)=[];
I=find(yfitKL==0);ymeasureKL(I)=[];yfitKL(I)=[];xfitKL(I)=[];

ymeasureKL=ymeasureKL/sum(ymeasureKL);
yfitKL=yfitKL/sum(yfitKL);
KL = kldiv(xfitKL,ymeasureKL,yfitKL);

%%% reduce the sampling period (increase samples to smooothen the plot)
if max(xfit)<=10
xfitplot=min(xfit):0.01:max(xfit);
else
xfitplot=min(xfit):1:max(xfit);
end
    
yfitplot = pdf(pd,xfitplot);


%% measure goodness of fit
SSE = sum((ymeasure-yfit).^2);
SST = sum((ymeasure-mean(ymeasure)).^2);
R_square=1-(SSE/SST);

hold on
set(gca,'FontSize',12)
plot(xmeasure,ymeasure,':r','LineWidth',2);
plot(xfitplot,yfitplot,'-b','LineWidth',2);
legend('Histogram','Acutual data distibution','The Model');
xlabel(strcat('R_m_o_t_i_o_n (kbps)'));
ylabel('pdf');
if (length(opt)==3)
    if (opt=='ALL')
        title(strcat('Using "',type,'" distribution to model the source, SSE=',num2str(SSE),', R-square=',num2str(R_square), 'KL=',num2str(KL)))
    else
        title(strcat('Using "',type,'" distribution to model "',opt,'" Classfication Accuracy, SSE=',num2str(SSE),', R-square=',num2str(R_square), 'KL=',num2str(KL)))
    end
else
    title(strcat('Using "',type,'" distribution to model "',opt,'" Classfication Accuracy, SSE=',num2str(SSE),', R-square=',num2str(R_square), 'KL=',num2str(KL)))
end