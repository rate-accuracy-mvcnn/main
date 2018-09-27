function [FNames ,FrameNumberRateArray]=RateFrame_Load_Function(filename)


ToPrint=0;
%% Load file contents ...
fid = fopen(filename,'r') ;
tline = fgetl(fid);
NumFrames=1000;
cnt2=1;
ReadArray=[];
FNames=blanks(1);
WriteFileName=0;
while ischar(tline)
    %disp(tline)
    NumaricLine=double(tline)-48;
    cnt1=1;
    cnt3=1;
    SizeArrayTemplate=zeros(1,1000);
    ReadArray=[ReadArray;SizeArrayTemplate];
    for l=1:length(NumaricLine)
        if ( NumaricLine(l)== -16 )
            if cnt1==1
                NumFrames=ReadArray(cnt2,cnt1)+3;
            end
            cnt1=cnt1+1;
        else
            if (cnt1 < NumFrames)
                ReadArray(cnt2,cnt1)=ReadArray(cnt2,cnt1)*10+NumaricLine(l);
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
    tline = fgetl(fid);
    cnt2=cnt2+1;
    cnt3=1;
    WriteFileName=0;
end
fclose(fid);

FrameNumberRateArray=ReadArray;