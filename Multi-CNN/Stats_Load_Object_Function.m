function [VObjects]=Stats_Load_Object_Function(QP_Encoder, OptComm_Encoder, FPS, VObjects)
%% The fields of each rwo of Stats vector (i.e. Stats_All, ...) which corresponds to each video
%% Rates and Number of MBs is in k (kbps, and kMBs)
%% 1. Video#
%% 2. Number of Frames Frames_Orig
%% 3. Rate of H.264 Bitstream (Orig)
%% 4  Rate of Motion info of H.264 Bitstream (Motion_Orig)
%% 5. Number of Frames_NoTexture
%% 6. Rate of cropped H.264 Bitstream (NoTexture)
%% 7. Rate of cropped H.264 Bitstream (Motion_NoTexture)
%% 8. Number of MBs with Mode0Copy
%% 9. Number of MBs with Mode1(16x16)
%% 10. Number of MBs with Mode2(16x8)
%% 11. Number of MBs with Mode3(8x16)
%% 12. Number of MBs with Mode4(8x8)
%% 13. Rate of motion info for Mode0Copy MBs
%% 14. Rate of motion info for Mode1(16x16) MBs
%% 15. Rate of motion info for Mode2(16x8) MBs
%% 16. Rate of motion info for Mode3(8x16) MBs
%% 17. Rate of motion info for Mode4(8x8) MBs
%% 18. PSNR_Y Value
%% 19. MSE_Y Value
%% 20. Classification result (1:correctly classified, 0:wrong classified)


% clear all;close all;clc;
% FPS=25;
%QP_Encoder=35;
%OptComm_Encoder='A';
ToPrint=0;
filename=strcat('./DataFiles/Stats_Orig_NOTexture_Test01_QP',num2str(QP_Encoder),'_MVSR16_MVRes8_',OptComm_Encoder,'.dat');
QP=QP_Encoder;
fprintf('Loading Stats Info for QP=%2d',QP);
%% Load file contents ...
fid = fopen(filename,'r');
tline = fgetl(fid);
tline = fgetl(fid);
cnt2=1;
StatsArray=[];
FNames=blanks(1);
WriteFileName=0;
while ischar(tline)
    %    disp(tline)
    NumaricLine=double(tline)-48;
    cnt1=1;
    cnt3=1;
    StatsArrayTemplate=zeros(1,19);
    StatsArray=[StatsArray;StatsArrayTemplate];
    M1=10; M2=0; MInc=0;
    for l=1:length(NumaricLine)
        if ( NumaricLine(l)== -16 )
            cnt1=cnt1+1;
            M1=10; M2=0; MInc=0;
        else
            if (cnt1 < 20)
                if tline(l)=='.'
                    MInc=1;
                    M1=1;
                else
                    M2=M2+MInc;
                    StatsArray(cnt2,cnt1)=StatsArray(cnt2,cnt1)*M1+NumaricLine(l)*((0.1)^M2);
                end
            else
                if tline(l)=='.'
                    WriteFileName=0;
                end
                if WriteFileName==1
                    FNames(cnt2,cnt3)=tline(l);
                    cnt3=cnt3+1;
                end
                if tline(l)=='/'
                    WriteFileName=1;
                end
            end
        end
    end
    StatsArray(cnt2,:);
    tline = fgetl(fid);
    cnt2=cnt2+1;
    cnt3=1;
    WriteFileName=0;
end
fclose(fid);

if (size(unique(StatsArray(:,1)),1)~=size(StatsArray,1))
    [Value,Index]=unique(StatsArray(:,1));
    StatsArray=StatsArray(Index,:);
    FNames=FNames(Index,:);
end

if (StatsArray(end,1)>(size(unique(StatsArray(:,1)),1)))
    for i=0:StatsArray(end,1)
        if isempty(find(i==StatsArray(:,1)))
            fprintf('Video File Number %d is missing from the Size File\n',i);
        end
    end
    error('Missing files in the StatsArray or Size_File');
end

VideoStats=StatsArray;
VideoStats(:,[3,4])=(VideoStats(:,[3,4])./VideoStats(:,[2]))*FPS/1000;  %%Rate of bits
VideoStats(:,[6,7])=(VideoStats(:,[6,7])./VideoStats(:,[5]))*FPS/1000;  %%Rate of bits
VideoStats(:,[8:12])=(VideoStats(:,[8:12])./VideoStats(:,[2]))/1000; %%Number of P MBs (different types) per Frame
VideoStats(:,[13,17])=(VideoStats(:,[13,17]))*FPS/1000; %%Rate of Bits


QPObject=VObjects(1).QP;
L=find(QP==QPObject);
for i=1:length(VObjects)
    for j=1:size(StatsArray,1)
        Len=min(length(VObjects(i).Filename),length(FNames(j,:)));
        if strcmp(VObjects(i).Filename(1:Len),FNames(j,1:Len))
            VObjects(i).NoFrames(L)=VideoStats(j,2);
            VObjects(i).Rate(L)=VideoStats(j,3);
            VObjects(i).RateMotion(L)=VideoStats(j,4);
            VObjects(i).RateNoTextureExcept1stFrame(L)=VideoStats(j,6);
            VObjects(i).Sparsity(L)=VideoStats(j,8);
            VObjects(i).P_MBs(L)=sum(VideoStats(j,[9:12]));
            VObjects(i).PSNR(L)=VideoStats(j,18);
            VObjects(i).MSE(L)=VideoStats(j,19);
        end
    end
end
fprintf(' ....... Done \n');
