import sympy
import numpy as np

# 两组符号变量:
x,y,r = sympy.symbols('x y r')
f = (x+y)**2 + (x+1)**2 + (y+3)**2
x1,y1 = sympy.symbols('x1 y1')

# 一阶导数:
fx = sympy.diff(f,x)
fy = sympy.diff(f,y)
# 梯度(列向量):
grad_f1 = np.array([[fx],[fy]])

acc = 0.0001    
x_tmp = 10 
y_tmp = -1.5  
k = 1 

print('共轭梯度下降开始:')
d = np.array([[float(fx.evalf(subs={x:x_tmp,y:y_tmp}))],
              [float(fy.evalf(subs={x:x_tmp,y:y_tmp}))]])  # 这里有问题!
while 1:
    # 上一轮:
    # grad_tmp为"梯度临时值",为了方便!
    grad_tmp = -np.array([[float(fx.evalf(subs={x:x_tmp,y:y_tmp}))],
                          [float(fy.evalf(subs={x:x_tmp,y:y_tmp}))]])  
    # grad_f1_down和grad_f1_up是μ的分母和分子!
    # 其中分母在上一轮求取,分子在新一轮求取!
    grad_f1_down = np.linalg.norm(grad_tmp)**2
    x1 = x_tmp + r*d[0]
    y1 = y_tmp + r*d[1]
    f_tmp = (x1+y1)**2 + (x1+1)**2 + (y1+3)**2  # 符号表达式不能作为evalf中的值去赋值!!!!!
    # r与r_result都是为了求λ的值
    r_result = sympy.solve(sympy.diff(f_tmp,r),r)

    # 新一轮:
    x_tmp = float(x_tmp + r_result*d[0])  # 一定要随时记得转数值类型！！！！！！
    y_tmp = float(y_tmp + r_result*d[1])
    grad_tmp = -np.array([[float(fx.evalf(subs={x:x_tmp,y:y_tmp}))],
                          [float(fy.evalf(subs={x:x_tmp,y:y_tmp}))]])  # 这里有问题!
    grad_f1_up = np.linalg.norm(grad_tmp)**2
    if np.linalg.norm(grad_tmp) <= acc:
        print('极值坐标为:(%.5f,%.5f,%.5f)'%(x_tmp,y_tmp,f.evalf(subs={x:x_tmp,y:y_tmp})))
        print('迭代次数:%d'%(k))
        break
    miu = grad_f1_up/grad_f1_down
    d = miu*d - grad_tmp
    k = k + 1

