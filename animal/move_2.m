function move_2()
%�����ϵĵ�͸��ͼƬ��׷���ƶ���͸��ͼƬĿ¼��
% src = './animal/bin_͸��/scaled/';
% des = './animal/animal_transparent/';
src = './animal/bin_͸��/scaled/';
des = './animal/animal_transparent/';
mkdir(des);
files = dir(src);
num = dir(des);
[num nn] = size(num);
num = num-2;
for i=3:length(files)
    num = num + 1;
%     [img map al] = imread([src files(i).name]);
%     [h,w,nn] = size(img);
%     alpha = zeros(h,w);
%     255 -> 1
%     alpha(al == 255) = 1;
%     imwrite(img,[des num2str(num) '.png'],'Alpha',alpha);
    copyfile([src files(i).name],[des num2str(num) '.png']);
end

end

