function [VObjects]=Correct_Vector_Temporal_Load_Object_Function(QP_Classifier, OptComm_Classifier, VObjects)

%QP_Encoder=40; OptComm_Encoder='A';
%QP_Classifier=QP_Encoder;OptComm_Classifier=OptComm_Encoder;


filename_Filename=strcat('DataFiles/filenames_Temporal_',OptComm_Classifier,'_QP',num2str(QP_Classifier));
filename_Classifier=strcat('DataFiles/correct_vec_Temporal_',OptComm_Classifier,'_QP',num2str(QP_Classifier));

QP=QP_Classifier;
fprintf('Loading Classification Temporal Vectore for QP=%2d',QP);
%% Load file contents ...
fid1 = fopen(filename_Filename,'r');
fid2 = fopen(filename_Classifier,'r');
cnt=1;
tline1 = fgetl(fid1);
tline2 = fgetl(fid2);
FNames=tline1(7:end-4);
Classified=double(tline2)-48;
while ( ischar(tline1) & ischar(tline2) )
    tline1 = fgetl(fid1);
    tline2 = fgetl(fid2);
    FNames_temp=tline1(7:end-4);
    while length(FNames_temp)>size(FNames,2)
        L=size(FNames,1);
        for i=1:L
            A(i,:)=char(zeros(1,length(FNames_temp)-size(FNames,2)));
        end
        FNames=[FNames A];
    end
    FNames(cnt,1:length(FNames_temp))=FNames_temp;
    Classified(cnt)=double(tline2)-48;
    cnt=cnt+1;
end
FNames=FNames(1:(size(FNames)-1),:);
Classified=Classified(1:(end-1))';
fclose(fid1);
fclose(fid2);

sum(sum(Classified));
QPObject=VObjects(1).QP;
L=find(QP==QPObject);
for i=1:length(VObjects)
    for j=1:length(Classified)
        Len=min(length(VObjects(i).Filename),length(FNames(j,:)));
        if strcmp(VObjects(i).Filename(1:Len),FNames(j,1:Len))
            VObjects(i).Classified_Temporal(L)=Classified(j);
        end
    end
end

fprintf(' ....... Done \n');

