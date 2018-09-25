function scan_animal()
%遍历文件，保存平滑后的透明图片，并编号
%动物
animal_dir = '.\animal\animal_final\';
template_dir = '.\animal\animal_tmp\';
files = dir(animal_dir);
files = files(3:end,:);
%保存路径
save_path = '.\animal\animal_transparent\';
save300_path = '';
%滤波后二值化模板保存路径
bk_path = '.\animal\animal_bk\';
mkdir(save_path);
mkdir(save300_path);
mkdir(bk_path);
for i=1:length(files)
    list = regexp(files(i).name,'\.','split');
    num = list{end,1};
    template = [template_dir num '.png'];
    original = [animal_dir files(i).name];
    exs = [save_path num '.png'];
    if exist(template,'file') && exist(original,'file') && ~exist(exs,'file')
        crop(template,original,save_path,str2num(num),bk_path,save300_path);
    end
end
end