function scan_old()
%遍历文件，保存平滑后的透明图片，并编号
%动物
animal_dir = '.\animal\animal_final\';   
files = dir(animal_dir);
files = files(3:end,:);
%保存路径
save_path = '.\animal_transparent\';
save300_path = '.\animal_transparent_300\';
%滤波后二值化模板保存路径
bk_path = '.\animal\animal_bk\';
mkdir(save_path);
n = 0;
for k=1:length(files)
    list = regexp(files(k).name,'\.','split')
    if isequal(list{end,end},'bmp') == 1
        n = n+1;
        fname{1,n} = list{end,1};
    end
end

for i=1:n
    template = [animal_dir fname{1,i} '_tmp.png'];
    original = [animal_dir fname{1,i} '.bmp'];
    if exist(template,'file') && exist(original,'file')
        crop(template,original,save_path,i,bk_path,save300_path);
    end
end
%vehicle
% vehicle_dir = '.\vehicle\';   
% files = dir(vehicle_dir);
% files = files(3:end,:);
% save_path = '.\vehicle_transparent\';
% save300_path = '.\vehicle_transparent_300\';
% bk_path = '.\vehicle_bk\'
% mkdir(save_path);
% n = 0;
% for k=1:length(files)
%     list = regexp(files(k).name,'\.','split')
%     if isequal(list{end,end},'bmp') == 1
%         n = n+1;
%         fname{1,n} = list{end,1};
%     end
% end
% 
% for i=1:n
%     template = [vehicle_dir fname{1,i} '_tmp.png'];
%     original = [vehicle_dir fname{1,i} '.bmp'];
%     if exist(template,'file') && exist(original,'file')
%         crop(template,original,save_path,i,bk_path,[]);
%     end
% end
end