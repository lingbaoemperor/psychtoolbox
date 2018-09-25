function statistic_v1()
%占据图百分比，从混合目录中读取
animal = './animal/bk/';
files = dir(animal);
files = files(3:end);
len = length(files);
count = 0;
for k=1:len
    res = regexp(files(k).name,'\.','split');
    pre_name = res{1,1};
    to_num = str2num(pre_name);
    if isequal(to_num,[])
        continue
    end
    count = count + 1;
    [img map alpha] = imread([animal files(k).name]);
    [h,w,nn] = size(img);
    %alpha算的
    h = 512;
    w = 512;
    y1(count,1) = sum(sum(alpha ~= 0))/(h*w);
    y1(count,2) = to_num;
end
x1 = linspace(1,count,count);
y1 = sortrows(y1,1);
%文件编号-比例
% scatter(y1(:,2),y1(:,1),'r.');

vehicle = './vehicle/bk/';
files = dir(vehicle);
files = files(3:end);
len = length(files);
count = 0;
for k=1:len
    res = regexp(files(k).name,'\.','split');
    pre_name = res{1,1};
    to_num = str2num(pre_name);
    if isequal(to_num,[])
        continue
    end
    count = count + 1;
    [img map alpha] = imread([vehicle files(k).name]);
    [h,w,nn] = size(img);
    %alpha算的
    h = 512;
    w = 512;
    y2(count,1) = sum(sum(alpha ~= 0))/(h*w);
    y2(count,2) = to_num;
end
figure(1);
grid on
hold on
%顺序-比例
scatter(x1,y1(:,1)','r.');
x2 = linspace(1,count,count);
y2 = sortrows(y2,1);
scatter(x2,y2(:,1),'g.');
legend('animal','vehicle');
% scatter(y2(:,2),y2(:,1),'g.');
% plot(x1,y1,x2,y2);
save('./data/animal_what_toscaled','y1');
save('./data/vehicle_what_toscaled','y2');
end

