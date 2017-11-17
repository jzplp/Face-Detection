clc,clear
%1.图片读取
%AllPictureRead 读取所有人脸样本函数
%num1为正例（人脸）个数，num2为负例（非人脸）个数
%PictureSam 样本图片矩阵
%PictureSam(:,:,i)为第i张图片
tic %Elapsed time is 6.823812 seconds.
[PictureSam,num,num1]=AllPictureRead();
toc
%图片长度方向像素数PicHeight,图片长度方向像素数PicWidth 一般情况下两者相等;
%num为样本总数
[PicHeight PicWidth num]=size(PictureSam);
%2.CalIntegral函数 计算积分图
tic %Elapsed time is 35.040152 seconds.
Integral=CalIntegral(PictureSam,num,PicHeight,PicWidth);
toc
%Integral为积分图矩阵
%Integral(:,:,i)为第i张图片的积分图
%清除没用的变量 节省空间
clear PictureSam

%----一般不用运行-----
%3.SumCalRect函数 求满足条件(s,t条件)的矩形总个数
%sum12 代表(s,t条件)为1,2的矩形个数
[RectNum,sum12,sum13,sum22]=SumCalRect(PicHeight,PicWidth);

%4.CalHaarValue函数 计算不同Haar特征的特征值
%(x1,y1)为矩形起始坐标，(x2,y2)为矩形终点坐标
%CalInteValue函数 根据积分图计算一个矩形的积分值

%HaarWeakClass Haar弱分类器结构体
%HaarWeakClass.theta 阈值
%HaarWeakClass.begin 特征窗口起始坐标 [x1,y1]
%HaarWeakClass.end 特征窗口终点坐标 [x2,y2]
%HaarWeakClass.st 特征矩形种类 [s,t](对应s,t条件)
%HaarWeakClass.p 不等式的方向 1或-1
%HaarWeakClass.err 分类误差
%i为弱分类器计数值
%Train1stOneWeakClass为 任一个弱分类器 第一次 训练函数
%第一次训练确定HaarWeakClass结构体de theta和p
tic %Elapsed time is 8566.878533 seconds.
[HaarWeakClass,WeakNum]=Train1stWeakClass(num,num1,Integral,PicHeight,PicWidth)
toc
%保存第一次训练的弱分类器到 1stOneWeakClass.mat
save 1stOneWeakClass HaarWeakClass WeakNum PicHeight PicWidth Integral num num1
%第一次训练完成 清除所有变量（有用的已经保存）
clear all

%--------训练300个弱分类器过程-------------
clc,clear
load 1stOneWeakClass Integral num num1 HaarWeakClass WeakNum
%样本权重SamWeight 初值为1/num
SamWeight=(1/num)*ones(1,num);
T=300; %T为循环次数，也是训练出的弱分类器个数
tic %Elapsed time is 586460.479390 seconds.
for x=1:T
    MinErrVal=Inf; %MinErrVal 最小分类误差
    MinErrNum=0;  %MinErrNum 最小分类误差对应的弱分类器标号
    for y=1:WeakNum
        HaarWeakClass(y)=TrainOneWeakClass(HaarWeakClass(y),num,num1,Integral,SamWeight);
        if MinErrVal>=HaarWeakClass(y).err
            MinErrVal=HaarWeakClass(y).err;
            MinErrNum=y;
        end
    end
    %OptWeak(x) 为第x次遍历寻找出的最优弱分类器
    OptWeak(x)=HaarWeakClass(MinErrNum);
    %在弱分类器数组中清除它
    HaarWeakClass(MinErrNum)=[];
    %弱分类器数组长度减一
    WeakNum=WeakNum-1;
    Beta=OptWeak(x).err/(1-OptWeak(x).err);
    %弱分类器的权值
    WaekWeight(x)=log(1/Beta);
    %更新样本权值
    for i=1:num
        %计算特征值
        TempHaarF=CalHaarValue(Integral(:,:,i),OptWeak(x).begin(1),OptWeak(x).begin(2),OptWeak(x).end(1),OptWeak(x).end(2),OptWeak(x).st(1),OptWeak(x).st(2));
        if i<=num1 %人脸样本标记为1
            TempY=1;
        else
            TempY=0; %非人脸样本标记为0 自己计算得：标记为-1的话判断正确也会有误差
        end
        if OptWeak(x).p*TempHaarF < OptWeak(x).p*OptWeak(x).theta %判断为人脸
            TempHaarH=1;
        else
            TempHaarH=0;
        end
        if TempY==TempHaarH %若判断正确
            SamWeight(i)=SamWeight(i)*Beta; %就降低权值
        end
    end
    %样本权值归一化
    SamWeight=SamWeight./sum(SamWeight);
