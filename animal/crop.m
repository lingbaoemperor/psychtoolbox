function crop(template_path,original_path,save_path,number,bk_path,save300_path)
%��scan����
%����ģ��·��(RGB��ɫ)������ͼ��·��������Ŀ¼�����������(���ִ���)���˲���ڰ�ģ�屣��·��
%��ͼ������Ϊ͸������
template = imread(template_path);
original = imread(original_path);
template_bw = im2bw(template,0.1);

H = fspecial('gaussian',[10 10],1.5);
template_bw = imfilter(template_bw,H,'replicate');
%�ڰ�ģ�屣��
imwrite(template_bw,[bk_path num2str(number) '.png']);
%͸��ͼ�񱣴�
[h,w,nnn] = size(template);
alpha = zeros(h,w);
alpha(template_bw == 1) = 1;
imwrite(original,[save_path num2str(number) '.png'],'Alpha',alpha);
%��СΪ300*300����
if isequal(save300_path,[]) ~= 1
    img = imresize(original,[300,300]);
    alpha = imresize(alpha,[300,300]);
    imwrite(img,[save300_path num2str(number) '.png'],'Alpha',alpha);
end
end