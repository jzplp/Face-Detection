function [InteValue]=CalInteValue(Integral,x1,y1,x2,y2)
%计算一个窗口的积分值
%Integral为该样本积分图矩阵
%(x1,y1)为矩形起始坐标，(x2,y2)为矩形终点坐标
if x1~=1 & y1~=1
    InteValue=Integral(x2,y2)+Integral(x1-1,y1-1)-Integral(x1-1,y2)-Integral(x2,y1-1);
elseif y1~=1
    InteValue=Integral(x2,y2)-Integral(x2,y1-1);
elseif x1~=1
    InteValue=Integral(x2,y2)-Integral(x1-1,y2);
else
    InteValue=Integral(x2,y2);
end