% 蚁群算法找Schaffer函数的最小值!
% 说明：全局最优算法核心都是靠概率的！目标都是让陷入局部最小的情况变成一种小概率事件!
% 本例中Schaffer外围一圈的沟壑还是对蚁群算法有一定的迷惑性的！已尽量让其发生变成一种小概率事件了。
% 改进：在75行全局搜索时，一般改成全局半径的一半~

clc;
clear;
% f的最大值就是-前面的数值;这里是2.4
f = inline('0.5 + ( (sin(sqrt(X.^2+Y.^2))).^2 - 0.5 ) ./ ( 1+0.01*(X.^2+Y.^2) ).^2');
x = -5:0.01:5;
y = -5:0.01:5;
[X,Y] = meshgrid(x,y);
F = f(X,Y);
figure(1);
mesh(X,Y,F);
xlabel('横坐标x'); ylabel('纵坐标y'); zlabel('空间坐标z');
hold on;

% 坐标/搜索范围的设置:
lower_x = -5;
upper_x = 5;
lower_y = -5;
upper_y = 5; 

% 模型初始参数设置:
ant = 500;      % 蚂蚁总数300只太多了,不到100只松松解决问题
times = 200;    % 每只蚂蚁搜寻80次
rou = 0.9;     % 信息素挥发速率
p0 = 0.2;      % 蚂蚁转移的概率常数

% 初始蚂蚁位置(空间内随机)、适应度计算:
ant_x = zeros(1,ant);  % 每只蚂蚁位置的x坐标
ant_y = zeros(1,ant);  % 每只蚂蚁位置的y坐标
tau = zeros(1,ant);    % 适应度/函数数值
Macro = zeros(1,ant);  % Macro和tau共同使用的中间过渡量而已
for i=1:ant
    ant_x(i) = (upper_x-lower_x)*rand() + lower_x;
    ant_y(i) = (upper_y-lower_y)*rand() + lower_y;
    tau(i) = f(ant_x(i),ant_y(i));         % 初始适应度/函数值
    plot3(ant_x(i),ant_y(i),tau(i),'k*');  % 起始群都用黑色*标记
    hold on;
    Macro = zeros(1,ant);
end

fprintf('蚁群搜索开始(找最小值,绿*):\n');
T = 1;
tau_best = zeros(1,times);  % 记录每轮寻找后的群体中的最大值!
p = zeros(1,ant);   % 每只蚂蚁状态转移的概率,都与p0比较
while T < times
    lamda = 1/T;
    % 这里是查看极值的地方!！
    [tau_best(T),bestindex] = min(tau);
    
    % 精度足够高，提前结束!
    if T >= 3 && abs((tau_best(T) - tau_best(T-2))) < 0.000001
        fprintf('精度足够高,提前结束!\n');
        % 小心思:最后一次画图放在这里，可以把最后一个点标成绿色而不是红色！
        plot3(ant_x(bestindex), ant_y(bestindex), f(ant_x(bestindex),ant_y(bestindex)), 'g*');
        break;
    end
    plot3(ant_x(bestindex), ant_y(bestindex), f(ant_x(bestindex),ant_y(bestindex)), 'r*');
    hold on;
    
    for i = 1:ant
        p(i) = (tau(bestindex) - tau(i))/tau(bestindex); % 每一只蚂蚁的转移概率
    end
    % 位置更新: 新算的临时坐标tempx与tempy不一定用!
    for i = 1:ant
        % 小于p0进行局部搜索:
        if p(i) < p0
            tempx = ant_x(i) + 0.5*(2*rand-1)*lamda;  % 局部搜索再下到一半
            tempy = ant_y(i) + 0.5*(2*rand-1)*lamda;
        % 大于p0进行全局搜索:
        else
            tempx = ant_x(i) + (upper_x-lower_x)*(rand-2.5);  % 5/2=2.5
            tempy = ant_y(i) + (upper_y-lower_y)*(rand-2.5);
        end
        % 不能越界，做一个越界判断:
        if tempx < lower_x
            tempx = lower_x;
        end
        if tempx > upper_x
            tempx = upper_x;
        end
        if tempy < lower_y
            tempy = lower_y;
        end
        if tempy > upper_y
            tempy = upper_y;
        end
        % 判断蚂蚁是否移动,即tempx和tempy是否采用
        % tau(i)是上一轮的值；Macro是及时更新的值!!
        if f(tempx,tempy) < tau(i)
            ant_x(i) = tempx;
            ant_y(i) = tempy;
            Macro(i) = f(tempx,tempy);
        end
    end
   
    % 适应度更新:
    for i = 1:ant
        tau(i) = (1-rou)*tau(i) + Macro(i);
    end
    
    % 搜索进入下一轮:
    T = T + 1;
end
hold on;
    
fprintf('蚁群搜索到的最小值点:(%.5f,%.5f,%.5f)\n',...
        ant_x(bestindex), ant_y(bestindex), f(ant_x(bestindex),ant_y(bestindex)));
fprintf('搜索次数:%d\n\n',T)

% 测试发现: 大于0.08肯定是陷在周围那一圈沟壑当中了!
% 这是小概率事件，再次执行重新执行程序即可。
if f(ant_x(bestindex),ant_y(bestindex)) > 0.08
    fprintf('发生小概率事件: 陷入局部极小值,请再次执行程序!\n')
    return ;
end

% 下面开始梯度下降精确搜索:
% 初始化:
syms x y;
f = 0.5 + ( (sin(sqrt(x^2+y^2)))^2 - 0.5 ) / ( 1+0.01*(x^2+y^2) )^2;
fx = diff(f,x);
fy = diff(f,y);
acc = 0.00001;     % 精度
study_step = 0.001; % 学习率
x = ant_x(bestindex); 
y = ant_y(bestindex);
k = 0; % 下降次数
fprintf('梯度下降精确搜索开始(黄线):\n');
while eval(fx)~=0 | eval(fy)~=0 
	ans_tmp = [x,y] - study_step*[eval(fx),eval(fy)];
	acc_tmp = sqrt((ans_tmp(1)-x)^2 + (ans_tmp(2)-y)^2);
	if acc_tmp <= acc
		fprintf('精确极值坐标为:(%.5f,%.5f,%.5f)\n',ans_tmp(1),ans_tmp(2),f_tmp);
        fprintf('迭代次数:%d\n',k);
        plot3(ans_tmp(1),ans_tmp(2),f_tmp,'y.');
        hold off
		break;
	end
	x = ans_tmp(1);
	y = ans_tmp(2);
	f_tmp = eval(f);
    plot3(x,y,f_tmp,'y.')
    hold on;
    k = k + 1;  % 计数器
end
    
    