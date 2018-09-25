function scan_vehicle()
%vehicle
vehicle_dir = '.\vehicle\vehicle_final\';
template_dir = '.\vehicle\vehicle_tmp\';
files = dir(vehicle_dir);
files = files(3:end,:);
save_path = '.\vehicle\vehicle_transparent\';
save300_path = '';
bk_path = '.\vehicle\vehicle_bk\';
mkdir(save_path);
mkdir(save300_path);
mkdir(bk_path);
for k=1:length(files)
    list = regexp(files(k).name,'\.','split');
    num = list{end,1};
    template = [template_dir num '.png'];
    original = [vehicle_dir files(k).name];
    exs = [save_path num '.png']
    if  exist(template,'file') && exist(original,'file') && ~exist(exs,'file')
        crop(template,original,save_path,str2num(num),bk_path,save300_path);
    end
end
end

