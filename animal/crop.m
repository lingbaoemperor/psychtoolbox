function crop(template_path,original_path,save_path,number,bk_path,save300_path)
%由scan调用
%完整模板路径(RGB红色)，完整图像路径，保存目录，保存的名字(数字代表)，滤波后黑白模板保存路径
%抠图并保存为透明背景
template = imread(template_path);
original = imread(original_path);
template_bw = im2bw(template,0.1);

H = fspecial('gaussian',[10 10],1.5);
template_bw = imfilter(template_bw,H,'replicate');
%黑板模板保存
imwrite(template_bw,[bk_path num2str(number) '.png']);
%透明图像保存
[h,w,nnn] = size(template);
alpha = zeros(h,w);
alpha(template_bw == 1) = 1;
imwrite(original,[save_path num2str(number) '.png'],'Alpha',alpha);
%缩小为300*300保存
if isequal(save300_path,[]) ~= 1
    img = imresize(original,[300,300]);
    alpha = imresize(alpha,[300,300]);
    imwrite(img,[save300_path num2str(number) '.png'],'Alpha',alpha);
end
end