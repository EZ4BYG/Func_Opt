# -*- coding: utf-8 -*-
"""
Created on Sun Jan  6 22:24:47 2019

@author: Boyu Gao
"""
import random
import numpy as np

# x_all 与 y_all 规定空间范围:
# 400*300 = 12w种的全集; 网格的步长可以改的更小来提高精度!
x_all = [x for x in np.arange(-20,20,0.1)]
y_all = [y for y in np.arange(-15,15,0.1)]
# x_min 与 y_min 记录不断更新的极小值:
x_min = 0
y_min = 0 
# x0 与 y0 是蒙特卡洛搜索的起始点; f_min是其实最小值!
x0 = 10.0
y0 = -1.5
f_min = (x0+y0)**2 + (x0+1)**2 + (y0+3)**2

# count是记录成功更新当前最小值的次数:
num = 1
count = 0
print('蒙特卡洛随机搜索开始:')
# 搜索集为10w; 理论上找到极小值的概率为 10/12 ≈ 83.3%
# 计算/搜索速度非常快！
while num < 100000:
    x_tmp = random.choice(x_all)
    y_tmp = random.choice(y_all)
    f_tmp = (x_tmp+y_tmp)**2 + (x_tmp+1)**2 + (y_tmp+3)**2
    if f_tmp <= f_min:
        count = count + 1
        x_min = x_tmp
        y_min = y_tmp
        f_min = f_tmp
        print('极值坐标为:(%.5f,%.5f,%.5f)'%(x_min, y_min, f_min))
        print('迭代次数:%d'%(count))
    num = num + 1

