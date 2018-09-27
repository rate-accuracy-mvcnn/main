clc;close all;clear all;

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

%% The terms Dynamicity or Activity are used interchangeably in this work 

%%Global Inputs:
FPS=25;
ExtractDataFromSource=1;

if ExtractDataFromSource
    %% Create Video Objects according to the names in the UCF split 1.
    fid = fopen('testlist01.txt','r') ;
    tline = fgetl(fid);
    cnt1=1;
    cnt2=1;
    WriteFileName=0;
    while ischar(tline)
        %    disp(tline)
        for l=1:length(tline)
            if tline(l)=='.' WriteFileName=0;end
            if WriteFileName==1 FName(cnt1)=tline(l);cnt1=cnt1+1;end
            if tline(l)=='/' WriteFileName=1; end
        end
        VObjects(cnt2)=VideoObjectClass(cnt2,FName);
        VObjects(cnt2).QP=[0 30 40 51];
        FName=blanks(0);
        cnt2=cnt2+1;
        tline = fgetl(fid);
        WriteFileName=0;
        cnt1=1;
    end
    fclose(fid);
    
    %%Load and Attach Stats and classification to Video Objects
    QP_Encoder=0; OptComm_Encoder='A';
    QP_Classifier=QP_Encoder;OptComm_Classifier=OptComm_Encoder;
    VObjects=Stats_Load_Object_Function(QP_Encoder, OptComm_Encoder,FPS, VObjects);
    VObjects=Correct_Vector_Load_Object_Function(QP_Classifier, OptComm_Classifier, VObjects);
    VObjects=Correct_Vector_Spatial_Load_Object_Function(QP_Classifier, OptComm_Classifier, VObjects);
    VObjects=RateFrame_Load_Object_Function(QP_Encoder, OptComm_Encoder, FPS, VObjects);
    VObjects=ComputeNoTextureRatePerVideoFromFrame(VObjects,QP_Encoder);
   
    
    QP_Encoder=30; OptComm_Encoder='A';
    QP_Classifier=QP_Encoder;OptComm_Classifier=OptComm_Encoder;
    VObjects=Stats_Load_Object_Function(QP_Encoder, OptComm_Encoder,FPS, VObjects);
    VObjects=Correct_Vector_Load_Object_Function(QP_Classifier, OptComm_Classifier, VObjects);
    VObjects=Correct_Vector_2D_Load_Object_Function(QP_Classifier, OptComm_Classifier, VObjects);
    VObjects=Correct_Vector_Spatial_Load_Object_Function(QP_Classifier, OptComm_Classifier, VObjects);
    VObjects=RateFrame_Load_Object_Function(QP_Encoder, OptComm_Encoder, FPS, VObjects);
    VObjects=ComputeNoTextureRatePerVideoFromFrame(VObjects,QP_Encoder); 
       
    QP_Encoder=40; OptComm_Encoder='A';
    QP_Classifier=QP_Encoder;OptComm_Classifier=OptComm_Encoder;
    VObjects=Stats_Load_Object_Function(QP_Encoder, OptComm_Encoder,FPS, VObjects);
    VObjects=Correct_Vector_Load_Object_Function(QP_Classifier, OptComm_Classifier, VObjects);
    VObjects=Correct_Vector_2D_Load_Object_Function(QP_Classifier, OptComm_Classifier, VObjects);
    VObjects=Correct_Vector_Spatial_Load_Object_Function(QP_Classifier, OptComm_Classifier, VObjects);
    VObjects=Correct_Vector_2D_Fusion_Load_Object_Function(QP_Classifier, OptComm_Classifier, VObjects);
    VObjects=Correct_Vector_3D_Fusion_Load_Object_Function(QP_Classifier, OptComm_Classifier, VObjects);
    VObjects=RateFrame_Load_Object_Function(QP_Encoder, OptComm_Encoder, FPS, VObjects);
    VObjects=ComputeNoTextureRatePerVideoFromFrame(VObjects,QP_Encoder);
 %   VObjects=Compute_Load_Object_NZMVPerFrame(VObjects,QP_Encoder);
    
    QP_Encoder=51; OptComm_Encoder='A';
    QP_Classifier=QP_Encoder;OptComm_Classifier=OptComm_Encoder;
    VObjects=Stats_Load_Object_Function(QP_Encoder, OptComm_Encoder,FPS, VObjects);
    VObjects=Correct_Vector_Load_Object_Function(QP_Classifier, OptComm_Classifier, VObjects);
    VObjects=Correct_Vector_Spatial_Load_Object_Function(QP_Classifier, OptComm_Classifier, VObjects);
    VObjects=RateFrame_Load_Object_Function(QP_Encoder, OptComm_Encoder, FPS, VObjects);
    VObjects=ComputeNoTextureRatePerVideoFromFrame(VObjects,QP_Encoder);
    
    save('VObjects.mat','VObjects');
else
    load('VObjects.mat');
end

% %%Obtaining some average stats for all videos
% AvRate=[0 0 0 0];
% AvRateMotion=[0 0 0 0];
% AvRateNoTexture=[0 0 0 0];
% Accuracy=[0 0 0 0];
% Sparsity=[0 0 0 0];
% Density=[0 0 0 0];
% AvRm_o=[0 0 0 0];
% LSize=length(VObjects);
% cnt2=1;cnt3=1;cnt4=1;cnt5=1;
% for cnt1=1:LSize
%     AvRate=AvRate+VObjects(cnt1).Rate([1 3 4 5])/LSize;
%     AvRateMotion=AvRateMotion+VObjects(cnt1).RateMotion([1 3 4 5])/LSize;
%     AvRateNoTexture=AvRateNoTexture+VObjects(cnt1).RateNoTexture([1 3 4 5])/LSize;
%     Accuracy=Accuracy+VObjects(cnt1).Classified([1 3 4 5])/LSize;
%     Sparsity=Sparsity+VObjects(cnt1).Sparsity([1 3 4 5])/LSize;
%     Density=Density+VObjects(cnt1).P_MBs([1 3 4 5])/LSize;
%     VObjects(cnt1).Rm_o([1 3 4 5])=VObjects(cnt1).RateMotion([1 3 4 5])./VObjects(cnt1).Rate([1 3 4 5]);
%     VObjects(cnt1).S=(VObjects(cnt1).Rm_o(4)-VObjects(cnt1).Rm_o(5))/(VObjects(cnt1).RateNoTexture(4)-VObjects(cnt1).RateNoTexture(5));
%     AvRm_o=AvRm_o+VObjects(cnt1).Rm_o([1 3 4 5])/LSize;
% end

