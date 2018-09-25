function scaled_down_1()
src = './animal/bin_͸��/����/';
des = './animal/bin_͸��/����С/';
files = dir(src);
files = files(3:end);
scale = 2/3;
for i=1:length(files)
    [img map alpha] = imread([src files(i).name]);
    [h w d] = size(img);
    img = imresize(img,[h*scale,w*scale]);
    alpha = imresize(alpha,[h*scale,w*scale]);
    imwrite(img,[des files(i).name],'Alpha',alpha);
end
end

