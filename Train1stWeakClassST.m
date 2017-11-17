function [HaarWeakClass,i]=Train1stWeakClassST(HaarWeakClass,num,num1,Integral,PicHeight,PicWidth,s,t,i)
%Train1stWeakClassST为 对于不同的s.t条件的 弱分类器 第一次 训练函数
%HaarWeakClass Haar弱分类器结构体
%用整个HaarWeakClass矩阵调用
%num为样本（图片）个数 num1为正例（人脸）个数
%Integral为积分图矩阵
%Real(i) 样本i是否为正例（人脸）的标志 1为人脸，-1为非人脸
%图片长度方向像素数PicHeight,图片长度方向像素数PicWidth 一般情况下两者相等;
%i为弱分类器计数值
for x1=1:PicHeight-s+1
    for y1=1:PicWidth-t+1
        for x2=x1+s-1:s:PicHeight
            for y2=y1+t-1:t:PicWidth
                HaarWeakClass(i).begin=[x1 y1];
                HaarWeakClass(i).end=[x2,y2];
                HaarWeakClass(i).st=[s,t];
                HaarWeakClass(i)=Train1stOneWeakClass(HaarWeakClass(i),num,num1,Integral);
                i=i+1;
            end
        end
    end
end