%%Separation of Variables - Histogram 3D CNN
%QPmain=40;QPmore=40;SeparateRmo(VObjects,QPmain,QPmore);
%QPmain=51;QPmore=40;SeparateRmoSlope(VObjects,QPmain,QPmore);
%QPmain=40;QPmore=40;SeparateSparsity(VObjects,QPmain,QPmore);

%%Separation of variables - Histogram dual CNN (2D &3D)
%QP1=30;SeparateRateMotion_2D_3D(VObjects,QP1);
%QP1=40;SeparateRateMotion_2D_3D(VObjects,QP1);
%QP1=40;SeparateRateMotion_2D_3D_Spatial(VObjects,QP1);

%QP1=30;SeparateActivity_2D_3D(VObjects,QP1);
%QP1=40;SeparateActivity_2D_3D(VObjects,QP1);

%%%Apply regression for more details (per frame features)
% QPreg=40;
% [b_TF_0,mdl_TF_0,Acc_TF_0]=Fitnlm_Object_RTotalFrame(VObjects, QPreg);
% [b_MF_0,mdl_MF_0,Acc_MF_0]=Fitnlm_Object_RMotionFrame(VObjects, QPreg);

%%%Apply regression for high level features
% QPreg=0;
% [b_All_0,mdl_All_0,Acc_All_0]=Fitnlm_Object_All(VObjects, QPreg);
% [b_NoActivity_0,mdl_NoActivity_0,Acc_NoActivity_0]=Fitnlm_Object_NoActivity(VObjects, QPreg);
% [b_RmotionActivity_0,mdl_RmotionActivity_0,Acc_RmotionActivity_0]=Fitnlm_Object_RmotionActivity(VObjects, QPreg);
% R(1,:)=[QPreg Acc_All_0 Acc_NoActivity_0 Acc_RmotionActivity_0];
% 
% QPreg=30;
% [b_All_30,mdl_All_30,Acc_All_30]=Fitnlm_Object_All(VObjects, QPreg);
% [b_NoActivity_30,mdl_NoActivity_30,Acc_NoActivity_30]=Fitnlm_Object_NoActivity(VObjects, QPreg);
% [b_RmotionActivity_30,mdl_RmotionActivity_30,Acc_RmotionActivity_30]=Fitnlm_Object_RmotionActivity(VObjects, QPreg);
% R(2,:)=[QPreg Acc_All_30 Acc_NoActivity_30 Acc_RmotionActivity_30];
% 
% QPreg=35;
% [b_All_35,mdl_All_35,Acc_All_35]=Fitnlm_Object_All(VObjects, QPreg);
% [b_NoActivity_35,mdl_NoActivity_35,Acc_NoActivity_35]=Fitnlm_Object_NoActivity(VObjects, QPreg);
% [b_RmotionActivity_35,mdl_RmotionActivity_35,Acc_RmotionActivity_35]=Fitnlm_Object_RmotionActivity(VObjects, QPreg);
% R(3,:)=[QPreg Acc_All_35 Acc_NoActivity_35 Acc_RmotionActivity_35];
% 
% QPreg=40;
% [b_All_40,mdl_All_40,Acc_All_40]=Fitnlm_Object_All(VObjects, QPreg);
% [b_NoActivity_40,mdl_NoActivity_40,Acc_NoActivity_40]=Fitnlm_Object_NoActivity(VObjects, QPreg);
% [b_RmotionActivity_40,mdl_RmotionActivity_40,Acc_RmotionActivity_40]=Fitnlm_Object_RmotionActivity(VObjects, QPreg);
% R(4,:)=[QPreg Acc_All_40 Acc_NoActivity_40 Acc_RmotionActivity_40];
% 
% QPreg=51;
% [b_All_51,mdl_All_51,Acc_All_51]=Fitnlm_Object_All(VObjects, QPreg);
% [b_NoActivity_51,mdl_NoActivity_51,Acc_NoActivity_51]=Fitnlm_Object_NoActivity(VObjects, QPreg);
% [b_RmotionActivity_51,mdl_RmotionActivity_51,Acc_RmotionActivity_51]=Fitnlm_Object_RmotionActivity(VObjects, QPreg);
% R(5,:)=[QPreg Acc_All_51 Acc_NoActivity_51 Acc_RmotionActivity_51];
% R
% 
% %pvalues=[mdl_All_0.Coefficients.pValue, mdl_All_30.Coefficients.pValue, mdl_All_40.Coefficients.pValue, mdl_All_51.Coefficients.pValue]
% %Estimates=[mdl_All_0.Coefficients.Estimate, mdl_All_30.Coefficients.Estimate, mdl_All_40.Coefficients.Estimate, mdl_All_51.Coefficients.Estimate]
% 
% pvalues=[mdl_All_0.p, mdl_All_30.p, mdl_All_40.p, mdl_All_51.p]
% Estimates=[b_All_0 b_All_30 b_All_40 b_All_51]
% 
 
