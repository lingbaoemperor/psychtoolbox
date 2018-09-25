function check_intersec()
%检查序号有没有错误
animal_dir = './animal/transparent_cut/';
vehicle_dir = './vehicle/transparent_cut/';
vehicle = dir(vehicle_dir);
vehicle = vehicle(3:end);
animal = dir(animal_dir);
animal = animal(3:end);
%animal 3 命名检查
i = 0;
for k=1:length(animal)
    split = regexp(animal(k).name,'\.','split');
    pre_name = split{1,1};
    num = str2num(pre_name);
    if isequal(num,[])
        continue
    end
    if (~exist([animal_dir pre_name '_bk.jpg']) && ~exist([animal_dir pre_name '_bk.bmp']) && ~exist([animal_dir pre_name '_bk.png'])) || ~exist([animal_dir pre_name '_merge.jpg'])
        pre_name
        continue
    end
    i = i+1;
    num = str2num(pre_name);
    animal_list(i) = num;
end
if length(animal_list) ~= 300
    fprintf('Error_Animal\n');
end

%vehicle 3 命名检查
i = 0;
for k=1:length(vehicle)
    split = regexp(vehicle(k).name,'\.','split');
    pre_name = split{1,1};
    num = str2num(pre_name);
    if isequal(num,[])
        continue
    end
    if (~exist([vehicle_dir pre_name '_bk.jpg']) &&...
        ~exist([vehicle_dir pre_name '_bk.bmp']) &&...
        ~exist([vehicle_dir pre_name '_bk.png'])) ||...
        ~exist([vehicle_dir pre_name '_merge.jpg'])
        continue
    end
    i = i+1;
    num = str2num(pre_name);
    vehicle_list(i) = num;
end
if length(vehicle_list) ~= 300
    fprintf('Error_Vehicle\n');
end

%vehicle 4 命名搭配检查
i = 0;
for k=1:length(vehicle)
    split = regexp(vehicle(k).name,'\.','split');
    pre_name = split{1,1};
    split = regexp(pre_name,'_','split');
    if length(split) ~= 3
        continue
    end
    num_str = split{1,1};
    pnum_str = split{1,end};
    pnum = str2num(pnum_str);
    if (~exist([vehicle_dir num_str '_bk.jpg']) && ...
        ~exist([vehicle_dir num_str '_bk.bmp']) && ...
        ~exist([vehicle_dir num_str '_bk.png'])) ||...
        ~exist([vehicle_dir num_str '.png']) ||...
        ~exist([vehicle_dir num_str '_merge.jpg'])
        fprintf('vehicle缺失!!!\n');
        continue
    end
    if exist('vehicle_match','var') && ismember(pnum,vehicle_match(:,2))
         [r,c] = find(vehicle_match == pnum);
         fprintf ('at %s:vehicle重复使用animal背景,背景%d已被%d使用!!!\n',num_str,pnum,vehicle_match(r,1));
         continue
    end
    i = i+1;
    %vehicle对应animal编号
    vehicle_match(i,1) = str2num(num_str);
    vehicle_match(i,2) = pnum;
end
%animal背景是否全部使用
[C,I] = setdiff(animal_list,vehicle_match(:,2));
if length(C) ~= 0
   fprintf('有未使用的animal背景%d个!!!：\n',length(C));
end
[C,I] = setdiff(vehicle_list,vehicle_match(:,1));
if length(C) ~= 0
   fprintf('有未使用的vehicle目标%d!!!：\n',length(C));
end

%animal 4 命名搭配检查
i = 0;
for k=1:length(animal)
    split = regexp(animal(k).name,'\.','split');
    pre_name = split{1,1};
    split = regexp(pre_name,'_','split');
    if length(split) ~= 3
        continue
    end
    num_str = split{1,1};
    pnum_str = split{1,end};
    pnum = str2num(pnum_str);
    if (~exist([animal_dir num_str '_bk.jpg']) && ...
        ~exist([animal_dir num_str '_bk.bmp']) && ...
        ~exist([animal_dir num_str '_bk.png'])) ||...
        ~exist([animal_dir num_str '.png']) ||...
        ~exist([animal_dir num_str '_merge.jpg'])
        fprintf('animal缺失!!!\n');
        continue
    end
    if exist('animai_match','var') && ismember(pnum,animal_match(:,2))
         [r,c] = find(animal_match == pnum);
         fprintf ('at %s:vehicle重复使用animal背景,背景%d已被%d使用!!!\n',num_str,pnum,animal_match(r,1));
         continue
    end
    i = i+1;
    %vehicle对应animal编号
    animal_match(i,1) = str2num(num_str);
    animal_match(i,2) = pnum;
end
%animal背景是否全部使用
[C,I] = setdiff(vehicle_list,animal_match(:,2));
if length(C) ~= 0
   fprintf('有未使用的vehicle背景：%d个!!!\n',length(C));
end
[C,I] = setdiff(animal_list,animal_match(:,1));
if length(C) ~= 0
   fprintf('有未使用的animal目标：%d个!!!\n',length(C));
end
end

