clc;
clear;
syms x y;
f =(x+y)^2 + (x+1)^2 + (y+3)^2;
syms x1 y1 a;  % a是阻尼步长
f1 = (x1+y1)^2 + (x1+1)^2 + (y1+3)^2;

% 梯度:一阶导数
fx = diff(f,x);
fy = diff(f,y);
% 海森矩阵:二阶导数
fxx = diff(fx,x);
fyy = diff(fy,y);
fxy = diff(fx,y);
fyx = diff(fy,x);

grad_f1 = [fx;fy];    % 梯度
grad_H2 = [fxx fxy;fyx fyy]; % 2x2的海森矩阵

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
plot3(x0,y0,z0,'r*');
hold on       

acc = 0.00001;  % 精度
x = 10; 
y = -1.5;      % 起始点
k = 0;         % 下降次数

fprintf('阻尼牛顿下降开始:\n')
while 1
	ans_tmp = [x;y];
	% S中间计算部分:(x1,y1)及f1属于中间过渡参数?
	S = -eval(inv(grad_H2))*eval(grad_f1);
	x1 = x + a*S(1)
	y1 = y + a*S(2)
	% 阻尼步长从f1关于a的偏导数中求得:
    if diff(eval(f1),a) == 0
        a_result = 0;
    else
	    a_result = solve(diff(eval(f1)));
        fprintf('第%d次迭代,当前阻尼步长为:%.5f\n', k, a_result);
    end
    % 并且更新(x,y)的值:
    x = x + a_result*S(1);
	y = y + a_result*S(2);
    result_tmp = [x;y];
    acc_tmp = sqrt( (result_tmp(1)-ans_tmp(1))^2 + (result_tmp(2) - ans_tmp(2))^2 );
	if acc_tmp < acc
		fprintf('极值坐标为:(%.5f,%.5f,%.5f)\n', x, y, eval(f));
        fprintf('迭代次数:%d\n',k);
        plot3(x,y,eval(f),'r*');
        hold off;
        break;
    end
    plot3(x,y,eval(f),'r*');
    hold on;
    k = k + 1;
    if k >= 100
        fprintf('自动结束!\n');
        break;
    end
end
        

    