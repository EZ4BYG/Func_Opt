% 本程序使用Rastrigin函数
% 思路：先用蒙特卡洛全局搜索到近似最小值(精度有限)，再用梯度下降法进行精确搜索！

clc;
clear;
syms x y;
% 根据函数表达式: f最小值是0
f = 20 + x^2 + y^2 -10*(cos(2*pi*x) + cos(2*pi*y));
% 一阶导数: 为精搜的梯度下降准备
fx = diff(f,x);
fy = diff(f,y);

% 原始图像:
x = -5:0.01:5;
y = -5:0.01:5;
[X,Y] = meshgrid(x,y);
Z = 20 + X.^2 + Y.^2 -10*(cos(2*pi*X) + cos(2*pi*Y));
figure(1);
mesh(X,Y,Z);
xlabel('横坐标x'); ylabel('纵坐标y'); zlabel('空间坐标z');
hold on;
x0 = 2.42;
y0 = -4.58;
f_min = 20 + x0^2 + y0^2 -10*(cos(2*pi*x0) + cos(2*pi*y0));
plot3(x0,y0,f_min,'b*');
hold on;

% 1001*1001 全集10w种可能(x,y):
x_all = -5:0.01:5;
y_all = -5:0.01:5;
num = 1;
count = 0;  % 记录所有测试数据中有几次成功前进了！
fprintf('蒙特卡洛随机抽样开始:\n')
while num < 80000  % 测试集8w  测试集太小找到极值的概率就很小!
    x = x_all(randperm(length(x_all),1));
    y = y_all(randperm(length(y_all),1));
    if eval(f) < f_min
        count = count + 1;
        f_min = eval(f);
        x_tmp = x;
        y_tmp = y;
        fprintf('当前极小值坐标为:(%.5f,%.5f,%.5f)\n', x_tmp, y_tmp, f_min);
        fprintf('当前成功替换次数:%d\n\n',count)
        plot3(x_tmp, y_tmp, f_min, 'r*');
        hold on;
    end
    num = num + 1;
end


% 下面开始梯度下降精确搜索:
% 初始化:
acc = 0.001;     % 精度
study_step = 0.001; % 学习率
x = x_tmp; 
y = y_tmp;
k = 0; % 下降次数
% 梯度下降开始:[x1,y1] = [x0,y0] - step*( fx(x0,y0),fy(x0,y0) )
% 图像：在一个坡的两侧，跳跃式下降！
fprintf('梯度下降精确搜索开始:\n');
while eval(fx)~=0 | eval(fy)~=0 
	ans_tmp = [x,y] - study_step*[eval(fx),eval(fy)];
	acc_tmp = sqrt((ans_tmp(1)-x)^2 + (ans_tmp(2)-y)^2);
	if acc_tmp <= acc
		fprintf('精确极值坐标为:(%.5f,%.5f,%.5f)\n',ans_tmp(1),ans_tmp(2),f_tmp);
        fprintf('迭代次数:%d\n',k);
        plot3(ans_tmp(1),ans_tmp(2),f_tmp,'k.');
        hold off
		break;
	end
	x = ans_tmp(1);
	y = ans_tmp(2);
	f_tmp = eval(f);
    plot3(x,y,f_tmp,'k.')
    hold on;
    k = k + 1;  % 计数器
end

