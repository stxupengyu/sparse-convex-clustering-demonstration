# sparse-convex-clustering-demonstration
R语言包“稀疏凸聚类（scvxclustr）”的实验演示。  
scvxclustr包已经由原作者给出开源代码：  
https://github.com/elong0527/scvxclustr  
****
其环境配置较为复杂，这里给出本人安装经验：  
1.配置环境较为复杂  
2.要求R版本为3.6.3以上  
3.安装devtools包  
4.安装scvxclustr包：需要通过install_github(“elong0527/scvxclustr”)的方式  
5.安装rtools40：  https://cran.r-project.org/bin/windows/Rtools/  
6.配置PATH：参考https://stackoverflow.com/questions/40788645/how-to-create-renviron-file  
7.大概是这么个安装逻辑，如果中间出现报错可以再在google、百度上找找解决方法。  
****
文件说明：  
toy_example为原作者给出的参考代码。为了方便展示和学习，本人对toy_example进行改进，形成了pre.Rmd。movement_libras_selected为一个手部运动数据集，我们参考pre.Rmd，在pre-example.Rmd里进行聚类展示。rand_index.ipynb为用python进行的数据可视化以及rand index值的计算。

