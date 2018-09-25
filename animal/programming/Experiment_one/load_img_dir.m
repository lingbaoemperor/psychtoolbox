function [animal_match,vehicle_match,images,N] = load_img_dir(Preferences)
animal_dir = Preferences.Target.Animal.Directory;
vehicle_dir = Preferences.Target.Vehicle.Directory;
vehicle = dir(vehicle_dir);
vehicle = vehicle(3:end);
animal = dir(animal_dir);
animal = animal(3:end);
%ֱ�Ӽ������α�������ú��滹Ҫ���ң��鷳
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
        fprintf('animalȱʧ!!!\n');
        continue
    end
    if exist('animai_match','var') && ismember(pnum,animal_match(:,2))
         fprintf ('�������ظ�!!!');
         sca;
    end
    N = N+1;
    %animal����Ӧvehicle�����ı��,num_str,pnum_str
    [img,map,alpha]= imread([animal_dir num_str '.png']);
    img(:,:,4) = alpha;
    images.Animal(N).Target = img;
    images.Animal(N).Target_Size = size(alpha);
    bk1 = dir([animal_dir num_str '_bk.*']);
    bk1 = bk1(1).name;
    images.Animal(N).Bk = imread([animal_dir bk1]);
    images.Animal(N).Num = str2num(num_str);
    %animal��vehicle��Ӧ��ϵ
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
        fprintf('vehicleȱʧ!!!\n');
        continue
    end
    if exist('vehicle_match','var') && ismember(pnum,vehicle_match(:,2))
         fprintf ('�������ظ�!!!');
         sca;
    end
    N = N+1;
    %animal����Ӧvehicle�����ı��,num_str,pnum_str
    [img,map,alpha]= imread([vehicle_dir num_str '.png']);
    img(:,:,4) = alpha;
    images.Vehicle(N).Target = img;
    images.Vehicle(N).Target_Size = size(alpha);
    bk1 = dir([vehicle_dir num_str '_bk.*']);
    bk1 = bk1(1).name;
    images.Vehicle(N).Bk = imread([vehicle_dir bk1]);
    images.Vehicle(N).Num = str2num(num_str);
    %animal��vehicle��Ӧ��ϵ
    vehicle_match(N,1) = str2num(num_str);
    vehicle_match(N,2) = pnum;
end

end

