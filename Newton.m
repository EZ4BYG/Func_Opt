clc;
clear;
syms x y;
f =(x+y)^2 + (x+1)^2 + (y+3)^2;

% 一阶导数:
fx = diff(f,x);
fy = diff(f,y);
% 二阶导数:
fxx = diff(fx,x);
fyy = diff(fy,y);
fxy = diff(fx,y);
fyx = diff(fy,x);

grad_f1 = [fx;fy];    % 数字代表求导阶数
grad_H2 = [fxx fxy;fyx fyy]; % 数字代表求导阶数

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
       
acc = 0.001;  % 精度
x = 10; 
y = -1.5;      % 起始点
k = 0;         % 下降次数

% 牛顿法一步到位！
fprintf('牛顿下降开始:\n')
while 1
    ans_tmp = [x;y] - eval(inv(grad_H2))*eval(grad_f1);
    acc_tmp = sqrt((ans_tmp(1)-x)^2 + (ans_tmp(2)-y)^2);
   	if acc_tmp <= acc
		fprintf('极值坐标为:(%.5f,%.5f,%.5f)\n',ans_tmp(1),ans_tmp(2),f_tmp);
        fprintf('迭代次数:%d\n',k);
        plot3(ans_tmp(1),ans_tmp(2),f_tmp,'r*');
        hold off;
		break;
	end
	x = ans_tmp(1);
	y = ans_tmp(2);
	f_tmp = (x+y)^2 + (x+1)^2 + (y+3)^2;
    plot3(x,y,f_tmp,'r*');
    hold on;
    k = k + 1;  % 计数器
end

