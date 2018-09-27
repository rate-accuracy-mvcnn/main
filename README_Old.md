# main

## AVC/H.264 Cropped Bitstream

To produce cropped Bitstream use
./JM_Cropped_MV_Stats -svid <source video>

Options:
Various encoding parameters can be set directly such as
   --ecfg   JM configuration file
   -svid    input video
   --qp     qP value for P and I frames
   --sr     search range
   --res    resolution of the MB Grid (4,8,16)
   
Outputs:
1- Cropped JM bitstream
2- MV.bin file where MV values are mapped to a grid according to the correspodning MB position
3- States (including rate) per frame for the cropped bitstream
4- Summary of states for the cropped bitstream
5- States (including rate) per frame for the bitstream produced by the original JM encoder
6- Summary of states for the original JM bitstream

Sample Output:
%########################################################################################
JM config file=encoder_option2.cfg, Source Video=v_BoxingPunchingBag_g05_c01.avi, QP=40, Search Range=16, MV Resolution=8
%########################################################################################
Converting source video to YUV format
Producing cropped H.264 bitstream (encoder)
Extracting MVs from the cropped H.264 bitstream (decoder)
Original JM: encoding to produce rate (bps) per frame (optional) 
Mapping MV to a grid according to Macroblocks positions
Moving outputs to JMMV parent directory

----------------------------------------------------------------
## HEVC/H.265 Cropped Bitstream

To produce cropped Bitstream use
./HM_Cropped_MV_Stats -svid <source video>

Options:
Various encoding parameters can be set directly such as
   --ecfg   HM configuration file
   -svid    input video
   --qp     qP value for P and I frames
   --mcu    maximum CTU size
   --mpd    maximum partition depth
   --sr     search range
   --res    resolution of the MB Grid (4,8,16)
   
Outputs:
1- Cropped HM bitstream
2- Original HM bitstream
3- MV.bin file where MV values are extracted from cropped HM bitstream and mapped to a grid according to the correspodning CU position
4- Summary of states for the cropped bitstream
5- Summary of states for the original HM bitstream

Sample Output:
%########################################################################################
HM config file=encoder_Jubran.cfg, Source Video=v_BoxingPunchingBag_g05_c01.avi, QP=24, Max CU Size=16, Max Partition Depth=2, Search Range=16, MV Resolution=8
%########################################################################################
Converting source video to YUV format
Producing cropped HEVC bitstream (encoder)
Extracting MVs from the cropped HEVC bitstream (decoder)
Original HM: encoding and then decoding to produce rates and stats (optional)
Moving outputs to HMMV parent directory

----------------------------------------------------------
## Multi-CNN Framework
To produce the data required to evaluate the Multi-CNN on UCF-101 Split0:
1-Edit the header of the MultiProcessGenerateJMMVComputeSaveOrigin shell script to specify the video coding parameters of the JM codec.
2-Edit the header of the  GenerateAndComputeSizeRatio-UCF-Split-1 shell script to specify the path of folder that includes all original UCF videos.
3-Run the MultiProcessGenerateJMMVComputeSaveOrigin script, this will produce three output files per input video stored in parent directly called JMMV. These files are
   a.MV.bins: contain the MV pairs for each encoding block, 
   b.Orig Stats file: text file that includes statics and information of encoding the video using the standard JM codec
   c.No Texture Stats file: text file that includes statics and information of producing the cropped bitstream
4-Edit the header and then run the CollectStatsPerVideo_UCF script. This will collect the statistics and rate information from “Orig Stats file” and “No Texture Stats file” of al videos and write it in one Stats_Orig_NOTexture output file.
5-Samples of these files for UCF-101 Test split is included in the Multi-CNN/DataFiles folder.
6-Get the correct decision vectors from the CNN model
7-To load the stats and decision vectors per video run the MainCreateProcessVideoObjects.m file. This will create separate object for each video with attributed based on the stats  and decision vectors files.
8-Edit the header and then run the AnalyticalMultiCNN_shortGamma_Rmotion.m to get the Multi-CNN threshold values (R_L and R_H). You will also get expected classification accuracy and required rate of Multi-CNN based on these threshold values.