end
toc

tic %Elapsed time is 15.184293 seconds.
%求每个最优弱分类器对所有样本的判断输出
%JudgOut(x,i) 第x个最优弱分类器对第i个样本的输出
for x=1:T %T个最优弱分类器
    for i=1:num
        %计算特征值
        TempHaarF=CalHaarValue(Integral(:,:,i),OptWeak(x).begin(1),OptWeak(x).begin(2),OptWeak(x).end(1),OptWeak(x).end(2),OptWeak(x).st(1),OptWeak(x).st(2));
        if OptWeak(x).p*TempHaarF < OptWeak(x).p*OptWeak(x).theta %判断为人脸
             JudgOut(x,i)=1;
        else
            JudgOut(x,i)=0;
        end
    end
end
toc

%保存有用的变量在FinishWeak.mat中
%OptWeak(x) 为第x次遍历寻找出的最优弱分类器
%WaekWeight(x) 第x个弱分类器的权值
%JudgOut(x,i) 第x个最优弱分类器对第i个样本的输出
%T为训练出的弱分类器个数
save FinishWeak OptWeak WaekWeight JudgOut T
save FinishWeakTemp SamWeight
%清除所有变量
clear all
%-----------

clc,clear
%级联分类器训练过程 
load FinishWeak OptWeak WaekWeight JudgOut T
load 1stOneWeakClass Integral num num1
tic %Elapsed time is 1.033488 seconds.
%DivPRMin 每层强分类器的最小检测率 
DivPRMin=0.925;
%DivFPRMax 每层强分类器的最大误检率 
DivFPRMax=0.5;
%WholeFPR 要求整个分类器的误检率 
WholeFPR=0.001;
%StrongClass 强分类器结构
%StrongClass.weak(i) 强分类器中的第i个弱分类器
%StrongClass.weakweight(i) 强分类器中的第i个弱分类器的权值
%StrongClass.weaknum 强分类器中的弱分类器个数(没有这个)
%StrongClass.pass 弱分类器的组合值若大于此值，便判断为人脸样本
%StrongClass.PR 强分类器对于训练样本的最终检测率
%StrongClass.FPR 强分类器对于训练样本的最终误检率
%StrongClass.num(i) 强分类器包含的弱分类器编号（在OptWeak中的编号）
MinWeakNum=3; %每一级强分类器所具有的最小弱分类器个数
CurFPR=1; %当前整个分类器的误检率
CurPR=1; %当前整个分类器的检测率
i=1; %i为当前强分类器的编号
WeakI=0;  %i为当前弱分类器的编号
LackFlag=0; %缺少弱分类器标志 若没有足够的弱分类器可用 LackFlag=1
while CurFPR>WholeFPR | i<=13 %若当前整个分类器的误检率达不到要求 且强分类器数量小于等于5个
    weaknum=0; %weaknum为当前强分类器具有的弱分类器个数
    CurDivPRMin=0; %当前强分类器的检测率
    CurDivFPRMax=1; %当前强分类器的误检率
    while CurDivPRMin<DivPRMin | CurDivFPRMax>DivFPRMax
        %给强分类器增加弱分类器过程
        if weaknum==0 %初始的分类器个数
            if WeakI+MinWeakNum>T
                LackFlag=1; %若没有足够的弱分类器可用
                break; 
            end
            StrongClass(i).weak=OptWeak(WeakI+1:WeakI+MinWeakNum);
            StrongClass(i).weakweight=WaekWeight(WeakI+1:WeakI+MinWeakNum);
            StrongClass(i).num=WeakI+1:WeakI+MinWeakNum;
            WeakI=WeakI+MinWeakNum;
            weaknum=MinWeakNum;
        else
            if WeakI+1>T %若没有足够的弱分类器可用
                LackFlag=1;
                break;
            end
            %在此强分类器中增加一个弱分类器
            StrongClass(i).weak=[StrongClass(i).weak OptWeak(WeakI+1)];
            StrongClass(i).weakweight=[StrongClass(i).weakweight WaekWeight(WeakI+1)];
            WeakI=WeakI+1;
            weaknum=weaknum+1;
            StrongClass(i).num=[StrongClass(i).num WeakI];
        end
        %计算强分类器的各类性能参数过程
        StrongClass(i).pass=0.5*sum(StrongClass(i).weakweight);
        %StrongWeakJudg 强分类器样本判断输出函数
        [CurDivPRMin,CurDivFPRMax]=StrongWeakJudg(StrongClass(i),JudgOut,num,num1);
    end
    if LackFlag==1 %若没有足够的弱分类器可用,则结束程序
        WARNING='没有足够的弱分类器可用,结束程序！'
            break;
    end
    StrongClass(i).PR=CurDivPRMin;
    StrongClass(i).FPR=CurDivFPRMax;
    CurFPR=CurFPR*StrongClass(i).FPR;
    CurPR=CurPR*StrongClass(i).PR;
    i=i+1;
