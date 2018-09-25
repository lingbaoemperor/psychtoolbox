function [animal_match,vehicle_match,images,N] = load_img_dir(Preferences)
animal_dir = Preferences.Target.Animal.Directory;
vehicle_dir = Preferences.Target.Vehicle.Directory;
vehicle = dir(vehicle_dir);
vehicle = vehicle(3:end);
animal = dir(animal_dir);
animal = animal(3:end);
%直接加载两次背景，免得后面还要查找，麻烦
%animal
N = 0;
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
         fprintf ('背景有重复!!!');
         sca;
    end
    N = N+1;
    %animal及对应vehicle背景的编号,num_str,pnum_str
    [img,map,alpha]= imread([animal_dir num_str '.png']);
    img(:,:,4) = alpha;
    images.Animal(N).Target = img;
    images.Animal(N).Target_Size = size(alpha);
    bk1 = dir([animal_dir num_str '_bk.*']);
    bk1 = bk1(1).name;
    images.Animal(N).Bk = imread([animal_dir bk1]);
    images.Animal(N).Num = str2num(num_str);
    %animal与vehicle对应关系
    animal_match(N,1) = str2num(num_str);
    animal_match(N,2) = pnum;
end

%vehicle
N = 0;
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
         fprintf ('背景有重复!!!');
         sca;
    end
    N = N+1;
    %animal及对应vehicle背景的编号,num_str,pnum_str
    [img,map,alpha]= imread([vehicle_dir num_str '.png']);
    img(:,:,4) = alpha;
    images.Vehicle(N).Target = img;
    images.Vehicle(N).Target_Size = size(alpha);
    bk1 = dir([vehicle_dir num_str '_bk.*']);
    bk1 = bk1(1).name;
    images.Vehicle(N).Bk = imread([vehicle_dir bk1]);
    images.Vehicle(N).Num = str2num(num_str);
    %animal与vehicle对应关系
    vehicle_match(N,1) = str2num(num_str);
    vehicle_match(N,2) = pnum;
end

end

