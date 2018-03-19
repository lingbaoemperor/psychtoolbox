function the_mask = create_normal_mask(X,Y,N_Patches);

%  X=720;
%  Y=900;
the_mask=255*ones(Y,X,3);

min_x = 5;
max_x = 50;
min_y = 5;
max_y = 50;

    for i=1: N_Patches
        size_x = Shuffle (min_x: max_x);
        size_x = size_x(1);
        size_y = Shuffle (min_y: max_y);
        size_y = size_y(1);
        
        position_x = Shuffle (1:X);
        position_x = position_x(1);
        
        position_y = Shuffle (1:Y);
        position_y = position_y(1);
        
        colors=Shuffle('rgbcmykw');
        colors=colors(1);
        switch colors
            case 'r'
                color_R=255;
                color_G=0;
                color_B=0;
            case 'g'
                color_R=0;
                color_G=255;
                color_B=0;
            case 'b'
                color_R=0;
                color_G=0;
                color_B=255;
            case 'c'
                color_R=0;
                color_G=255;
                color_B=255;
            case 'm'
                color_R=255;
                color_G=0;
                color_B=255;
            case 'y'
                color_R=255;
                color_G=255;
                color_B=0;
            case 'k'
                color_R=0;
                color_G=0;
                color_B=0;
            case 'w'
                color_R=255;
                color_G=255;
                color_B=255;
        end
        
        
        for x=round(position_x-size_x/2: position_x+size_x/2-1)
            if x>0 && x <= X
                for y= round(position_y-size_y/2: position_y+size_y/2-1)
                    if y>0 && y <= Y
                        the_mask(y,x,1)=color_R;
                        the_mask(y,x,2)=color_G;
                        the_mask(y,x,3)=color_B;
                    end
                end
            end
        end
	end
