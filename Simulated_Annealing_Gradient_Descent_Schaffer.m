% 模拟退火感觉不好用！Rastrigin的小坑太多了！
% 这里必须要暴力、超大量搜索才能不断跳出一个个坑！
% 这个要想搜到精确解，真的是看运气！！

clc;
clear;
syms x y;
% 根据函数表达式: f最小值是0
f = 0.5 + ( (sin(x^2+y^2))^2 - 0.5 ) / ( 1+0.01*(x^2+y^2) )^2; 
% 一阶导数: 为精搜的梯度下降准备
fx = diff(f,x);
fy = diff(f,y);

% 原始图像:
x = -5:0.01:5;
y = -5:0.01:5;
[X,Y] = meshgrid(x,y);
Z = 0.5 + ( (sin(sqrt(X.^2+Y.^2))).^2 - 0.5 ) ./ ( 1+0.01*(X.^2+Y.^2) ).^2;
figure(1);
mesh(X,Y,Z);
xlabel('横坐标x'); ylabel('纵坐标y'); zlabel('空间坐标z');
hold on;
x0 = 1.29;
y0 = -4.62;
f_min = 0.5 + ( (sin(sqrt(x0^2+y0^2)))^2 - 0.5 ) / ( 1+0.01*(x0^2+y0^2) )^2;
plot3(x0,y0,f_min,'b*');
hold on;

% 起始点:
% 希望范围还是: x∈[-20,0.1,20] y∈[-15,0,1,15]
x = 2.42;
y = -4.58;
f_min = eval(f);

fprintf('已知:精确极小值坐标(0.0,0.0,0.0)\n')
fprintf('模拟退火开始:\n')
num = 2000;     % 每个温度下迭代次数
T_max = 500;    % 初始最大温度30000
T_min = 0.001;  % 结尾最小温度0.01
Trate = 0.95;   % 温度下降速率0.95
n = 0;
re_heat = 2;     % 重升温机制
global_min = 0;  % 记录出现点的最小值！
while T_max > T_min
    T_max = T_max*Trate;
    %fprintf('当前温度:%.5f\n',T_max);
    while n < num
        x_tmp = x + round(rand,1)*round(rand()-0.5,2);
        y_tmp = y + round(rand,1)*round(rand()-0.5,2);
        if (x_tmp > -5 && x_tmp < 5) && (y_tmp > -5 && y_tmp < 5)
            f_tmp = 0.5 + ( (sin(x_tmp^2+y_tmp^2))^2 - 0.5 ) / ( 1+0.01*(x_tmp^2+y_tmp^2) )^2; 
            res = f_tmp - f_min;
            % 真实点: 找到更小的值当然得更新!
            if res < 0
                f_min = f_tmp;
                global_min = f_min;  % 这里肯定是越来越小的!
                x = x_tmp;
                y = y_tmp;
                plot3(x,y,f_min,'r*');
                hold on 
            else
                % 加一个记忆功能:
                if T_max < 30 && global_min < f_tmp
                    continue;
                end
                % 概率点: 没找到更小的值，看概率
                p = exp(-res/T_max);
                if rand() < p   
                    f_min = f_tmp;
                    x = x_tmp;
                    y = y_tmp;
                    plot3(x,y,f_min,'w*');
                    hold on;
                end
            end
        end
        n = n + 1;
    end
    % 重升温
    if T_max < 100 && re_heat > 0 
        fprintf('温度小于50,重升温!\n')
        T_max = T_max + 100;
        re_heat = re_heat - 1;
    end
end
fprintf('近似极小值坐标为:(%.5f,%.5f,%.5f)\n', x, y, f_min);

% 下面开始梯度下降精确搜索:
% 初始化:
acc = 0.0001;     % 精度
study_step = 0.001; % 学习率
k = 0; % 下降次数
% 梯度下降开始:[x1,y1] = [x0,y0] - step*( fx(x0,y0),fy(x0,y0) )
% 图像：在一个坡的两侧，跳跃式下降！
fprintf('梯度下降精确搜索开始:\n');
while eval(fx)~=0 | eval(fy)~=0 
	ans_tmp = [x,y] - study_step*[eval(fx),eval(fy)];
	acc_tmp = sqrt((ans_tmp(1)-x)^2 + (ans_tmp(2)-y)^2);
	if acc_tmp <= acc | k >= 5000
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
global_min