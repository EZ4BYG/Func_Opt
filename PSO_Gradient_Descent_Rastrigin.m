% 粒子群: Rastrigin函数
% 说明: 这个函数极小值陷阱太多！但粒子群“基本”没有问题！
% 测试会发现: 总有最后的那2,3个陷阱容易陷进去！但这样的结果已经非常好了！
% 粒子群比模拟退火好太多！又快又精确！

clc;
clear;
f = inline('20 + x.^2 + y.^2 -10*(cos(2*pi*x) + cos(2*pi*y))','x','y');
% 初始点: f(2.42,-4.58) = 64.3589

% 初始参数:
% 群体进化200次;群体有30个个体
maxgen = 200;
popsize = 30;  
% 权重参数初始化
w = 1.0;
c1 = 1.49445;
c2 = 1.49445;
% 粒子速度和位置的范围
Vmax = 1;
Vmin = -1;
popmax = 5;
popmin = -5;

% 初始化速度和位置
vx = (rand(1,popsize)-0.5)*2;      % 速度vx和vy在[-1,1]之间:第一行全是x坐标,第二行全是y坐标
vy = (rand(1,popsize)-0.5)*2;
popx = (rand(1,popsize)-0.5)*10;   % 位置popx和popy在[-5,5]之间:同上
popy = (rand(1,popsize)-0.5)*10;

% 初始: 个体(g)最优位置、个体适应度
gbestx = popx;
gbesty = popy;
gfitness = f(popx,popy);
% 初始: 群体(z)最优位置、群体最佳适应度
[zmin,z] = min(gfitness);
zfitness = zmin;    % 群体最佳适应度
zbestx = popx(z);
zbesty = popy(z);   % 群体最优位置

gen = 0;  % 进化次数
fprintf('粒子群搜索开始:\n')
while gen < maxgen
    % fprintf('第%d次循环\n',gen);
    % 每个个体速度更新: 速度一定更新！
    for gv = 1:1:popsize
        vx(gv) = w*vx(gv) + c1*rand()*(gbestx(gv)-popx(gv)) + c2*rand()*(zbestx-popx(gv));
        % vx方向的速度大小限制:
        if vx(gv) > Vmax
            vx(gv) = Vmax;
        elseif vx(gv) < Vmin
            vx(gv) = Vmin;
        end
        vy(gv) = w*vy(gv) + c1*rand()*(gbesty(gv)-popy(gv)) + c2*rand()*(zbesty-popy(gv));
        % vy方向的速度大小限制:
        if vy(gv) > Vmax
            vy(gv) = Vmax;
        elseif vy(gv) < Vmin
            vy(gv) = Vmin;
        end
    end
    
    % 每个个体的位置更新: 位置虽然一定在更新，但不一定是想要采用的最优位置！
    for gp = 1:1:popsize
        popx(gp) = popx(gp) + 0.5*vx(gp);
        popy(gp) = popy(gp) + 0.5*vy(gp);
        % x向位置限制:
        if popx(gp) > popmax
            popx(gp) = popmax;
        elseif popx(gp) < popmin
            popx(gp) = popmin;
        end
        % y向位置限制:
        if popy(gp) > popmax
            popy(gp) = popmax;
        elseif popy(gp) < popmin
            popy(gp) = popmin;
        end
    end
    
    % 计算每个个体新的适应度: 计算但不一定采用
    gfitness_tmp = f(popx,popy);
    
    % 每个个体的最优位置、最佳适应值更新:
    for gi = 1:1:popsize
        if gfitness_tmp(gi) < gfitness(gi)
            % 满足个体适应度值降低才更新个体最优位置,否则不变!
            gbestx(gi) = popx(gi);
            gbesty(gi) = popy(gi);
            gfitness(gi) = gfitness_tmp(gi);
        end
    end
    
    % 群体最优位置、最佳适应值更新:
    [zmin,z] = min(gfitness);
    zfitness = zmin;    % 群体最佳适应度
    zbestx = popx(z);
    zbesty = popy(z);   % 群体最优位置!
   
    % 下一次搜索:
    gen = gen + 1; 
end
fprintf('粒子群搜索到的极值点:(%.5f,%.5f,%.5f)\n\n', zbestx, zbesty, zfitness);

if zfitness < 0.001
    fprintf('粒子群精度足够高,不再进行梯度下降!\n');
    return ;
end

% 下面开始梯度下降精确搜索:
% 初始化:
syms x y;
f = 20 + x^2 + y^2 -10*(cos(2*pi*x) + cos(2*pi*y));
fx = diff(f,x);
fy = diff(f,y);
acc = 0.00001;     % 精度
study_step = 0.001; % 学习率
x = zbestx; 
y = zbesty;
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
        %plot3(ans_tmp(1),ans_tmp(2),f_tmp,'k.');
        %hold off
		break;
	end
	x = ans_tmp(1);
	y = ans_tmp(2);
	f_tmp = eval(f);
    %plot3(x,y,f_tmp,'k.')
    %hold on;
    k = k + 1;  % 计数器
end



