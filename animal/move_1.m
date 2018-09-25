function move_1()
%模板和图片在一个文件夹，对应分开到两个文件夹 1.xxx 1_tmp.png
%已转移：货车、面包车、战斗机、飞机、防暴车
src = './vehicle/baidu_zong/船/';
des_target = './vehicle/vehicle_final/';
des_tmp = './vehicle/vehicle_tmp/';
form_original = '.jpg';
mkdir(des_target);
mkdir(des_tmp);
% 目标文件夹已有的文件数量，追加编号
t = dir(des_target);
[count nn] = size(t);
count = count - 2;
% 要移动的文件，必须偶数,原图+模板
files = dir(src);
for i = 3:length(files)
    res = regexp(files(i).name,'\.','split');
    res = res{1,1};
    num = str2num(res);
    if isequal(num,[])
        continue;
    end
    if exist([src res '_tmp.png'])
        count = count + 1;
        %src 1.bmp des 1.bmp
        copyfile([src files(i).name],[des_target num2str(count) form_original]);
        %src 1_tmp.png des 1.png
        copyfile([src res '_tmp.png'],[des_tmp num2str(count) '.png']);
    end
end

end

