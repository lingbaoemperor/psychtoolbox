function anova()
%方差分析原理详解（未完待续）
x = [0.84 1.05 1.20 1.20 1.39 1.53 1.67 1.80 1.87 2.07 2.11];
y = [0.54 0.64 0.64 0.75 0.76 0.81 1.16 1.20 1.34 1.35 1.48 1.56 1.87];
[nnn,size_group1] = size(x);
[nnn,size_group2] = size(y);
mean_all = mean([x y]);
mean_group1 = mean(x)
mean_group2 = mean(y)
%组间离差,各组均值与总均值的差的平方和
ssb = sum((mean_group1-mean_all)^2)*size_group1+sum((mean_group2-mean_all)^2)*size_group2;
%组内离差,各组均值与组内值的差的平方和
ssw = sum((x-mean_group1).^2)+sum((y-mean_group2).^2);
%未完待续%
end

