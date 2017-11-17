function [FacePicture]=ReadPicture(CharP,num,begin)
%图片读取
%num为图片个数
%CharP为图片前缀
%begin为图片文件名计数起始值
FacePicture=[];
for i=begin:begin+num-1
    if i<10
        %PictureName为要读取的文件名
        PictureName=[CharP '0000' num2str(i) '.bmp'];
    elseif i<100
            PictureName=[CharP '000' num2str(i) '.bmp'];
    elseif i<1000
        PictureName=[CharP '00' num2str(i) '.bmp'];
    else
        PictureName=[CharP '0' num2str(i) '.bmp'];
    end
    PictureTemp=imread(PictureName);
    %bmp格式读取的有RGB值，但图片为灰度，RGB值相同，故只取R值
    PictureTemp=PictureTemp(:,:,1);
    %FacePicture为原始人脸图片矩阵
    %FacePicture(:,:,i)为第i张图片
    FacePicture=cat(3,FacePicture,PictureTemp);
end