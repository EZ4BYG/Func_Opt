% 蚁群算法找最大值
% 核心思路: 
% 和粒子群算法有些相似，都是靠团队的力量共同去找目标！
% 蚁群算法中特殊的是它的"信息素"挥发! 这个效果是其他算法中没有的！

clc;
clear;
% f的最大值就是-前面的数值;这里是2.4
f = inline('2.4-(x.^4 + 3*y.^4 - 0.2*cos(3*pi*x) - 0.4*cos(4*pi*y) + 0.6)');
x = -1:0.001:1;
y = -1:0.001:1;
[X,Y] = meshgrid(x,y);
F = f(X,Y);
figure(1);
mesh(X,Y,F);
xlabel('横坐标x'); ylabel('纵坐标y'); zlabel('空间坐标z');
hold on;

% 坐标/搜索范围的设置:
lower_x = -1;
upper_x = 1;
lower_y = -1;
upper_y = 1; 

% 模型初始参数设置:
ant = 80;      % 蚂蚁总数300只太多了,不到100只松松解决问题
times = 30;    % 每只蚂蚁搜寻80次
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

fprintf('蚁群搜索开始(找最大值):\n');
T = 1;
tau_best = zeros(1,times);  % 记录每轮寻找后的群体中的最大值!
p = zeros(1,ant);   % 每只蚂蚁状态转移的概率,都与p0比较
while T < times
    lamda = 1/T;
    % 这里是查看极值的地方!！
    [tau_best(T),bestindex] = max(tau);
    
    % 精度足够高，提前结束!
    % 这里我有个策略: 当前适应度值 与 前两轮的值对比！ 而不是与上一轮值对比！
    % 因为相邻两次循环的值很可能因为有一定的相关性而彼此接近！
    if T >= 3 && abs((tau_best(T) - tau_best(T-2))) < 0.000001
        fprintf('精度足够高,提前结束!\n');
        % 小心思:最后一次画图放在这里，可以把最后一个点标成蓝色而不是红色！
        plot3(ant_x(bestindex), ant_y(bestindex), f(ant_x(bestindex),ant_y(bestindex)), 'b*');
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
            tempx = ant_x(i) + (2*rand-1)*lamda;
            tempy = ant_y(i) + (2*rand-1)*lamda;
        % 大于p0进行全局搜索:
        else
            tempx = ant_x(i) + (upper_x-lower_x)*(rand-0.5);
            tempy = ant_y(i) + (upper_y-lower_y)*(rand-0.5);
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
        if f(tempx,tempy) > tau(i)
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
hold off;
    
fprintf('蚁群搜索到的最大值点:(%.5f,%.5f,%.5f)\n',...
        ant_x(bestindex), ant_y(bestindex), f(ant_x(bestindex),ant_y(bestindex)));
fprintf('搜索次数:%d\n',T)
    
    