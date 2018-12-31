clc;
clear;
syms x y r;
f = (x+y)^2 + (x+1)^2 + (y+3)^2;
syms x_tmp y_tmp;
f_tmp = (x_tmp+y_tmp)^2 + (x_tmp+1)^2 + (y_tmp+3)^2;

% 一阶导数:
fx = diff(f,x);
fy = diff(f,y);
grad_f1 = [fx,fy]';  % 梯度(列向量)

% 做图:原始3d曲面图
x = -20:0.1:20;
y = -15:0.1:15;
[X,Y] = meshgrid(x,y); 
Z = (X+Y).^2 + (X+1).^2 + (Y+3).^2;
figure(1);
mesh(X,Y,Z);
xlabel('横坐标x'); ylabel('纵坐标y'); zlabel('空间坐标z');
hold on;
% 做图:原始点
x0 = 10; y0 = -1.5;
z0 = (x0+y0)^2 + (x0+1)^2 + (y0+3)^2;
plot3(x0,y0,z0,'r*')
hold on

% 初始化:
acc = 0.0001;     % 精度
x = 10; 
y = -1.5;  % 起点
k = 1;     % 下降次数:这里特殊！共轭是用"新点"来做判断的！

fprintf('共轭梯度下降开始:\n');
d = -eval(grad_f1);   % 起始d值
while 1
    % grad_f1_down与grad_f1_up是算μ的分母与分子
    % 并且分子是梯度新一轮的值，分母是梯度上一轮的值！
    % r和r_result就是每一轮的变步长λ
    grad_f1_down = norm(eval(grad_f1))^2;   % 用老(x,y)的值
    x_tmp = x + r*d(1);
    y_tmp = y + r*d(2);
    r_result = solve(diff(eval(f_tmp)));

    % 进入新一轮:
    x = x + r_result*d(1);
    y = y + r_result*d(2);
    grad_f1_up = norm(eval(grad_f1))^2;     % 用新(x,y)的值
    plot3(x,y,eval(f),'r*');  % 并且标点也是用新的!
    hold on 

    if norm(eval(grad_f1)) <= acc
        fprintf('极值坐标为:(%.5f,%.5f,%.5f)\n',x,y,eval(f))
        fprintf('迭代次数:%d\n',k)
        break;
    end
    
    miu = grad_f1_up/grad_f1_down;
    d = -eval(grad_f1) + miu*d;
    k = k+1;
end
hold off;
    
    