classdef VideoObjectClass
    %UNTITLED5 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Id
        Filename
        QP=[];
        NoFrames=[0 0 0 0];
        Rate=[0 0 0 0];
        RateMotion=[0 0 0 0];
        RateNoTexture=[0 0 0 0];
        RateNoTextureExcept1stFrame=[0 0 0 0];
        Sparsity=[0 0 0 0];
        P_MBs=[0 0 0 0];
        PSNR=[0 0 0 0];
        MSE=[0 0 0 0];
        NZMV=[0 0 0 0];
        Dynamicity=[0 0 0 0]
        Classified=[0 0 0 0];
        Classified_2D=[0 0 0 0];
        Classified_Spatial=[0 0 0 0];
        Classified_2D_Fusion=[0 0 0 0];
        Classified_3D_Fusion=[0 0 0 0];
        FrameRateTotalOrig=[];
        FrameRateTotalNoTexture=[];
        FrameRateMotionOrig=[];
        FrameRateMotionNoTexture=[];
        VarFrameRateTotalOrig=[0 0 0 0];
        VarFrameRateMotionOrig=[0 0 0 0];
        PerFrameFeatures=[];
        Rm_o
        S
        D
        Combined=[0 0 0 0 0];
    end
    
    methods
        function thisVideoObjectClass = VideoObjectClass(X,Y,Z)
            if nargin==2
                thisVideoObjectClass.Id=X;
                thisVideoObjectClass.Filename=Y;
            end
        end
    end
end