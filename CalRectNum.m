function [sum]=CalRectNum(s,t,PicHeight,PicWidth)
%求满足条件(s,t条件)的矩形个数
%图片长度方向像素数PicHeight,图片长度方向像素数PicWidth 一般情况下两者相等
sum=0; %矩形个数
for x1=1:PicHeight-s+1
    for y1=1:PicWidth-t+1
        sum=sum+floor((PicHeight-x1+1)/s)*floor((PicWidth-y1+1)/t);
    end
end