end
toc
%保存级联分类器
%StrongClass 强分类器结构
%CurPR 整个分类器对于测试样本的检测率
%CurFPR 整个分类器对于测试样本的误检率
save FinishStrong StrongClass CurPR CurFPR
%清除所有变量
clear all

%-----300弱分类器组成一个强分类器
NNN=300; %唯一一个强分类器中弱分类器个数
load FinishWeak OptWeak WaekWeight JudgOut
load 1stOneWeakClass num num1
StrongClass(1).weak=OptWeak(1:NNN);
StrongClass(1).weakweight=WaekWeight(1:NNN);
StrongClass(1).num=1:NNN;
%计算强分类器的各类性能参数过程
StrongClass(i).pass=0.5*sum(StrongClass(i).weakweight);
%StrongWeakJudg 强分类器样本判断输出函数
[CurDivPRMin,CurDivFPRMax]=StrongWeakJudg(StrongClass(i),JudgOut,num,num1);
StrongClass(i).PR=CurDivPRMin;
StrongClass(i).FPR=CurDivFPRMax;

%-----级联分类器 检测过程
clc,clear
tic
TrainPicSize=20; %训练时图片尺寸
for i=301:450
    if i<10
        PictureName=['faces_test\image_000' num2str(i) '.jpg']; 
    elseif i<100
        PictureName=['faces_test\image_00' num2str(i) '.jpg'];
    else
        PictureName=['faces_test\image_0' num2str(i) '.jpg'];
    end
    %Test函数 检测人脸函数
    [SimpleOut,OutPut]=Test(PictureName,TrainPicSize);
    %-----显示标记人脸后的图片
    %图像窗口序号1
    figure(1);  
    %打开原图
    PictureTemp=imread(PictureName);
    %显示图片
    imshow(PictureTemp);
    %如果没有任何人脸窗口 就检测下一个图像
    if isempty(SimpleOut)
        continue;
    end
    
    hold on
    %显示拼合后的检测窗口
    for x=1:length(OutPut)  
        %在标记窗口处画一个矩形 （红色）
        rectangle('position',[OutPut(x).begin(2),OutPut(x).begin(1),OutPut(x).end(2)-OutPut(x).begin(2)+1,OutPut(x).end(1)-OutPut(x).begin(1)+1],'Edgecolor','r');
    end
    hold off
    %拼合后的检测窗口保存在OutPut文件夹中
    print(1,'-djpeg',['OutPut/' num2str(i) '.jpeg']);
    %关闭图像窗口
    close
    
    %图像窗口序号1
    figure(1);
    imshow(PictureTemp);
    hold on
    %显示拼合前的检测窗口
    for x=1:length(SimpleOut) 
        rectangle('position',[SimpleOut(x).begin(2),SimpleOut(x).begin(1),SimpleOut(x).end(2)-SimpleOut(x).begin(2)+1,SimpleOut(x).end(1)-SimpleOut(x).begin(1)+1],'Edgecolor','r');
    end
    hold off
    %拼合后的检测窗口保存在OutPut文件夹中
    print(1,'-djpeg',['SimpleOut/' num2str(i) '.jpeg']);
    %关闭图像窗口
    close
end
toc