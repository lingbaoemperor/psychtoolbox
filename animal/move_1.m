function move_1()
%ģ���ͼƬ��һ���ļ��У���Ӧ�ֿ��������ļ��� 1.xxx 1_tmp.png
%��ת�ƣ��������������ս�������ɻ���������
src = './vehicle/baidu_zong/��/';
des_target = './vehicle/vehicle_final/';
des_tmp = './vehicle/vehicle_tmp/';
form_original = '.jpg';
mkdir(des_target);
mkdir(des_tmp);
% Ŀ���ļ������е��ļ�������׷�ӱ��
t = dir(des_target);
[count nn] = size(t);
count = count - 2;
% Ҫ�ƶ����ļ�������ż��,ԭͼ+ģ��
files = dir(src);
for i = 3:length(files)
    res = regexp(files(i).name,'\.','split');
    res = res{1,1};
    num = str2num(res);
    if isequal(num,[])
        continue;
    end
    if exist([src res '_tmp.png'])
        count = count + 1;
        %src 1.bmp des 1.bmp
        copyfile([src files(i).name],[des_target num2str(count) form_original]);
        %src 1_tmp.png des 1.png
        copyfile([src res '_tmp.png'],[des_tmp num2str(count) '.png']);
    end
end

end

