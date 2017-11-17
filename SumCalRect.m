function [RectNum,sum12,sum13,sum22]=SumCalRect(PicHeight,PicWidth)
%求满足条件(s,t条件)的矩形个数,CalRectNum为矩形特征计算函数
s=1;t=2; %对于两矩形特征
sum12=CalRectNum(s,t,PicHeight,PicWidth);
s=1;t=3;%对于三矩形特征
sum13=CalRectNum(s,t,PicHeight,PicWidth);
s=2;t=2;%对于四矩形特征
sum22=CalRectNum(s,t,PicHeight,PicWidth);
%总矩形个数
RectNum=sum12*2+sum13*2+sum22;