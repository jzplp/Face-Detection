function [HaarWeakClass]=TrainOneWeakClass(HaarWeakClass,num,num1,Integral,SamWeight)
%一个弱分类器 训练函数
%HaarWeakClass Haar弱分类器结构体
%不要用整个HaarWeakClass矩阵调用，调用方式为HaarWeakClass(i)，返回值也赋给它。
%num为样本（图片）个数 num1为正例（人脸）个数
%Integral为积分图矩阵
%样本权重SamWeight

%计算特征值
%TempHaarF 为这一弱分类器对第i张图片的特征值f
%TempErr 此弱分类器的误差
TempErr=0;
for i=1:num
    %计算特征值
    TempHaarF=CalHaarValue(Integral(:,:,i),HaarWeakClass.begin(1),HaarWeakClass.begin(2),HaarWeakClass.end(1),HaarWeakClass.end(2),HaarWeakClass.st(1),HaarWeakClass.st(2));
    if i<=num1 %人脸样本标记为1
        TempY=1;
    else
        TempY=0; %非人脸样本标记为0 自己计算得：标记为-1的话判断正确也会有误差
    end
    if HaarWeakClass.p*TempHaarF < HaarWeakClass.p*HaarWeakClass.theta %判断为人脸
        TempHaarH=1;
    else
        TempHaarH=0;
    end
    %计算分类误差
    TempErr=TempErr+SamWeight(i)*abs(TempHaarH-TempY);
end
HaarWeakClass.err=TempErr;