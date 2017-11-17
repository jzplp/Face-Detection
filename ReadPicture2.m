function [FacePicture]=ReadPicture2(CharP,num,begin)
%图片读取的第二种函数
%num为图片个数
%CharP为图片前缀
%begin为图片文件名计数起始值
FacePicture=[];
for i=begin:begin+num-1
    %PictureName为要读取的文件名
    PictureName=[CharP num2str(i) '.bmp'];
    PictureTemp=imread(PictureName);
    %bmp格式读取的有RGB值，但图片为灰度，RGB值相同，故只取R值
    PictureTemp=PictureTemp(:,:,1);
    %FacePicture为原始人脸图片矩阵
    %FacePicture(:,:,i)为第i张图片
    FacePicture=cat(3,FacePicture,PictureTemp);
end