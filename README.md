# Optimization_Algorithm
梯度下降、牛顿法、共轭梯度法matlab和python程序：求一个空间曲面的极值点。

1. 梯度下降算法速度较慢、迭代次数较大，并且最后的结果是近似值；
2. 牛顿法利用函数的二阶泰勒展开近似，可以一步到位（收敛很快）！并且结果的精度很高！缺点是需要用到海森矩阵，即函数的二阶导！
3. 共轭梯度法是介于梯度下降和牛顿法之间的折中方法，既有牛顿法的收敛速度，又不需要用到函数的二阶导！推荐这种方法！

##### date:2019.1.6 #####
更新1：新增“阻尼牛顿法”的matlab和python程序；文件名：Damped_Newton.m / python_Damped_Newton.py 

##### date:2019.1.7 #####
更新2：新增“蒙特卡洛全局最优”的matlab和python程序；文件名：Monte_Carlo.m / python_Monte_Carlo.py
