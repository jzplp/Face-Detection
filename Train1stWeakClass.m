function [HaarWeakClass,i]=Train1stWeakClass(num,num1,Integral,PicHeight,PicWidth)
%Train1stWeakClass为 弱分类器 第一次 训练函数
%HaarWeakClass Haar弱分类器结构体
%num为样本（图片）个数 num1为正例（人脸）个数
%Integral为积分图矩阵
%图片长度方向像素数PicHeight,图片长度方向像素数PicWidth 一般情况下两者相等;
%i为弱分类器计数值
%声明HaarWeakClass结构体 下面的赋值只为声明，没有实际含义
HaarWeakClass.theta=0;
HaarWeakClass.begin=[1,1];
HaarWeakClass.end=[1,1];
HaarWeakClass.st=[1,1];
HaarWeakClass.p=1;
HaarWeakClass.err=0;
i=1; %i为弱分类器计数值
s=1;t=2; %对于两矩形特征 s,t=1,2
[HaarWeakClass,i]=Train1stWeakClassST(HaarWeakClass,num,num1,Integral,PicHeight,PicWidth,s,t,i);
s=2;t=1; %对于两矩形特征 s,t=2,1
[HaarWeakClass,i]=Train1stWeakClassST(HaarWeakClass,num,num1,Integral,PicHeight,PicWidth,s,t,i);
s=1;t=3; %对于三矩形特征 s,t=1,3
[HaarWeakClass,i]=Train1stWeakClassST(HaarWeakClass,num,num1,Integral,PicHeight,PicWidth,s,t,i);
s=3;t=1; %对于三矩形特征 s,t=3,1
[HaarWeakClass,i]=Train1stWeakClassST(HaarWeakClass,num,num1,Integral,PicHeight,PicWidth,s,t,i);
s=2;t=2; %对于四矩形特征 s,t=3,1
[HaarWeakClass,i]=Train1stWeakClassST(HaarWeakClass,num,num1,Integral,PicHeight,PicWidth,s,t,i);
i=i-1;