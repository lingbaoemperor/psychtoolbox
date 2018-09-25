function move_3()
%原图文件夹、模板文件夹、透明文件夹
%手动删除某个图片后更新文件夹内图片序号
% src = './animal/animal_final/';
% tmp = './animal/animal_tmp/';
% transparent = './animal/animal_transparent/';
src = './vehicle/vehicle_final/';
tmp = './vehicle/vehicle_tmp/';
transparent = './vehicle/vehicle_transparent/';
files = dir(src);
files = files(3:end);
%名字序号排序
for i=1:length(files)
    res = regexp(files(i).name,'\.','split');
    num = res{1,1};
    num = str2num(num);
    if isequal(num,[])
        ['Error！！！']
        return
    end
    fname{i,1} = num;
    fname{i,2} = files(i).name;
    fname{i,3} = res{1,2};
end
fname = sortrows(fname);
for i=1:length(files)
    if isequal(fname{i,1},i)
        continue;
    end
    %源文件
    movefile([src fname{i,2}],[src num2str(i) '.' fname{i,3}]);
    %模板和透明
    name = [num2str(fname{i,1}) '.png'];
    movefile([tmp name],[tmp num2str(i) '.png']);
    movefile([transparent name],[transparent num2str(i) '.png']);
    %删除已经已移动的
%     delete([src fname{i,2}]);
%     delete([tmp name]);
%     delete([transparent name]);
end
end