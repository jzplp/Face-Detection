function [InteValue]=CalHaarValue(Integral,x1,y1,x2,y2,s,t)
%计算不同Haar特征的特征值
%(x1,y1)为矩形起始坐标，(x2,y2)为矩形终点坐标
%Integral为该样本积分图矩阵
%CalInteValue为根据积分图计算一个矩形的积分值
%Haar特征满足不同的(s,t条件)
if s==1 & t==2 %对于两矩形特征 s,t=1,2
    WhiteSum=CalInteValue(Integral,x1,y1,x2,y1+floor((y2-y1)/2));
    BlackSum=CalInteValue(Integral,x1,y1+floor((y2-y1)/2)+1,x2,y2);
elseif s==2 & t==1 %对于两矩形特征 s,t=2,1
    WhiteSum=CalInteValue(Integral,x1,y1,x1+floor((x2-x1)/2),y2);
    BlackSum=CalInteValue(Integral,x1+floor((x2-x1)/2)+1,y1,x2,y2);
elseif s==1 & t==3 %对于三矩形特征 s,t=1,3
    WhiteSum=CalInteValue(Integral,x1,y1,x2,y1+(y2-y1+1)/3-1);
    BlackSum=CalInteValue(Integral,x1,y1+(y2-y1+1)/3,x2,y1+((y2-y1+1)/3)*2-1);
    WhiteSum=WhiteSum+CalInteValue(Integral,x1,y1+((y2-y1+1)/3)*2,x2,y2);
elseif s==3 & t==1 %对于三矩形特征 s,t=3,1
    WhiteSum=CalInteValue(Integral,x1,y1,x1+(x2-x1+1)/3-1,y2);
    BlackSum=CalInteValue(Integral,x1+(x2-x1+1)/3,y1,x1+((x2-x1+1)/3)*2-1,y2);
    WhiteSum=WhiteSum+CalInteValue(Integral,x1+((x2-x1+1)/3)*2,y1,x2,y2);
else %对于四矩形特征 s,t=2,2
    WhiteSum=CalInteValue(Integral,x1,y1,x1+floor((x2-x1)/2),y1+floor((y2-y1)/2));
    WhiteSum=WhiteSum+CalInteValue(Integral,x1+floor((x2-x1)/2)+1,y1+floor((y2-y1)/2)+1,x2,y2);
    BlackSum=CalInteValue(Integral,x1,y1+floor((y2-y1)/2)+1,x1+floor((x2-x1)/2),y2);
    BlackSum=BlackSum+CalInteValue(Integral,x1+floor((x2-x1)/2)+1,y1,x2,y1+floor((y2-y1)/2));
end
InteValue=WhiteSum-BlackSum;
     
    