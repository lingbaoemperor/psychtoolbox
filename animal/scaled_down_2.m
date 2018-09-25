function scaled_down_2()
%缩小animal animal_transparent ->transparent_final
%vehicle_transparent ->transparent_final
src = './animal/animal_transparent/';
des = './animal/transparent_final/';
mkdir(des);
load('./data/animal_filter.mat');
scale = 0.7;
step = 0.1/5;
% step = [0.1/5 0.1/35 0.1/10 0.15/85 0.07/80 1];
[len nn] = size(y1)
for i=1:len
    switch i
        case 1
            scale = 0.7;
            step = -0.1/5;
        case 6
            scale = 0.6;
            step = 0.1/35;
        case 41
            scale = 0.7;
            step = 0.05/10;
        case 51
            scale = 0.75;
            step = 0.1/85;
        case 136
            scale = 0.85;
            step = 0.1/80;
        case 216
            scale = 0.95;
            step = 0;
        otherwise
    end
    scale = scale+step;
    num = num2str(y1(i,2));
    [img map alpha] = imread([src num '.png']);
    [h w d] = size(img);
    img = imresize(img,[h*scale,w*scale]);
    alpha = imresize(alpha,[h*scale,w*scale]);
    imwrite(img,[des num '.png'],'Alpha',alpha);
end

%vehicle
src = './vehicle/vehicle_transparent/';
des = './vehicle/transparent_final/';
mkdir(des);
load('./data/vehicle_filter.mat');
scale = 0.7;
[len nn] = size(y2)
for i=1:len
    break;
    num = num2str(y2(i,2));
    %从哪里开始缩小
    if i < 275
        copyfile([src num '.png'],[des num '.png']);
        continue;
    end
    [img map alpha] = imread([src num '.png']);
    [h w d] = size(img);
    img = imresize(img,[h*scale,w*scale]);
    alpha = imresize(alpha,[h*scale,w*scale]);
    imwrite(img,[des num '.png'],'Alpha',alpha);
end
end

