function number()
%给透明图片编号，暂时用不上
transparent_path = './animal_transparent/';
bk_path = './animal_bk/';

files = dir(transparent_path);
files = files(3:end);
for i=1:length(files)
    img = imread([transparent_path files(i).name]);
    bk = imread([bk_path files(i).name]);
    [h,w,nn] = size(img);
    alpha = zeros(h,w);
    alpha(bk == 1) = 1;
    imwrite(img,[transparent_path num2str(i) '.png'],'Alpha',alpha);
end
end

