function [images,N] = load_target_dir(this_directory,prefix)
%get list of BMP-files in this_directory
image_list = dir([this_directory prefix]);
image_list = image_list(3:end);
%��ͬtargetͼƬ�ߴ粻һ������������ָ���ߴ磬���ؿ��ܺ���
N = 0;
images = [];
for i=1:length(image_list)
    res = regexp(image_list(i).name,'\.','split');
    name = res(1,1);
    name = cell2mat(name);
    number = str2num(name);
    if isequal(number,[])
        continue
    end
    N = N+1;
    images(N).name = number;%image_list(i).name;
    %RGBA---target
    [images(N).target map alpha] = imread([this_directory image_list(i).name]);
    images(N).target(:,:,4) = alpha;
    %size of target
    [h,w,nn] = size(alpha);
    images(N).size = [h w];
    %pre_bk---expectation
    exp = dir([this_directory name '_bk.*']);
    exp = exp(1).name;
    images(N).expectation = imread([this_directory exp]);
    %����ϲ���ͼ���Ȳ�Ҫ
end
end

