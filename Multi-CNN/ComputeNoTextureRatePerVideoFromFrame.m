function [VObjects]=ComputeNoTextureRatePerVideoFromFrame(VObjects,QP)

%QP=40;
IndexQP=find(VObjects(1).QP==QP);
for cnt1=1:length(VObjects)
VObjects(cnt1).RateNoTexture(IndexQP)=mean(VObjects(cnt1).FrameRateTotalNoTexture(IndexQP,:));
VObjects(cnt1).Rate(IndexQP)=mean(VObjects(cnt1).FrameRateTotalOrig(IndexQP,:));
end