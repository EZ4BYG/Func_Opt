import sympy

x,y = sympy.symbols('x y')
f = (x+y)**2 + (x+1)**2 + (y+3)**2;

fx = sympy.diff(f,x)
fy = sympy.diff(f,y)
print('fx:',fx)
print('fx:',fy)

# acc = float(input('最速/梯度下降精度:'))
# study_step = float(input('学习率:'))
acc = 0.0001       # 精度
study_step = 0.01  # 学习率
x_tmp = 10    # 起点
y_tmp = -1.5  # 起点 
k = 0   # 迭代次数计数器
ans_tmp = [x_tmp,y_tmp];  # 迭代点的记录

while fx.evalf(subs={x:x_tmp,y:y_tmp})!=0 or fy.evalf(subs={x:x_tmp,y:y_tmp})!=0:
    # print(fx.evalf(subs={x:x_tmp,y:y_tmp}))
    gradient_tmp = [ study_step*fx.evalf(subs={x:x_tmp,y:y_tmp}),\
                     study_step*fy.evalf(subs={x:x_tmp,y:y_tmp}) ]  
    ans_tmp = [x_tmp-gradient_tmp[0], y_tmp-gradient_tmp[1]]
    acc_tmp = sympy.sqrt( (ans_tmp[0]-x_tmp)**2 + (ans_tmp[1]-y_tmp)**2 )
    if acc_tmp < acc:
        f_end = f.evalf(subs={x:ans_tmp[0],y:ans_tmp[1]})
        print('极值坐标为:(%.5f,%.5f,%.5f)'%(ans_tmp[0],ans_tmp[1],f_end))
        print('迭代次数:%d'%(k))
        break
    x_tmp = ans_tmp[0]
    y_tmp = ans_tmp[1]
    k = k + 1

