function [VObjects]=Compute_Load_Object_NZMVPerFrame(VObjects,QP)
%clear all;
%QP=40;
fprintf('Loading NZMV per Frame for QP=%2d',QP);
L=find(VObjects(1).QP==QP);

numFrame=500;

fid = fopen('testlist01.txt','r');
tline = fgetl(fid);
tline_2ndpart=tline((find(tline=='/')+1):(find(tline=='.')-1));
FNames=tline_2ndpart;
cnt1=1;
QP1=QP;
T=1;
play_jm_QP1=0;
if ~exist(strcat('NZMV_QP',num2str(QP),'.mat'))
    %load(strcat('NZMV_QP',numstr(QP),'.mat'),'FNames','NZMV');
    while ~isempty(tline_2ndpart)
        if cnt1>length(NZMV)
            clear mv_data_jm jmdx jmdy;
            filename_jm_QP1=strcat('..\JMMV_Test01_QP',num2str(QP1),'_MVSR16_MVRes8_A\rgb24_',tline_2ndpart,'.bin');
            
            if ~exist(filename_jm_QP1)
                fprintf('%s does not exist\n',filename_jm_QP1);
            else
                %% loadinng JM MVs for QP1
                [mv_data_jm_QP1, framePts_QP1, frameInd_QP1, frameType_QP1] = load_mv(filename_jm_QP1,T, play_jm_QP1);
                numFrame_jm_QP1 = size(mv_data_jm_QP1,3);
                jmdx_QP1 = mv_data_jm_QP1(1:end/2, :, 1:numFrame_jm_QP1);
                jmdy_QP1 = mv_data_jm_QP1((end/2)+1:end, :, 1:numFrame_jm_QP1);
            end
            
            clear FNames_temp;
            FNames_temp=tline_2ndpart;
            while length(FNames_temp)>size(FNames,2)
                L=size(FNames,1);
                for i=1:L
                    A(i,:)=char(zeros(1,length(FNames_temp)-size(FNames,2)));
                end
                FNames=[FNames A];
            end
            FNames(cnt1,1:length(FNames_temp))=FNames_temp;
            NZMV(cnt1)=(length(find(abs(jmdx_QP1)))+length(find(abs(jmdy_QP1))))/numFrame_jm_QP1;
            
            tline = fgetl(fid);
            tline_2ndpart=tline((find(tline=='/')+1):(find(tline=='.')-1));
            cnt1=cnt1+1
            save(strcat('NZMV_QP',num2str(QP),'.mat'),'FNames','NZMV');
            
        else
            tline = fgetl(fid);
            tline_2ndpart=tline((find(tline=='/')+1):(find(tline=='.')-1));
            cnt1=cnt1+1
        end
    end
end

load(strcat('NZMV_QP',numstr(QP),'.mat'),'FNames','NZMV');

for i=1:length(VObjects)
    for j=1:length(NZMV)
        Len=min(length(VObjects(i).Filename),length(FNames(j,:)));
        if strcmp(VObjects(i).Filename(1:Len),FNames(j,1:Len))
            VObjects(i).NZMV(L)=NZMV(j);
        end
    end
end
fprintf(' ....... Done \n');
