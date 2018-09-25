function cut_left()
%裁剪透明图片，只保留有target的部分,同时将对应的900张图片移到另一个文件夹
animal_dir = './animal/bk/';
vehicle_dir = './vehicle/bk/';
animal_des = './animal/transparent_cut/';
vehicle_des = './vehicle/transparent_cut/';
mkdir(vehicle_des);
mkdir(animal_des);
vehicles = dir(vehicle_dir);
vehicles = vehicles(3:end);
for i=1:length(vehicles)
    split = regexp(vehicles(i).name,'\.','split');
    pre_name = split{1,1};
    num = str2num(pre_name);
    if isequal(num,[])
        copyfile([vehicle_dir vehicles(i).name],[vehicle_des vehicles(i).name]);
        continue
    end
    if exist([vehicle_des vehicles(i).name])
        continue
    end
    [img map alpha] = imread([vehicle_dir vehicles(i).name]);
    [y1,x1] = find(alpha'~=0,1);
    [y2,x2] = find(alpha'~=0,1,'last');
    [x3,y3] = find(alpha~= 0,1);
    [x4,y4] = find(alpha~=0,1,'last');
    alpha = alpha(x1:x2,y3:y4);
    img = img(x1:x2,y3:y4,:);
    imwrite(img,[vehicle_des vehicles(i).name],'Alpha',alpha);
end

animals = dir(animal_dir);
animals = animals(3:end);
for i=1:length(animals)
    split = regexp(animals(i).name,'\.','split');
    pre_name = split{1,1};
    num = str2num(pre_name);
    if isequal(num,[])
        copyfile([animal_dir animals(i).name],[animal_des animals(i).name]);
        continue
    end
    if exist([animal_des animals(i).name])
        continue
    end
    [img map alpha] = imread([animal_dir animals(i).name]);
    [y1,x1] = find(alpha'~=0,1);
    [y2,x2] = find(alpha'~=0,1,'last');
    [x3,y3] = find(alpha~= 0,1);
    [x4,y4] = find(alpha~=0,1,'last');
    alpha = alpha(x1:x2,y3:y4);
    img = img(x1:x2,y3:y4,:);
    imwrite(img,[animal_des animals(i).name],'Alpha',alpha);
end

end

