# Face-Detection
本科毕业设计 基于Haar特征与AdaBoost算法的人脸检测的实现

========================================

本项目源代码遵循GPL授权许可，你可以修改并免费使用，但请保留本项目作者信息，谢谢。

论文引用格式：

贾震. 基于Haar特征与AdaBoost算法的人脸检测研究与实现[D]. 曲阜师范大学, 2016.



------博客地址------ Coding Home - 漂流瓶jz

CSDN博客 http://blog.csdn.net/qq278672818

新浪博客 http://blog.sina.com.cn/jzplp


========================================

main.m 为主函数

里面包含训练和检测的主要操作说明和用法。

========================================

实验过程：

![image](https://github.com/jzplp/Face-Detection/blob/master/ReadmeImage/process.png)

实验结果;

![image](https://github.com/jzplp/Face-Detection/blob/master/ReadmeImage/result.png)

========================================

训练样本：
MIT人脸数据库

样本尺寸：20*20px

样本个数：5971个样本，其中人脸样本为2429个

faces文件夹 包含人脸样本

nonfaces文件夹 包含非人脸样本

========================================

测试样本：
加州理工大学 人脸数据库

样本尺寸：896*592px

包含450个样本

faces_test文件夹

（程序剔除了部分非人脸样本，实际检测样本数约为440个）

========================================

