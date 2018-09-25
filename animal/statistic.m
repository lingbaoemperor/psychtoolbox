function statistic()
%占据原图像的百分比
% animal = './animal/animal_bk/';
% animal = './animal/transparent_final/';
animal = './animal/animal_transparent/';
files = dir(animal);
files = files(3:end);
len = length(files);
x1 = linspace(1,len,len);
y1 = zeros(len,2);
for k=1:len
    %1.png
    [img map alpha] = imread([animal files(k).name]);
    %缩放
    %img = imresize(img,[300,300]);
    [h,w,nn] = size(img);
    %index = ['1' 'png']
    index = regexp(files(k).name,'\.','split');
    %index = '1'
    index = index(1,1);
    %index = 1
    index = str2num(cell2mat(index));
    %像素点个数
    %y1(1,index) = sum(img(img == 1));
    %占据原图像的百分比
    %黑板模板算的
%     y1(1,index) = sum(sum(img == 1))/(h*w);
    %alpha算的
    h = 512;
    w = 512;
    y1(k,1) = sum(sum(alpha ~= 0))/(h*w);
    y1(k,2) = index;
end
y1 = sortrows(y1,1);
figure(1);
hold on
%顺序-比例
scatter(x1,y1(:,1)','r.');
%文件编号-比例
% scatter(y1(:,2),y1(:,1),'r.');

vehicle = './vehicle/vehicle_transparent/';
files = dir(vehicle);
files = files(3:end);
len = length(files);
x2 = linspace(1,len,len);
y2 = zeros(len,2);

for k=1:len
    [img map alpha] = imread([vehicle files(k).name]);
    [h,w,nn] = size(img);
    index = regexp(files(k).name,'\.','split');
    index = index(1,1);
    index = str2num(cell2mat(index));
    %alpha算的
    h = 512;
    w = 512;
    y2(k,1) = sum(sum(alpha ~= 0))/(h*w);
    y2(k,2) = index;
end
y2 = sortrows(y2,1);
scatter(x2,y2(:,1),'g.');
grid on;
% scatter(y2(:,2),y2(:,1),'g.');
% plot(x1,y1,x2,y2);
%排序后，比例、文件序号
% save('./data/animal','y1');
% save('./data/vehicle','y2');
end

