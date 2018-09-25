function scaled_down_1()
src = './vehicle/transparent_final/';
des = './vehicle/transparent_final_1/';
load('./data/vehicle_final.mat');
mkdir(des);
scale = 0.98;
step = 0;
% step = [0.1/5 0.1/35 0.1/10 0.15/85 0.07/80 1];
[len nn] = size(y2);
for i=1:len
    num = num2str(y2(i,2));
    if i<275
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

