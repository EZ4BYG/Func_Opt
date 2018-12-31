import sympy
import numpy as np
import time

x,y = sympy.symbols('x y')
f = (x+y)**2 + (x+1)**2 + (y+3)**2

# 一阶导数:
fx = sympy.diff(f,x)
fy = sympy.diff(f,y)
# 二阶导数:
fxx = sympy.diff(fx,x)
fyy = sympy.diff(fy,y)
fxy = sympy.diff(fx,y)
fyx = sympy.diff(fy,x)

grad_f1 = np.array([[fx],[fy]])
grad_H2 = np.array([[float(fxx),float(fxy)],
                    [float(fyx),float(fyy)]])

# 参数设置:
acc = 0.001  
x_tmp = 10
y_tmp = -1.5      
k = 0  # 迭代次数计数器

print('牛顿下降开始:\n')
while 1:
    grad_f1 = np.array([[float(fx.evalf(subs={x:x_tmp,y:y_tmp}))],
                        [float(fy.evalf(subs={x:x_tmp,y:y_tmp}))]])
    ans_tmp = np.array([[x_tmp],[y_tmp]]) - np.dot(np.linalg.inv(grad_H2),grad_f1)    
    acc_tmp = ( (ans_tmp[0,0]-x_tmp)**2 + (ans_tmp[1,0]-y_tmp)**2 )**0.5

    if acc_tmp <= acc:
        print('极值坐标为:(%.5f,%.5f,%.5f)'%(ans_tmp[0,0],ans_tmp[1,0],f_tmp))
        print('迭代次数:%d'%(k))
        break
    
    x_tmp = ans_tmp[0,0]
    y_tmp = ans_tmp[1,0]
    f_tmp = (x_tmp+y_tmp)**2 + (x_tmp+1)**2 + (y_tmp+3)**2
    k = k + 1
