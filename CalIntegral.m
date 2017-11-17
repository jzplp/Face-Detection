function [Integral]=CalIntegral(FacePicture,num,PicHeight,PicWidth)
%计算积分图
Integral=[];
%Integral为积分图矩阵
%Integral(:,:,i)为第i张图片的积分图
%由于FacePicture是uint8，计算时要先转换成double类型 
for i=1:num
    Integral(1,1,i)=double(FacePicture(1,1,i)); %第一个元素
    for j=2:PicHeight %最上面一行元素
        Integral(j,1,i)=Integral(j-1,1,i)+double(FacePicture(j,1,i));
    end
    for z=2:PicWidth %最左边一列元素
        Integral(1,z,i)=Integral(1,z-1,i)+double(FacePicture(1,z,i));
    end
    for j=2:PicHeight %剩下的元素
        for z=2:PicWidth
            Integral(j,z,i)=Integral(j-1,z,i)+Integral(j,z-1,i)+double(FacePicture(j,z,i))-Integral(j-1,z-1,i);
        end
    end
end