function move_4()
%��С��ĺϲ� xx_min -> xx
src = './animal/z/animal_z/';
des = './animal/bk/';
files = dir(src);
files = files(3:end);
%�����������
for i=1:length(files)
    %112.bmp
    res = regexp(files(i).name,'\.','split');
    pre_name = res{1,1};
    to_num = str2num(pre_name);
    after_name = res{1,2};
    if isequal(to_num,[]) == 0
        continue
    end
    res1  = regexp(pre_name,'_','split');
    num = res1{1,1};
    if isequal(num,[])
        ['Error:' files(i).name]
    end
    %���֡�ȫ�ơ���׺
    f_src{i,1} = num;
    f_src{i,2} = files(i).name;
    f_src{i,3} = res{1,2};
    copyfile([src files(i).name],[des num '.' after_name]);
end
end