% 模拟退火法核心思路:
% 为了找出地球上最高的山，一群兔子们在开始并没有合适的策略，它们随机地跳了很长时间！
% 在这期间，它们可能走向高处，也可能踏入平地;
% 但是，随着时间的流逝，它们"渐渐清醒"! 并朝着最高的方向跳去，最后就到达了珠穆朗玛峰。

% 注：由于随机数的问题，模拟退火法不方便做图!
% 若想要高精度: x_tmp = x + rand()-0.5;      % 不限制,让它多取小数点后的几位
% 若想做图: x_tmp = x + round(rand()-0.5,1); % 限制小数点只到0.1
% 本例选择画图: 真实更新点用红* ; 概率更新点用黑*!

clc;
clear;
syms x y;
f =(x+y)^2 + (x+1)^2 + (y+3)^2;

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

% 起始点:
% 希望范围还是: x∈[-20,0.1,20] y∈[-15,0,1,15]
x = 10.0;
y = -1.5;
f_min = eval(f);

fprintf('已知:精确极小值坐标(0.33333,-1.66667,5.33333)\n')
fprintf('模拟退火开始:\n')
num = 1000;    % 每个温度下迭代次数
T_max = 1000;  % 初始最大温度1000
T_min = 0.01;  % 结尾最小温度0.01
Trate = 0.95;  % 温度下降速率0.95
n = 0;
while T_max > T_min
    %fprintf('当前温度:%.5f\n',T_max);
    while n < num
        x_tmp = x + round(rand()-0.5,2);
        y_tmp = y + round(rand()-0.5,2);
        if (x_tmp > -20 && x_tmp < 20) && (y_tmp > -15 && y_tmp < 15)
            f_tmp = (x_tmp+y_tmp)^2 + (x_tmp+1)^2 + (y_tmp+3)^2;
            res = f_tmp - f_min;
            % 真实点: 找到更小的值当然得更新!
            if res < 0
                f_min = f_tmp;
                x = x_tmp;
                y = y_tmp;
                plot3(x,y,f_min,'r*');
                hold on 
            else
                % 概率点: 没找到更小的值，看概率
                p = exp(-res/T_max);
                if rand() > p  
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
    T_max = T_max*Trate;
end
fprintf('近似极小值坐标为:(%.5f,%.5f,%.5f)\n', x, y, f_min);
hold off;
        
                    
    
    
    
    
    
    