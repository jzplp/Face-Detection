function [SimpleOut,OutPut]=Test(PictureName,TrainPicSize)
%Test 为整个检测函数
%PictureName为待检测的图片名称（地址）
%TrainPicSize 训练时图片尺寸
%读取图片
PictureTemp=imread(PictureName);
%转化为灰度
PictureTemp=rgb2gray(PictureTemp);
%对灰度图进行直方图均衡
PictureTemp=histeq(PictureTemp);
%图片长度方向像素数PicHeight,图片长度方向像素数PicWidth
[PicHeight PicWidth]=size(PictureTemp);
%CalIntegral 计算图片积分图函数(这是训练时用的函数)
%TestIntegral为积分图矩阵
TestIntegral=CalIntegral(PictureTemp,1,PicHeight,PicWidth);
load FinishStrong StrongClass
%TestWindow 检测窗口结构
%TestWindow.begin 检测窗口起始坐标 [x1,y1]
%TestWindow.end 检测窗口终点坐标 [x2,y2]
%TestWindow.times 放大倍数（对于训练样本大小的倍数）
SimpleOut=[]; %SimpleOut 保存判断为人脸的检测窗口
HorOffset=5; %检测窗口水平偏移像素数
VorOffset=5; %检测窗口竖直偏移像素数
%Times为最大的放大倍数
Times=min([PicHeight/TrainPicSize PicWidth/TrainPicSize]);
for t=1:Times
    for x1=1:HorOffset:PicHeight-t*TrainPicSize+1 %水平方向滑动窗口
        for y1=1:VorOffset:PicWidth-t*TrainPicSize+1 %竖直方向滑动窗口
            TempFlag=1; %检测标记初值 强分类器若检测为人脸，则TempFlag=1
            for i=1:length(StrongClass) %第i个强分类器
                TempOut=0; %强分类器计算出的组合值 初值0
                for wi=1:length(StrongClass(i).weak) %第wi个弱分类器
                    %弱分类器根据当前的放大倍数来放大窗口
                    %[xx1 yy1],[xx2 yy2]为放大后的弱分类器矩形坐标
                    xx1=x1-1+(StrongClass(i).weak(wi).begin(1)-1)*t+1; 
                    yy1=y1-1+(StrongClass(i).weak(wi).begin(2)-1)*t+1;
                    xx2=xx1-1+(StrongClass(i).weak(wi).end(1)-StrongClass(i).weak(wi).begin(1)+1)*t; %改
                    yy2=yy1-1+(StrongClass(i).weak(wi).end(2)-StrongClass(i).weak(wi).begin(2)+1)*t; %改
                    %求弱分类器特征值
                    TempHaarF=CalHaarValue(TestIntegral,xx1,yy1,xx2,yy2,StrongClass(i).weak(wi).st(1),StrongClass(i).weak(wi).st(2));
                    if StrongClass(i).weak(wi).p*TempHaarF < StrongClass(i).weak(wi).p*StrongClass(i).weak(wi).theta*t*t %判断为人脸
                        TempOut=TempOut+StrongClass(i).weakweight(wi);
                    end
                end
                if TempOut < StrongClass(i).pass 
                    break; %若强分类器判断为非人脸，则跳出循环
                elseif i==length(StrongClass) %最后一个强分类器且判断为人脸
                    TestWindow.begin=[x1,y1];
                    TestWindow.end=[x1-1+t*TrainPicSize,y1-1+t*TrainPicSize];
                    TestWindow.times=t;
                    SimpleOut=[SimpleOut TestWindow]; %保存判断为人脸的窗口
                end
            end
        end
    end
end

%-----把得到的人脸窗口分类
%若两个窗口重叠区域的面积大于等于任意一个窗口面积的MerRatio(1/2),则判断两个窗口在同一个区域
MerRatio=1/2;
NoMerFlag=1; %1表示还有未划分区域的窗口 0表示多有窗口都已经划分区域完毕
AreaTagNum=0; %区域标记计数 代表现在总共有几个区域
%AreaTag(i)表示第i个窗口所属的区域标记
AreaTag=zeros(1,length(SimpleOut)); 
for i=1:length(SimpleOut)
    if AreaTag~=0 %若此窗口已经有区域标记了
        continue; %进行下一个窗口的判断
    end
    %判断此窗口是否在已有的区域内
    for i2=1:length(SimpleOut)
        if AreaTag==0 %若此窗口没有区域标记
            continue; %进行下一个窗口的判断
        end
        %判断i和i2的重叠区域
        xx1=max(SimpleOut(i).begin(1),SimpleOut(i2).begin(1));
        yy1=max(SimpleOut(i).begin(2),SimpleOut(i2).begin(2));
        xx2=min(SimpleOut(i).end(1),SimpleOut(i2).end(1));
        yy2=min(SimpleOut(i).end(2),SimpleOut(i2).end(2));
        if xx2<=xx1 | yy2<=yy1 %若两窗口不相交
            continue; %进行下一个窗口的判断
        end
        CoinArea=(xx2-xx1+1)*(yy2-yy1+1); %重合面积
        if CoinArea>=SimpleOut(i).times*TrainPicSize*TrainPicSize | CoinArea>=SimpleOut(i2).times*TrainPicSize*TrainPicSize
            AreaTag(i)=AreaTag(i2); %重合面积大于1/2 则划分到i2所属区域内
            break;
        end
    end
    if AreaTag(i)~=0 %若此窗口已经有区域标记了
        continue; %进行下一个窗口的判断
    end
    %若进行到这里，SimpleOut(i)仍然没有区域标记
    AreaTagNum=AreaTagNum+1;
    AreaTag(i)=AreaTagNum; %SimpleOut(i)属于一个新的区域了   
end

%如果没有任何人脸窗口 就退出函数
if length(SimpleOut)==0
    OutPut=[];
    SimpleOut=[];
    return
end

%------同一区域的窗口进行合并
AreaNum=zeros(1,AreaTagNum); %AreaNum(i)第i区域的窗口的计数值
TempWindow.begin=[0,0];
TempWindow.end=[0,0];
%OutPut赋初值　
for i=1:AreaTagNum
    OutPut(i)=TempWindow;
end
%合并窗口
%Area(i) 表示第i个区域
for i=1:length(SimpleOut)
    AreaNum(AreaTag(i))=AreaNum(AreaTag(i))+1;
    OutPut(AreaTag(i)).begin=OutPut(AreaTag(i)).begin+SimpleOut(i).begin;
    OutPut(AreaTag(i)).end=OutPut(AreaTag(i)).end+SimpleOut(i).end;
end
%计算最后的窗口值
for i=1:AreaTagNum
    OutPut(i).begin=OutPut(i).begin./AreaNum(i);
    OutPut(i).end=OutPut(i).end./AreaNum(i);
end