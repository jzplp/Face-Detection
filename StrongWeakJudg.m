function [CurDivPRMin,CurDivFPRMax]=StrongWeakJudg(StrongClass,JudgOut,num,num1)
%强分类器样本判断输出函数
%StrongClass 强分类器结构 调用时用StrongClass(x)
%JudgOut(x,i) 第x个最优弱分类器对第i个样本的判断
%num为样本总数 num1为正例（人脸）个数
%CurDivPRMin 当前强分类器的检测率
%CurDivFPRMax 当前强分类器的误检率
TempJudgArr=zeros(1,num);
%计算强分类器对于每个样本的“特征值” TempJudgArr(x)
for i=1:length(StrongClass.weak)
   for x=1:num
       TempJudgArr(x)=TempJudgArr(x)+StrongClass.weakweight(i).*JudgOut(StrongClass.num(i),x);
   end
end
TempP=0; %正确检测到的人脸数
TempFP=0; %被误检为人脸的非人脸数
for i=1:num
    if i<=num1 & TempJudgArr(i)>=StrongClass.pass
        TempP=TempP+1;
    elseif i>num1 & TempJudgArr(i)>=StrongClass.pass
        TempFP=TempFP+1;
    end
end
CurDivPRMin=TempP/num1;
CurDivFPRMax=TempFP/(num-num1);