function [HaarWeakClass]=Train1stOneWeakClass(HaarWeakClass,num,num1,Integral)
%一个弱分类器 第一次 训练函数
%HaarWeakClass Haar弱分类器结构体
%不要用整个HaarWeakClass矩阵调用，调用方式为HaarWeakClass(i)，返回值也赋给它。
%num为样本（图片）个数 num1为正例（人脸）个数
%Integral为积分图矩阵

%计算特征值
%TempHaarF(i) 为这一弱分类器对第i张图片的特征值f
for i=1:num
    TempHaarF(i)=CalHaarValue(Integral(:,:,i),HaarWeakClass.begin(1),HaarWeakClass.begin(2),HaarWeakClass.end(1),HaarWeakClass.end(2),HaarWeakClass.st(1),HaarWeakClass.st(2));
end

%对求出的所有样本对于这一分类器的特征值排序，
%排序结果TempSort，排序之后的原序号TempSortOrd 
%sort函数用降序排序
[TempSort,TempSortOrd]=sort(TempHaarF);

%全部人脸样本的权重的和TempT1
TempT1=num1/num;
%全部非人脸样本的权重的和TempT1
TempT0=(num-num1)/num;
%在此元素之前的非人脸样本的权重的和TempS0
TempS0=0;
%在此元素之前的人脸样本的权重的和TempS1
TempS1=0;
%TempHaarErr(i) 为这一弱分类器对“排序好”的第i张图片的err
for i=1:num
    TempErr(i)=min([TempS1+TempT0-TempS0 TempS0+TempT1-TempS1]);
    if TempErr(i)==(TempS1+TempT0-TempS0)
        %个人解释：(S1+T0-S0)-(S0+T1-S1)=2(S1-S0)+(T0-T1)，
        %设T0=T1(人脸样本=非人脸样本)，
        %若S1-S0<0,（特征值低时非人脸样本多) TempErr(i)取(S1+T0-S0)表示不等式方向的p=-1
        TempFlagP(i)=-1;
    else %Err(i)==(TempS0+TempT1-TempS1)
        %若S1-S0>0,（特征值低时人脸样本多)，TempErr(i)取(S0+T1-S1)，表示不等式方向的p=1
        TempFlagP(i)=1;
    end
    if TempSortOrd(i)<=num1 %样本TempSortOrd(i)为人脸
        TempS1=TempS1+1/num;
    else %样本TempSortOrd(i)为非人脸
        TempS0=TempS0+1/num;
    end
end
%求出最小的分类误差MinVal,和对应在排序结果TempSort的标号MinI
[MinVal,MinI]=min(TempErr);
HaarWeakClass.theta=TempSort(MinI); 
HaarWeakClass.p=TempFlagP(MinI);