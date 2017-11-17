%Temp.m
%3.1.2节会用到
%弱分类器的例子 显示他的各项数据和说明

load FinishWeak OptWeak JudgOut
load 1stOneWeakClass num num1
%显示弱分类器
TempWaek=OptWeak(3)
TempPicture=imread('faces\face00005.bmp');
imshow(TempPicture);
hold on
%画出st=12的Haar特征的矩形
rectangle('position',[TempWaek.begin(2),TempWaek.begin(1),floor((TempWaek.end(2)-TempWaek.begin(2))/2)+1,TempWaek.end(1)-TempWaek.begin(1)+1],'Edgecolor','r');
rectangle('position',[TempWaek.begin(2)+floor((TempWaek.end(2)-TempWaek.begin(2))/2)+1,TempWaek.begin(1),floor((TempWaek.end(2)-TempWaek.begin(2))/2)+1,TempWaek.end(1)-TempWaek.begin(1)+1],'Edgecolor','g');

load 1stOneWeakClass Integral
%Y_N表示判断为人脸,实际也为人脸的样本
Y_Y=0;
%Y_N表示判断为人脸,实际为非人脸的样本
Y_N=0;
%N_Y表示判断为非人脸,实际为人脸的样本
N_Y=0;
%N_N表示判断为非人脸,实际为非人脸的样本
N_N=0;
for i=1:num
    TempHaarF=CalHaarValue(Integral(:,:,i),TempWaek.begin(1),TempWaek.begin(2),TempWaek.end(1),TempWaek.end(2),TempWaek.st(1),TempWaek.st(2));
    if TempHaarF <  TempWaek.theta
        if i<=num1
            Y_Y=Y_Y+1;
        else
            Y_N=Y_N+1;
        end
    else
        if i<=num1
            N_Y=N_Y+1;
        else
            N_N=N_N+1;
        end
    end
end
Y_Y,Y_N,N_Y,N_N,num1,num-num1

%3.3节会用到
%训练弱分类器的例子 加权分类误差和判断正确的样本个数
load FinishWeak OptWeak JudgOut
load 1stOneWeakClass num num1
load 1stOneWeakClass Integral
for x1=1:10
    OptWeak(x1).err
    %Y_N表示判断正确的样本个数
    Y_Y=0;
    %Y_N表示判断错误的样本个数
    Y_N=0;
    for i=1:num
        TempHaarF=CalHaarValue(Integral(:,:,i),OptWeak(x1).begin(1),OptWeak(x1).begin(2),OptWeak(x1).end(1),OptWeak(x1).end(2),OptWeak(x1).st(1),OptWeak(x1).st(2));
        if OptWeak(x1).p*TempHaarF <  OptWeak(x1).p*OptWeak(x1).theta
            if i<=num1
                Y_Y=Y_Y+1;
            else
                Y_N=Y_N+1;
            end
        else
            if i<=num1
                N_Y=N_Y+1;
            else
                N_N=N_N+1;
            end
        end
    end
Y_Y=Y_Y+N_N
Y_N=Y_N+N_Y
end

%3.4.1节 强分类器举例
%看强分类器拥有的弱分类器数越多时对于训练样本的辨别能力
load FinishWeak OptWeak WaekWeight JudgOut T
load 1stOneWeakClass num num1
for i=1:T
     StrongClass.weak=OptWeak(1:i);
     StrongClass.weakweight=WaekWeight(1:i);
     StrongClass.pass=0.5*sum(StrongClass.weakweight);
     TempJudgArr=zeros(1,num);
    %计算强分类器对于每个样本的“特征值” TempJudgArr(x)
    for x1=1:length(StrongClass.weak)
        for x2=1:num
            TempJudgArr(x2)=TempJudgArr(x2)+StrongClass.weakweight(x1).*JudgOut(x1,x2);
        end
    end
    TempP(i)=0; %正确检测的样本数
    TempFP(i)=0; %误检的样本数
    for x=1:num
        if x<=num1
            if TempJudgArr(x)>=StrongClass.pass
                TempP(i)=TempP(i)+1;
            else
                TempFP(i)=TempFP(i)+1;
            end
        else
            if TempJudgArr(x)>=StrongClass.pass
                TempFP(i)=TempFP(i)+1;
            else
                TempP(i)=TempP(i)+1;
            end
        end
    end
    TempP(i)=TempP(i)/num;
    TempFP(i)=TempFP(i)/num;
end
plot(TempP)
xlabel('弱分类器个数');
ylabel('检测率');

%4.1节 图像的预处理
%直方图均衡示例
PictureName='1.jpg';
%读取图片
PictureTemp=imread(PictureName);
%转化为灰度
PictureTemp=rgb2gray(PictureTemp);
imshow(PictureTemp)
%对灰度图进行直方图均衡
PictureTemp=histeq(PictureTemp);
imshow(PictureTemp)

%样本检测率 误检率 与 实际检测率
x=[6 8 9 12 15];
y1=[0.8131 0.686 0.6213 0.4465 0.31]; %样本检测率
y2=[0.8909 0.8795 0.8818 0.8477 0.7818]; %实际检测率
y3=[445 297 196 71 23];
%样本检测率 与实际检测率
plot(x,y1,'k-*')
axis([6 15 0 1])
xlabel('强分类器个数')
ylabel('检测率')
hold on
plot(x,y2,'k--^')

%误检个数
plot(x,y3,'k-^')
xlabel('强分类器个数')
ylabel('误检个数')

%测试检测时间
tic
TrainPicSize=20; %训练时图片尺寸
PictureName='testpx\1.jpg';
[SimpleOut,OutPut]=Test(PictureName,TrainPicSize);
toc