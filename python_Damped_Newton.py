import sympy 
import numpy as np
import time 

x,y = sympy.symbols('x y')
f = (x+y)**2 + (x+1)**2 + (y+3)**2
x1,y1,a = sympy.symbols('x1 y1 a')

# 一阶导数:
fx = sympy.diff(f,x)
fy = sympy.diff(f,y)
# 二阶导数:
fxx = sympy.diff(fx,x)
fyy = sympy.diff(fy,y)
fxy = sympy.diff(fx,y)
fyx = sympy.diff(fy,x)

# grad_f1 = np.array([[fx],[fy]])
grad_H2 = np.array([[float(fxx),float(fxy)],
                    [float(fyx),float(fyy)]])

# 参数设置:
acc = 0.001  
x_tmp = 10
y_tmp = -1.5      
k = 0  # 迭代次数计数器

print('阻尼牛顿下降开始:')
while 1:
    ans_tmp = [x_tmp,y_tmp]
    grad_f1 = np.array([[fx.evalf(subs={x:x_tmp,y:y_tmp})],
                        [fy.evalf(subs={x:x_tmp,y:y_tmp})]])
    # S中间过渡矩阵计算; (x1,y1)以及f1同样为中间过渡参数,为了求阻尼步长a
    S = -np.dot(np.linalg.inv(grad_H2),grad_f1)    
    x1 = x_tmp + a*S[0]
    y1 = y_tmp + a*S[1]
    f1 = (x1+y1)**2 + (x1+1)**2 + (y1+3)**2
    # 阻尼步长a:
    a_result = sympy.solve(sympy.diff(f1,a),a)
    # 如果a_result为[] 说明已经不用再求下去了!
    if a_result == []:
        a_result = 0
    # 更新到下一轮:
    x_tmp = x_tmp + a_result*S[0]
    y_tmp = y_tmp + a_result*S[1]
    acc_tmp = ((x_tmp-ans_tmp[0])**2 + (y_tmp-ans_tmp[1])**2)**(0.5)
    if acc_tmp <= acc:
        print('极值坐标为:(%.5f,%.5f,%.5f)'%(x_tmp, y_tmp, f.evalf(subs={x:x_tmp,y:y_tmp})))
        print('迭代次数:%d'%(k))
        break
    k = k + 1
