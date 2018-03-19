function [images, N] = load_image_dir(this_directory,prefix);

%get list of BMP-files in this_directory
image_list = dir([this_directory prefix '*.png']);

%for faster loading, check the size of one image and use the information to reserve the memory
sample=imread([this_directory image_list(1).name]);
images = []; %uint8(zeros(size(sample,1),size(sample,2),3,length(image_list)));

%now iterate through all filenames and load them, convert them to grayscale, and store them in the "images" matrix
for N=1:min([30 length(image_list)])

    this_filename = [this_directory image_list(N).name];

    fprintf('loading %s\n',this_filename);
    images(:,:,:,N) = imread(this_filename);
    
end