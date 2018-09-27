function [VObjects]=RateFrame_Load_Object_Function(QP_Encoder, OptComm_Encoder, FPS, VObjects)

% clear all;close all;clc;
% QP_Encoder=40;
% OptComm_Encoder='A';
% load('VObjects.mat');
% FPS=25;

QP=QP_Encoder;


filename_TotalOrig=strcat('./DataFiles/RTotal_Orig_Test01_QP',num2str(QP),'_MVSR16_MVRes8_',OptComm_Encoder,'.dat');
filename_MotionOrig=strcat('./DataFiles/RMotion_Orig_Test01_QP',num2str(QP),'_MVSR16_MVRes8_',OptComm_Encoder,'.dat');
filename_MotionNoTexture=strcat('./DataFiles/RMotion_NoTexture_Test01_QP',num2str(QP),'_MVSR16_MVRes8_',OptComm_Encoder,'.dat');
filename_TotalNoTexture=strcat('./DataFiles/RTotal_NoTexture_Test01_QP',num2str(QP),'_MVSR16_MVRes8_',OptComm_Encoder,'.dat');

%%%%%%%%%%%
fprintf('Loading Frame Rate Total Original for QP=%2d',QP);
clear Fnames FrameNumberRateArray;
[FNames ,FrameNumberRateArray]=RateFrame_Load_Function(filename_TotalOrig);
FrameNumberRateArray(:,2:end)=FrameNumberRateArray(:,2:end)*FPS/1000;
QPObject=VObjects(1).QP;
L=find(QP==QPObject);
for i=1:length(VObjects)
    for j=1:size(FNames,1)
        Len=min(length(VObjects(i).Filename),length(FNames(j,:)));
        if strcmp(VObjects(i).Filename(1:Len),FNames(j,1:Len))
            VObjects(i).FrameRateTotalOrig(L,:)=FrameNumberRateArray(j,(2:(FrameNumberRateArray(j,1)+2)));
            VObjects(i).VarFrameRateTotalOrig(L)=var(FrameNumberRateArray(j,(2:(FrameNumberRateArray(j,1)+2))));
        end
    end
end
fprintf(' ....... Done \n');

%%%%%%%%%%%
fprintf('Loading Frame Rate Motion Original for QP=%2d',QP);
clear Fnames FrameNumberRateArray;
[FNames ,FrameNumberRateArray]=RateFrame_Load_Function(filename_MotionOrig);
FrameNumberRateArray(:,2:end)=FrameNumberRateArray(:,2:end)*FPS/1000;
QPObject=VObjects(1).QP;
L=find(QP==QPObject);
for i=1:length(VObjects)
    for j=1:size(FNames,1)
        Len=min(length(VObjects(i).Filename),length(FNames(j,:)));
        if strcmp(VObjects(i).Filename(1:Len),FNames(j,1:Len))
            VObjects(i).FrameRateMotionOrig(L,:)=FrameNumberRateArray(j,(2:(FrameNumberRateArray(j,1)+2)));
            VObjects(i).VarFrameRateMotionOrig(L)=var(FrameNumberRateArray(j,(2:(FrameNumberRateArray(j,1)+2))));
        end
    end
end
fprintf(' ....... Done \n');

%%%%%%%%%%%
fprintf('Loading Frame Rate Total No Texture for QP=%2d',QP);
clear Fnames FrameNumberRateArray;
[FNames ,FrameNumberRateArray]=RateFrame_Load_Function(filename_TotalNoTexture);
FrameNumberRateArray(:,2:end)=FrameNumberRateArray(:,2:end)*FPS/1000;
QPObject=VObjects(1).QP;
L=find(QP==QPObject);
for i=1:length(VObjects)
    for j=1:size(FNames,1)
        Len=min(length(VObjects(i).Filename),length(FNames(j,:)));
        if strcmp(VObjects(i).Filename(1:Len),FNames(j,1:Len))
            VObjects(i).FrameRateTotalNoTexture(L,:)=FrameNumberRateArray(j,(2:(FrameNumberRateArray(j,1)+2)));
        end
    end
end
fprintf(' ....... Done \n');

%%%%%%%%%%%
fprintf('Loading Frame Rate Motion No Texture for QP=%2d',QP);
clear Fnames FrameNumberRateArray;
[FNames ,FrameNumberRateArray]=RateFrame_Load_Function(filename_MotionNoTexture);
FrameNumberRateArray(:,2:end)=FrameNumberRateArray(:,2:end)*FPS/1000;
QPObject=VObjects(1).QP;
L=find(QP==QPObject);
for i=1:length(VObjects)
    for j=1:size(FNames,1)
        Len=min(length(VObjects(i).Filename),length(FNames(j,:)));
        if strcmp(VObjects(i).Filename(1:Len),FNames(j,1:Len))
            VObjects(i).FrameRateMotionNoTexture(L,:)=FrameNumberRateArray(j,(2:(FrameNumberRateArray(j,1)+2)));
        end
    end
end

fprintf(' ....... Done \n');
