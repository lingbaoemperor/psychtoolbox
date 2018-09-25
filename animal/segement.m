function segement()
%筛选图片
%读取序号-比例数据
%去掉超过512的部分，画图
load('./data/animal.mat');
load('./data/vehicle.mat');
load('./data/v.txt');
load('./data/a.txt');
% [len,nn] = size(y1);
%百分比阈值
% percent = 0.6;
%%%%%%%%%%%%%%%
%%%%animal%%%%%
%%%%%%%%%%%%%%%
[C I] = setdiff(y1(:,2),a);
y1 = y1(I,:);
y1 = sortrows(y1,1);
[len,nn] = size(y1);
x1 = linspace(1,len,len);
%%%%%%%%%%%%%%%
%%%%vehicle%%%%
%%%%%%%%%%%%%%%
% [len,nn] = size(y2);
[C I] = setdiff(y2(:,2),v);
y2 = y2(I,:);
y2 = sortrows(y2,1);
[len,nn] = size(y2);

x2 = linspace(1,len,len);
scatter(x1,y1(:,1),'r.');
hold on;
scatter(x2,y2(:,1),'g.');
grid on;

% save('./data/animal_filter','y1');
% save('./data/vehicle_filter','y2');
end

