%返回四对刺激反应帧数的平均值
function [c_X,c_plus,o_X,o_plus] = getOnesMean(name)
dump = dir;
file = '';
for i=1:length(dump)
    if(length(regexp(dump(i).name,['CFS_XPlus_' name '.+Result.mat'])) == 1)
        file = dump(i).name;
    end
end
load(file);
r = [];

for i=1:Preferences.Paradigm.NumberOfBlocks
    %target mask catchTrial tooEarly ResponseTime
    result = [];
    result(:,1) = Preferences.Block(i).Target_Type_Sequence';
	result(:,2) = Preferences.Block(i).Mask_Type_Sequence';
    for t=1:100
        result(t,3) = Preferences.Results.Block(i).Trial(t).CatchTrial;
        result(t,4) = Preferences.Results.Block(i).Trial(t).TooEarly;
        result(t,5) = Preferences.Results.Block(i).Trial(t).Response_Frame;
    end
    r = [r;result];
end
%X 1 + 2
%c传统mask 1 o倾斜mask 2
c_X = [];
c_plus = [];
o_X = [];
o_plus = [];
for i=1:200
    if(isequal(r(i,1:4),[1 1 0 0]))
        c_X = [c_X;r(i,:)];
    elseif(isequal(r(i,1:4),[1 2 0 0]))
        c_plus = [c_plus;r(i,:)];
    elseif(isequal(r(i,1:4),[2 1 0 0]))
        o_X = [o_X;r(i,:)];
    elseif(isequal(r(i,1:4),[2 2 0 0]))
        o_plus = [o_plus;r(i,:)];
    end
end
c_X = mean(c_X(:,5));
c_plus = mean(c_plus(:,5));
o_X = mean(o_X(:,5));
o_plus = mean(o_plus(:,5));
end