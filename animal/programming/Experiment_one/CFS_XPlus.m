%need to enable alpha blending to make on-the-fly contrast work the way we want it to
Screen('BlendFunction', my_window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
send_trigger('set screen blend function',1,Preferences);

cX = Preferences.Screen_Resolution_X/2;
cY = Preferences.Screen_Resolution_Y/2;

Screen('FillRect', my_window, [127 127 127],[cX-Preferences.Desired_Screen_Resolution_X/2,cY-Preferences.Desired_Screen_Resolution_Y/2,cX+Preferences.Desired_Screen_Resolution_X/2,cY+Preferences.Desired_Screen_Resolution_Y/2]);
ShowText = 'Loading...';
Screen('TextSize', my_window , 50);
DrawFormattedText(my_window, ShowText, 'center', cY, [0 255 255]);
Screen('Flip', my_window);




% Preferences.DominantEye = 1; %-1 for left eye, 1 for right eye
Preferences.Target.Animal.Directory = 'G:\workdoc\matlab\psychtoolbox\animal\animal\transparent_cut\';
Preferences.Target.Vehicle.Directory = 'G:\workdoc\matlab\psychtoolbox\animal\vehicle\transparent_cut\';
Preferences.Mask.Cardinal.Directory = 'Masks_Cardinal/';

Preferences.RandomSeed = sum(100*clock);
%2010的版本用getDefaultStream，暂时不知道会不会有影响
reset(RandStream.getDefaultStream,Preferences.RandomSeed);

Preferences.SideBars.Outer = 480;
Preferences.SideBars.Inner = 30;
Preferences.SideBars.HalfHeight = 280;
Preferences.SideBars.FullWidth = 450;
Preferences.SideBars.Width = 5;

Preferences.Mask.Eccentricity.X = Preferences.DominantEye*(round((Preferences.SideBars.Outer - Preferences.SideBars.Inner)/2) + Preferences.SideBars.Inner);
Preferences.Mask.Eccentricity.Y = 0;
Preferences.Target.Eccentricity.X = Preferences.DominantEye*-1*(round((Preferences.SideBars.Outer - Preferences.SideBars.Inner)/2) + Preferences.SideBars.Inner);
Preferences.Target.Eccentricity.Y = 0;
%Expectation显示尺寸
Preferences.Expectation.Size.X = 400;
Preferences.Expectation.Size.Y = 400;
%透明Target缩放显示程度
Preferences.Target.ScaledPercent = 1;
%mask出现前fixation时间
Preferences.Paradigm.FixationWait.Fixed = 0.8;
Preferences.Paradigm.FixationWait.Random = 0.2;
%expectation出现后fixation时间
%暂时用上面的

Preferences.Paradigm.NumberOfPerTarget = 300;
%4 kind of assembly
Preferences.Paradigm.NumberOfType = 4;
Preferences.Paradigm.OneTypePerBlock = 20;
Preferences.Paradigm.Catch_TrialsPerBlock = 20;
Preferences.Paradigm.TrialsPerBlock = 4*20+20;%Preferences.Paradigm.NumberOfType*Preferences.Paradigm.OneTypePerBlock+Preferences.Paradigm.Catch_TrialsPerBlock;
Preferences.Paradigm.NumberOfBlocks = 300/20;

%保存的属性
Preferences.Paradigm.RefreshRate = 60; %assume this many Hz screen refresh
Preferences.Paradigm.FramesPerMask = [20];  %one mask should be visible for this many frames. At 120hz, 20 Frames correspond to 6Hz.
Preferences.Paradigm.PreStimulusMasks.Fixed = 1.5; %600ms masking before anything
Preferences.Paradigm.PreStimulusMasks.Random = 0.5; %add up to 200ms extra for randomization
Preferences.Paradigm.MaxStimulusDuration = 6; %wait up to 6s = for the subject to push a button.
Preferences.Paradigm.NumberOfMaskFrames = (Preferences.Paradigm.PreStimulusMasks.Fixed + Preferences.Paradigm.PreStimulusMasks.Random + Preferences.Paradigm.MaxStimulusDuration)*Preferences.Paradigm.RefreshRate;
Preferences.Paradigm.NumberOfMasks = ceil(Preferences.Paradigm.NumberOfMaskFrames/min(Preferences.Paradigm.FramesPerMask(:)));

Preferences.Paradigm.FramesToMaxContrast = Preferences.Paradigm.MaxStimulusDuration * Preferences.Paradigm.RefreshRate; %number of actual frames until max contrast is reached
Preferences.Paradigm.MinContrast = 0; %min contrast
Preferences.Paradigm.MaxContrast = 1; %max contrast
Preferences.Paradigm.ContrastStep = (Preferences.Paradigm.MaxContrast - Preferences.Paradigm.MinContrast) / Preferences.Paradigm.FramesToMaxContrast;
Preferences.Paradigm.ContrastRamp = Preferences.Paradigm.MinContrast:Preferences.Paradigm.ContrastStep:Preferences.Paradigm.MaxContrast;

Preferences.Paradigm.RestTime = 30;  % have a break 30 ms between blocks.

%%%%%%%%%%load all mask images at the beginning of the experiment
%返回图片数据和索引-mask
[AllMasks.the_masks,AllMasks.N]=load_mask_dir(Preferences.Mask.Cardinal.Directory,'');
% [AllTargets(1).the_targets,AllTargets(1).N]=load_target_dir(Preferences.Target.Animal.Directory,'');
[Animal_Nature,Vehicle_Manmade,AllImages,N] = load_img_dir(Preferences);
%%%%%%%  save all "MakeTexture" in advance
send_trigger(sprintf('loaded images.'), 1, Preferences);
%Mask 尺寸不变
Preferences.Mask.Size.X=size(AllMasks.the_masks,2);
Preferences.Mask.Size.Y=size(AllMasks.the_masks,1);

%convert masks to textures
for n = 1:AllMasks.N
    CardinalTextures(n) = Screen('MakeTexture',my_window,squeeze(AllMasks.the_masks(:,:,:,n)));
end    
%convert targets to textures
for n = 1:N
    AllImages.Animal(n).Target = Screen('MakeTexture',my_window,squeeze(AllImages.Animal(n).Target));
    AllImages.Animal(n).Bk = Screen('MakeTexture',my_window,squeeze(AllImages.Animal(n).Bk));
end
for n = 1:N
    AllImages.Vehicle(n).Target = Screen('MakeTexture',my_window,squeeze(AllImages.Vehicle(n).Target));
    AllImages.Vehicle(n).Bk = Screen('MakeTexture',my_window,squeeze(AllImages.Vehicle(n).Bk));
end

send_trigger(sprintf('created textures.'), 1, Preferences);
%clear Memory
clear AllMask;

%4中组合随机，此处保存目标和期望图片数组中的索引，顺序打乱
tmp = 1:Preferences.Paradigm.NumberOfPerTarget;
Animal_With_Nature_Sequence = Shuffle(tmp);
Animal_With_Nature_Sequence = [Animal_With_Nature_Sequence' Animal_With_Nature_Sequence'];

tmp = 1:Preferences.Paradigm.NumberOfPerTarget;
Vehicle_With_Manmade_Sequence = Shuffle(tmp);
Vehicle_With_Manmade_Sequence = [Vehicle_With_Manmade_Sequence' Vehicle_With_Manmade_Sequence'];

tmp = 1:Preferences.Paradigm.NumberOfPerTarget;
Animal_With_Manmade_Sequence = Shuffle(tmp);
[TF,LOC] = ismember(Animal_Nature(Animal_With_Manmade_Sequence,2),Vehicle_Manmade(:,1));
Animal_With_Manmade_Sequence = [Animal_With_Manmade_Sequence' LOC];

tmp = 1:Preferences.Paradigm.NumberOfPerTarget;
Vehicle_With_Nature_Sequence = Shuffle(tmp);
[TF,LOC] = ismember(Vehicle_Manmade(Vehicle_With_Nature_Sequence,2),Animal_Nature(:,1));
Vehicle_With_Nature_Sequence = [Vehicle_With_Nature_Sequence' LOC];

%1200个trial的信息
%1200*5 target_index、exp_index、target、expectation、type
%第6列反应时间，第七列TooEarly
%前两列代表target和exp在矩阵中的索引
Type1 = [Animal_With_Nature_Sequence Animal_Nature(Animal_With_Nature_Sequence(:,1),1) Animal_Nature(Animal_With_Nature_Sequence(:,1),1) ones(Preferences.Paradigm.NumberOfPerTarget,1)];
Type2 = [Vehicle_With_Manmade_Sequence Vehicle_Manmade(Vehicle_With_Manmade_Sequence(:,1),1) Vehicle_Manmade(Vehicle_With_Manmade_Sequence(:,1),1) ones(Preferences.Paradigm.NumberOfPerTarget,1)*2];

Type3 = [Animal_With_Manmade_Sequence Animal_Nature(Animal_With_Manmade_Sequence(:,1),:) ones(Preferences.Paradigm.NumberOfPerTarget,1)*3];
Type4 = [Vehicle_With_Nature_Sequence Vehicle_Manmade(Vehicle_With_Nature_Sequence(:,1),:) ones(Preferences.Paradigm.NumberOfPerTarget,1)*4];
clear tmp;
clear Animal_Nature;
clear Vehicle_Manmade;
%这里增加一个记录当前block用到的Target起始标记，表示该Block中第一个trial起始索引
Base = 1;
for block = 1:Preferences.Paradigm.NumberOfBlocks
    send_trigger(sprintf('START_BLOCK: %d',block), 1, Preferences);
    %一个block中trial的顺序,distractor暂时填1
    tmp = [Type1(Base:Base+Preferences.Paradigm.OneTypePerBlock-1,:);...
        Type2(Base:Base+Preferences.Paradigm.OneTypePerBlock-1,:);...
        Type3(Base:Base+Preferences.Paradigm.OneTypePerBlock-1,:);...
        Type4(Base:Base+Preferences.Paradigm.OneTypePerBlock-1,:);...
        ones(Preferences.Paradigm.Catch_TrialsPerBlock,5)*0];
    Preferences.Block(block).Trials = Shuffle(tmp,2);
    Base = Base+Preferences.Paradigm.OneTypePerBlock;
    
    %创建mask
	send_trigger('Creating mask playback vectors...',1,Preferences);
    
    %N张mask
	MaskVector = 1:AllMasks.N;
	this_shuffle = Shuffle(MaskVector);
	
    %一个block每个trial要播放的mask
	for k = 1:Preferences.Paradigm.TrialsPerBlock
	
        this_mask_vector = Shuffle(MaskVector);
        %如果mask张数不够一个trial的需要,补齐，超过了后面会截断，这里不是指帧数，是除以帧数的以后的张数
        while length(this_mask_vector)<Preferences.Paradigm.NumberOfMasks
        
            this_shuffle = Shuffle(MaskVector) %create a randomized sequence of all masks
            while this_shuffle(1)==this_mask_vector(end)
                this_shuffle = Shuffle(MaskVector);
            end
            
            this_mask_vector = [this_mask_vector this_shuffle];
            
        end
        
        %总的mask显示索引组数，现在乘以每个显示的帧数，即每张显示多少帧,结果是整个trial美帧的mask种类数组
        this_playback_vector =[];
        for frame = 1:length(this_mask_vector)
            this_playback_vector = [this_playback_vector ones(1,Preferences.Paradigm.FramesPerMask)*this_mask_vector(frame)];
        end
        %截断超出的，同上，这里保存一个trial每帧的mask总类索引数组
        Ordered_Masking_Sequence(k).MaskPlaybackVector =  this_playback_vector(1:Preferences.Paradigm.NumberOfMaskFrames); %random selection of masks 
	
	end

	%打乱并确定本block中target种类的显示顺序，保证每个mask和target组合数量是相等的
	Preferences.Block(block).Masking_Sequence = Ordered_Masking_Sequence;

	send_trigger('Trial sequence prepared!',1,Preferences);

    %%%% give 30s break between blocks!
    if block ~= 1
        %休息间隔，按键开始
        remaining_time = Preferences.Paradigm.RestTime;
        while remaining_time>0
            %%%DRAW GRAY BACKGROUND
            Screen('FillRect', my_window, [127 127 127],[cX-Preferences.Desired_Screen_Resolution_X/2,cY-Preferences.Desired_Screen_Resolution_Y/2,cX+Preferences.Desired_Screen_Resolution_X/2,cY+Preferences.Desired_Screen_Resolution_Y/2]);
            ShowText = sprintf('Please have a break for %02d seconds before block %d', remaining_time,block);
            Screen('TextSize', my_window , 50);
            DrawFormattedText(my_window, ShowText, 'center', cY, [0 255 255]);
            Screen('Flip', my_window);
            WaitSecs(1);
            remaining_time = remaining_time -1;
        end
        Screen('FillRect', my_window, [127 127 127],[cX-Preferences.Desired_Screen_Resolution_X/2,cY-Preferences.Desired_Screen_Resolution_Y/2,cX+Preferences.Desired_Screen_Resolution_X/2,cY+Preferences.Desired_Screen_Resolution_Y/2]);
        ShowText = strcat ('Press any key to continue');
        Screen('TextSize', my_window , 50);
        Screen('DrawText', my_window, ShowText, cX-180, cY+50, [255 255 0]);
        Screen('Flip', my_window);
        JanKbWait(Preferences.Automatic);
    end
    %调屏
    done = false;
    KbWait(0,1);
    while ~done
        
        %%%%ALIGNMENT
        %%%DRAW GRAY BACKGROUND
        Screen('FillRect', my_window, [127 127 127],[cX-Preferences.Desired_Screen_Resolution_X/2,cY-Preferences.Desired_Screen_Resolution_Y/2,cX+Preferences.Desired_Screen_Resolution_X/2,cY+Preferences.Desired_Screen_Resolution_Y/2]);
        
        %%%DRAW BLUE-YELLOW ALIGNMENT BARS
        %left-outer
        Screen('DrawLine', my_window, [0 0 255], cX - Preferences.SideBars.Outer, cY - Preferences.SideBars.HalfHeight, cX - Preferences.SideBars.Outer, cY + Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);
        %right-outer
        Screen('DrawLine', my_window, [255 255 0], cX + Preferences.SideBars.Outer, cY - Preferences.SideBars.HalfHeight, cX + Preferences.SideBars.Outer, cY + Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);
        %left-inner
        Screen('DrawLine', my_window, [0 0 255], cX - Preferences.SideBars.Inner, cY - Preferences.SideBars.HalfHeight, cX - Preferences.SideBars.Inner, cY + Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);
        %right-inner
        Screen('DrawLine', my_window, [255 255 0], cX + Preferences.SideBars.Inner, cY - Preferences.SideBars.HalfHeight, cX + Preferences.SideBars.Inner, cY + Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);
        
        %left-upper
        Screen('DrawLine', my_window, [0 0 255], cX - Preferences.SideBars.Outer, cY - Preferences.SideBars.HalfHeight, cX - Preferences.SideBars.Outer + Preferences.SideBars.FullWidth, cY - Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);
        %left-lower
        Screen('DrawLine', my_window, [0 0 255], cX - Preferences.SideBars.Outer, cY + Preferences.SideBars.HalfHeight, cX - Preferences.SideBars.Outer + Preferences.SideBars.FullWidth, cY + Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);
        %right-upper
        Screen('DrawLine', my_window, [255 255 0], cX + Preferences.SideBars.Inner, cY - Preferences.SideBars.HalfHeight, cX + Preferences.SideBars.Inner + Preferences.SideBars.FullWidth, cY - Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);
        %right-lower
        Screen('DrawLine', my_window, [255 255 0], cX + Preferences.SideBars.Inner, cY + Preferences.SideBars.HalfHeight, cX + Preferences.SideBars.Inner + Preferences.SideBars.FullWidth, cY + Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);
        
        %%%DRAW BLUE-YELLOW FIXATION CROSSES
        Screen('DrawLine', my_window, [0 0 255], cX - Preferences.Mask.Eccentricity.X, cY - Preferences.Mask.Eccentricity.Y-7, cX - Preferences.Mask.Eccentricity.X, cY - Preferences.Mask.Eccentricity.Y+6,3);
        Screen('DrawLine', my_window, [0 0 255], cX - Preferences.Mask.Eccentricity.X-7, cY - Preferences.Mask.Eccentricity.Y, cX - Preferences.Mask.Eccentricity.X+6, cY - Preferences.Mask.Eccentricity.Y,3);
        Screen('DrawLine', my_window, [255 255 0], cX + Preferences.Mask.Eccentricity.X, cY - Preferences.Mask.Eccentricity.Y-7, cX + Preferences.Mask.Eccentricity.X, cY - Preferences.Mask.Eccentricity.Y+6,3);
        Screen('DrawLine', my_window, [255 255 0], cX + Preferences.Mask.Eccentricity.X-7, cY - Preferences.Mask.Eccentricity.Y, cX + Preferences.Mask.Eccentricity.X+6, cY - Preferences.Mask.Eccentricity.Y,3);
        
        Screen('Flip',my_window);
        send_trigger('SHOW_ALIGNMENT', 1, Preferences);
        
        
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck();
        if keyIsDown
            input = KbName(keyCode);
            if iscell(input)
                input = input{1};
            end
            switch input
                case 'm'
                    %increase offset
                    Preferences.SideBars.Outer = Preferences.SideBars.Outer +Preferences.DominantEye;
                    Preferences.SideBars.Inner = Preferences.SideBars.Inner +Preferences.DominantEye;
                    
                case 'n'
                    %decrease offset
                    Preferences.SideBars.Outer = Preferences.SideBars.Outer -Preferences.DominantEye;
                    Preferences.SideBars.Inner = Preferences.SideBars.Inner -Preferences.DominantEye;
                    
                case 'space'
                    done = true;
            end
            
            Preferences.Mask.Eccentricity.X = Preferences.DominantEye*(round((Preferences.SideBars.Outer - Preferences.SideBars.Inner)/2) + Preferences.SideBars.Inner);
            Preferences.Target.Eccentricity.X = Preferences.DominantEye*-1*(round((Preferences.SideBars.Outer - Preferences.SideBars.Inner)/2) + Preferences.SideBars.Inner);
            
        end
        
    end
        
    %store for later use
    %调整后的数据保存，显示时要用
    Preferences.Results.Block(block).Mask.Eccentricity.X = Preferences.Mask.Eccentricity.X ;
    Preferences.Results.Block(block).Mask.Eccentricity.Y = Preferences.Mask.Eccentricity.Y ;
  
    %开始实验
    for trial = 1:Preferences.Paradigm.TrialsPerBlock
        
        send_trigger(sprintf('START_TRIAL: %d of block %d',trial,block), 1, Preferences);

        %randomize the timing of this trial
        %在看到targrt出现之前等待一个随机时间和一个fixation的时间
        this_random_period = randi(ceil(Preferences.Paradigm.PreStimulusMasks.Random*Preferences.Paradigm.RefreshRate));
        this_fixed_period = ceil(Preferences.Paradigm.PreStimulusMasks.Fixed*Preferences.Paradigm.RefreshRate);
        this_N_Frames = length(Preferences.Block(block).Masking_Sequence(trial).MaskPlaybackVector);
        this_MaskPlaybackVector = Preferences.Block(block).Masking_Sequence(trial).MaskPlaybackVector;
		
		this_Target = 0;
        target_index = Preferences.Block(block).Trials(trial,1);
        exp_index = Preferences.Block(block).Trials(trial,2);
		if Preferences.Block(block).Trials(trial,5) == 1;
            this_Target = AllImages.Animal(target_index).Target;
            this_Exp = AllImages.Animal(exp_index).Bk;
            target_Y = AllImages.Animal(target_index).Target_Size(1);
            target_X = AllImages.Animal(target_index).Target_Size(2);
        elseif Preferences.Block(block).Trials(trial,5) == 2;
            this_Target = AllImages.Vehicle(target_index).Target;
            this_Exp = AllImages.Vehicle(exp_index).Bk;
            target_Y = AllImages.Vehicle(target_index).Target_Size(1);
            target_X = AllImages.Vehicle(target_index).Target_Size(2);
        elseif Preferences.Block(block).Trials(trial,5) == 3;
            this_Target = AllImages.Animal(target_index).Target;
            this_Exp = AllImages.Vehicle(exp_index).Bk;
            target_Y = AllImages.Animal(target_index).Target_Size(1);
            target_X = AllImages.Animal(target_index).Target_Size(2);
        elseif Preferences.Block(block).Trials(trial,5) == 4;
            this_Target = AllImages.Vehicle(target_index).Target;
            this_Exp = AllImages.Animal(exp_index).Bk;
            target_Y = AllImages.Vehicle(target_index).Target_Size(1);
            target_X = AllImages.Vehicle(target_index).Target_Size(2);
        elseif Preferences.Block(block).Trials(trial,5) == 0;
            fprintf('Catch Trial:%n\n',trial);
        else
            fprintf('Unknow Type!!!\n');
            break
        end
   
        
%         this_random_frame = randi(this_N_Frames); %this is only for the automatic mode.
        
        
        %build contrast vector for this trial
        this_ContrastVector = [zeros(1,this_fixed_period) zeros(1,this_random_period) Preferences.Paradigm.ContrastRamp]; %start with zero, then add the ramp to 50%
		this_ContrastVector = [this_ContrastVector ones(1,this_N_Frames - length(this_ContrastVector))];
		
        if Preferences.Block(block).Trials(trial,5) == 0 %if this is a catch trial...
            this_ContrastVector = this_ContrastVector * 0; %...then set all contrasts to zero and...
        else
            %do nothing
        end    

        Preferences.Block(block).Contrast(trial).ContrastVector = this_ContrastVector; %save for later.

%         save GARBAGE Preferences
        
        %%%%PARADIGM
        %Step 1: show fixation for randomized interval before expectation

            %%%DRAW GRAY BACKGROUND
            Screen('FillRect', my_window, [127 127 127],[cX-Preferences.Desired_Screen_Resolution_X/2,cY-Preferences.Desired_Screen_Resolution_Y/2,cX+Preferences.Desired_Screen_Resolution_X/2,cY+Preferences.Desired_Screen_Resolution_Y/2]);

            %%%DRAW WHITE FIXATION CROSSES
            Screen('DrawLine', my_window, [255 255 255], cX - Preferences.Mask.Eccentricity.X, cY - Preferences.Mask.Eccentricity.Y-7, cX - Preferences.Mask.Eccentricity.X, cY - Preferences.Mask.Eccentricity.Y+6,3);
            Screen('DrawLine', my_window, [255 255 255], cX - Preferences.Mask.Eccentricity.X-7, cY - Preferences.Mask.Eccentricity.Y, cX - Preferences.Mask.Eccentricity.X+6, cY - Preferences.Mask.Eccentricity.Y,3);
            Screen('DrawLine', my_window, [255 255 255], cX + Preferences.Mask.Eccentricity.X, cY - Preferences.Mask.Eccentricity.Y-7, cX + Preferences.Mask.Eccentricity.X, cY - Preferences.Mask.Eccentricity.Y+6,3);
            Screen('DrawLine', my_window, [255 255 255], cX + Preferences.Mask.Eccentricity.X-7, cY - Preferences.Mask.Eccentricity.Y, cX + Preferences.Mask.Eccentricity.X+6, cY - Preferences.Mask.Eccentricity.Y,3);

            %%%DRAW WHITE ALIGNMENT BARS
            %left-outer
            Screen('DrawLine', my_window, [255 255 255], cX - Preferences.SideBars.Outer, cY - Preferences.SideBars.HalfHeight, cX - Preferences.SideBars.Outer, cY + Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);
            %right-outer
            Screen('DrawLine', my_window, [255 255 255], cX + Preferences.SideBars.Outer, cY - Preferences.SideBars.HalfHeight, cX + Preferences.SideBars.Outer, cY + Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);
            %left-inner
            Screen('DrawLine', my_window, [255 255 255], cX - Preferences.SideBars.Inner, cY - Preferences.SideBars.HalfHeight, cX - Preferences.SideBars.Inner, cY + Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);
            %right-inner
            Screen('DrawLine', my_window, [255 255 255], cX + Preferences.SideBars.Inner, cY - Preferences.SideBars.HalfHeight, cX + Preferences.SideBars.Inner, cY + Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);

            %left-upper
            Screen('DrawLine', my_window, [255 255 255], cX - Preferences.SideBars.Outer, cY - Preferences.SideBars.HalfHeight, cX - Preferences.SideBars.Outer + Preferences.SideBars.FullWidth, cY - Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);
            %left-lower
            Screen('DrawLine', my_window, [255 255 255], cX - Preferences.SideBars.Outer, cY + Preferences.SideBars.HalfHeight, cX - Preferences.SideBars.Outer + Preferences.SideBars.FullWidth, cY + Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);
            %right-upper
            Screen('DrawLine', my_window, [255 255 255], cX + Preferences.SideBars.Inner, cY - Preferences.SideBars.HalfHeight, cX + Preferences.SideBars.Inner + Preferences.SideBars.FullWidth, cY - Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);
            %right-lower
            Screen('DrawLine', my_window, [255 255 255], cX + Preferences.SideBars.Inner, cY + Preferences.SideBars.HalfHeight, cX + Preferences.SideBars.Inner + Preferences.SideBars.FullWidth, cY + Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);

            Screen('Flip',my_window);
            send_trigger('show_fixation', 1, Preferences);
 
			%wait for subject to start the trial
% 			JanKbWait(Preferences.Automatic);
			send_trigger(sprintf('SUBJECT START'), 1, Preferences);

            WaitSecs(Preferences.Paradigm.FixationWait.Fixed);
            send_trigger('waited_fixed', 1, Preferences);
            WaitSecs(rand(1)*Preferences.Paradigm.FixationWait.Random);
            send_trigger('waited_random', 1, Preferences);
            
            %Step 2:show expectation
            Screen('FillRect', my_window, [127 127 127],[cX-Preferences.Desired_Screen_Resolution_X/2,cY-Preferences.Desired_Screen_Resolution_Y/2,cX+Preferences.Desired_Screen_Resolution_X/2,cY+Preferences.Desired_Screen_Resolution_Y/2]);
                        %%%DRAW WHITE ALIGNMENT BARS
            %left-outer
            Screen('DrawLine', my_window, [255 255 255], cX - Preferences.SideBars.Outer, cY - Preferences.SideBars.HalfHeight, cX - Preferences.SideBars.Outer, cY + Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);
            %right-outer
            Screen('DrawLine', my_window, [255 255 255], cX + Preferences.SideBars.Outer, cY - Preferences.SideBars.HalfHeight, cX + Preferences.SideBars.Outer, cY + Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);
            %left-inner
            Screen('DrawLine', my_window, [255 255 255], cX - Preferences.SideBars.Inner, cY - Preferences.SideBars.HalfHeight, cX - Preferences.SideBars.Inner, cY + Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);
            %right-inner
            Screen('DrawLine', my_window, [255 255 255], cX + Preferences.SideBars.Inner, cY - Preferences.SideBars.HalfHeight, cX + Preferences.SideBars.Inner, cY + Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);

            %left-upper
            Screen('DrawLine', my_window, [255 255 255], cX - Preferences.SideBars.Outer, cY - Preferences.SideBars.HalfHeight, cX - Preferences.SideBars.Outer + Preferences.SideBars.FullWidth, cY - Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);
            %left-lower
            Screen('DrawLine', my_window, [255 255 255], cX - Preferences.SideBars.Outer, cY + Preferences.SideBars.HalfHeight, cX - Preferences.SideBars.Outer + Preferences.SideBars.FullWidth, cY + Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);
            %right-upper
            Screen('DrawLine', my_window, [255 255 255], cX + Preferences.SideBars.Inner, cY - Preferences.SideBars.HalfHeight, cX + Preferences.SideBars.Inner + Preferences.SideBars.FullWidth, cY - Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);
            %right-lower
            Screen('DrawLine', my_window, [255 255 255], cX + Preferences.SideBars.Inner, cY + Preferences.SideBars.HalfHeight, cX + Preferences.SideBars.Inner + Preferences.SideBars.FullWidth, cY + Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);
            %%这个地方待会找到catch trial图片以后就去掉判断%%
            if Preferences.Block(block).Trials(trial,5) ~= 0
            Screen('DrawTexture', my_window, this_Exp, [], [cX-Preferences.Target.Eccentricity.X-Preferences.Expectation.Size.X/2, cY-Preferences.Target.Eccentricity.Y-Preferences.Expectation.Size.Y/2, cX-Preferences.Target.Eccentricity.X+Preferences.Expectation.Size.X/2-1, cY-Preferences.Target.Eccentricity.Y+Preferences.Expectation.Size.Y/2-1]);
            Screen('DrawTexture', my_window,this_Exp, [], [cX-Preferences.Mask.Eccentricity.X-Preferences.Expectation.Size.X/2, cY-Preferences.Mask.Eccentricity.Y-Preferences.Expectation.Size.Y/2, cX-Preferences.Mask.Eccentricity.X+Preferences.Expectation.Size.X/2-1, cY-Preferences.Mask.Eccentricity.Y+Preferences.Expectation.Size.Y/2-1]);
            end
            Screen('Flip',my_window);
            WaitSecs(Preferences.Paradigm.FixationWait.Fixed);
            WaitSecs(rand(1)*Preferences.Paradigm.FixationWait.Random);
            
            %Step 3: expectation后的十字
            %%%DRAW GRAY BACKGROUND
            Screen('FillRect', my_window, [127 127 127],[cX-Preferences.Desired_Screen_Resolution_X/2,cY-Preferences.Desired_Screen_Resolution_Y/2,cX+Preferences.Desired_Screen_Resolution_X/2,cY+Preferences.Desired_Screen_Resolution_Y/2]);
            %%%DRAW WHITE FIXATION CROSSES
            Screen('DrawLine', my_window, [255 255 255], cX - Preferences.Mask.Eccentricity.X, cY - Preferences.Mask.Eccentricity.Y-7, cX - Preferences.Mask.Eccentricity.X, cY - Preferences.Mask.Eccentricity.Y+6,3);
            Screen('DrawLine', my_window, [255 255 255], cX - Preferences.Mask.Eccentricity.X-7, cY - Preferences.Mask.Eccentricity.Y, cX - Preferences.Mask.Eccentricity.X+6, cY - Preferences.Mask.Eccentricity.Y,3);
            Screen('DrawLine', my_window, [255 255 255], cX + Preferences.Mask.Eccentricity.X, cY - Preferences.Mask.Eccentricity.Y-7, cX + Preferences.Mask.Eccentricity.X, cY - Preferences.Mask.Eccentricity.Y+6,3);
            Screen('DrawLine', my_window, [255 255 255], cX + Preferences.Mask.Eccentricity.X-7, cY - Preferences.Mask.Eccentricity.Y, cX + Preferences.Mask.Eccentricity.X+6, cY - Preferences.Mask.Eccentricity.Y,3);

            %%%DRAW WHITE ALIGNMENT BARS
            %left-outer
            Screen('DrawLine', my_window, [255 255 255], cX - Preferences.SideBars.Outer, cY - Preferences.SideBars.HalfHeight, cX - Preferences.SideBars.Outer, cY + Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);
            %right-outer
            Screen('DrawLine', my_window, [255 255 255], cX + Preferences.SideBars.Outer, cY - Preferences.SideBars.HalfHeight, cX + Preferences.SideBars.Outer, cY + Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);
            %left-inner
            Screen('DrawLine', my_window, [255 255 255], cX - Preferences.SideBars.Inner, cY - Preferences.SideBars.HalfHeight, cX - Preferences.SideBars.Inner, cY + Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);
            %right-inner
            Screen('DrawLine', my_window, [255 255 255], cX + Preferences.SideBars.Inner, cY - Preferences.SideBars.HalfHeight, cX + Preferences.SideBars.Inner, cY + Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);

            %left-upper
            Screen('DrawLine', my_window, [255 255 255], cX - Preferences.SideBars.Outer, cY - Preferences.SideBars.HalfHeight, cX - Preferences.SideBars.Outer + Preferences.SideBars.FullWidth, cY - Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);
            %left-lower
            Screen('DrawLine', my_window, [255 255 255], cX - Preferences.SideBars.Outer, cY + Preferences.SideBars.HalfHeight, cX - Preferences.SideBars.Outer + Preferences.SideBars.FullWidth, cY + Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);
            %right-upper
            Screen('DrawLine', my_window, [255 255 255], cX + Preferences.SideBars.Inner, cY - Preferences.SideBars.HalfHeight, cX + Preferences.SideBars.Inner + Preferences.SideBars.FullWidth, cY - Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);
            %right-lower
            Screen('DrawLine', my_window, [255 255 255], cX + Preferences.SideBars.Inner, cY + Preferences.SideBars.HalfHeight, cX + Preferences.SideBars.Inner + Preferences.SideBars.FullWidth, cY + Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);

            Screen('Flip',my_window);
            send_trigger('show_fixation', 1, Preferences);
 
			%这里暂时不需要等待按键
			%JanKbWait(Preferences.Automatic);
			%send_trigger(sprintf('SUBJECT START'), 1, Preferences);
            
            WaitSecs(Preferences.Paradigm.FixationWait.Fixed);
            send_trigger('waited_fixed', 1, Preferences);
            WaitSecs(rand(1)*Preferences.Paradigm.FixationWait.Random);
            send_trigger('waited_random', 1, Preferences);
            
        %显示target
        %Step 4: Stimulus Presentation

            response_flag = false;
            for frame = 1:this_N_Frames

                %%%DRAW GRAY BACKGROUND
                Screen('FillRect', my_window, [127 127 127],[cX-Preferences.Desired_Screen_Resolution_X/2,cY-Preferences.Desired_Screen_Resolution_Y/2,cX+Preferences.Desired_Screen_Resolution_X/2,cY+Preferences.Desired_Screen_Resolution_Y/2]);

                %%%SHOW STIMULI
                Screen('DrawTexture', my_window, CardinalTextures(this_MaskPlaybackVector(frame)), [], [cX-Preferences.Mask.Eccentricity.X-Preferences.Mask.Size.X/2, cY-Preferences.Mask.Eccentricity.Y-Preferences.Mask.Size.Y/2, cX-Preferences.Mask.Eccentricity.X+Preferences.Mask.Size.X/2-1, cY-Preferences.Mask.Eccentricity.Y+Preferences.Mask.Size.Y/2-1]);
                if Preferences.Block(block).Trials(trial,5) ~= 0
                    Screen('DrawTexture', my_window, this_Target, [], [cX-Preferences.Target.Eccentricity.X-target_X/2, cY-Preferences.Target.Eccentricity.Y-target_Y/2, cX-Preferences.Target.Eccentricity.X+target_X/2-1, cY-Preferences.Target.Eccentricity.Y+target_Y/2-1],[],[], this_ContrastVector(frame));
                end

                %%%DRAW WHITE ALIGNMENT BARS
                %left-outer
                Screen('DrawLine', my_window, [255 255 255], cX - Preferences.SideBars.Outer, cY - Preferences.SideBars.HalfHeight, cX - Preferences.SideBars.Outer, cY + Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);
                %right-outer
                Screen('DrawLine', my_window, [255 255 255], cX + Preferences.SideBars.Outer, cY - Preferences.SideBars.HalfHeight, cX + Preferences.SideBars.Outer, cY + Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);
                %left-inner
                Screen('DrawLine', my_window, [255 255 255], cX - Preferences.SideBars.Inner, cY - Preferences.SideBars.HalfHeight, cX - Preferences.SideBars.Inner, cY + Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);
                %right-inner
                Screen('DrawLine', my_window, [255 255 255], cX + Preferences.SideBars.Inner, cY - Preferences.SideBars.HalfHeight, cX + Preferences.SideBars.Inner, cY + Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);

                %left-upper
                Screen('DrawLine', my_window, [255 255 255], cX - Preferences.SideBars.Outer, cY - Preferences.SideBars.HalfHeight, cX - Preferences.SideBars.Outer + Preferences.SideBars.FullWidth, cY - Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);
                %left-lower
                Screen('DrawLine', my_window, [255 255 255], cX - Preferences.SideBars.Outer, cY + Preferences.SideBars.HalfHeight, cX - Preferences.SideBars.Outer + Preferences.SideBars.FullWidth, cY + Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);
                %right-upper
                Screen('DrawLine', my_window, [255 255 255], cX + Preferences.SideBars.Inner, cY - Preferences.SideBars.HalfHeight, cX + Preferences.SideBars.Inner + Preferences.SideBars.FullWidth, cY - Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);
                %right-lower
                Screen('DrawLine', my_window, [255 255 255], cX + Preferences.SideBars.Inner, cY + Preferences.SideBars.HalfHeight, cX + Preferences.SideBars.Inner + Preferences.SideBars.FullWidth, cY + Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);
                
                %get user response
                if (Preferences.Automatic)
                    %random subject response
                    
                    if frame == this_random_frame
                        response_flag = true;
                        send_trigger(sprintf('subject responded at frame %d',frame), 1, Preferences);
                        break;
                    end
                else
                    
                    [keyIsDown, secs, keyCode, deltaSecs] = KbCheck(0);
                    if keyIsDown
                        response_flag = true;
                        send_trigger(sprintf('subject responded at frame %d',frame), 1, Preferences);
                        break;
                    end
                end
                Screen('Flip',my_window);
                send_trigger(sprintf('showing frame %d (T:%d M:%d) at contrast %1.3f',frame,this_Target,this_MaskPlaybackVector(frame),this_ContrastVector(frame)), 1, Preferences);
  
            end %frame

            Preferences.Block(block).Trials(trial,6) = frame; %store result, this is important
%             Preferences.Results.Block(block).Trial(trial).Target = this_Target; %this is redundant, but may be helpful for analysis and debugging
            
            
%show some masks to both eyes to erase afterimages
            
            
            for dummymask = 1:3
                for dummyframe = 1:Preferences.Paradigm.FramesPerMask

                    %%%DRAW GRAY BACKGROUND
                    Screen('FillRect', my_window, [127 127 127],[cX-Preferences.Desired_Screen_Resolution_X/2,cY-Preferences.Desired_Screen_Resolution_Y/2,cX+Preferences.Desired_Screen_Resolution_X/2,cY+Preferences.Desired_Screen_Resolution_Y/2])
                    %%%SHOW STIMULI
                    Screen('DrawTexture', my_window, CardinalTextures(dummymask), [], [cX-Preferences.Mask.Eccentricity.X-Preferences.Mask.Size.X/2, cY-Preferences.Mask.Eccentricity.Y-Preferences.Mask.Size.Y/2, cX-Preferences.Mask.Eccentricity.X+Preferences.Mask.Size.X/2-1, cY-Preferences.Mask.Eccentricity.Y+Preferences.Mask.Size.Y/2-1]);
                    Screen('DrawTexture', my_window, CardinalTextures(dummymask), [], [cX-Preferences.Target.Eccentricity.X-Preferences.Mask.Size.X/2, cY-Preferences.Target.Eccentricity.Y-Preferences.Mask.Size.Y/2, cX-Preferences.Target.Eccentricity.X+Preferences.Mask.Size.X/2-1, cY-Preferences.Target.Eccentricity.Y+Preferences.Mask.Size.Y/2-1]);
                        
                    %%%DRAW WHITE ALIGNMENT BARS
                    %left-outer
                    Screen('DrawLine', my_window, [255 255 255], cX - Preferences.SideBars.Outer, cY - Preferences.SideBars.HalfHeight, cX - Preferences.SideBars.Outer, cY + Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);
                    %right-outer
                    Screen('DrawLine', my_window, [255 255 255], cX + Preferences.SideBars.Outer, cY - Preferences.SideBars.HalfHeight, cX + Preferences.SideBars.Outer, cY + Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);
                    %left-inner
                    Screen('DrawLine', my_window, [255 255 255], cX - Preferences.SideBars.Inner, cY - Preferences.SideBars.HalfHeight, cX - Preferences.SideBars.Inner, cY + Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);
                    %right-inner
                    Screen('DrawLine', my_window, [255 255 255], cX + Preferences.SideBars.Inner, cY - Preferences.SideBars.HalfHeight, cX + Preferences.SideBars.Inner, cY + Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);

                    %left-upper
                    Screen('DrawLine', my_window, [255 255 255], cX - Preferences.SideBars.Outer, cY - Preferences.SideBars.HalfHeight, cX - Preferences.SideBars.Outer + Preferences.SideBars.FullWidth, cY - Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);
                    %left-lower
                    Screen('DrawLine', my_window, [255 255 255], cX - Preferences.SideBars.Outer, cY + Preferences.SideBars.HalfHeight, cX - Preferences.SideBars.Outer + Preferences.SideBars.FullWidth, cY + Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);
                    %right-upper
                    Screen('DrawLine', my_window, [255 255 255], cX + Preferences.SideBars.Inner, cY - Preferences.SideBars.HalfHeight, cX + Preferences.SideBars.Inner + Preferences.SideBars.FullWidth, cY - Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);
                    %right-lower
                    Screen('DrawLine', my_window, [255 255 255], cX + Preferences.SideBars.Inner, cY + Preferences.SideBars.HalfHeight, cX + Preferences.SideBars.Inner + Preferences.SideBars.FullWidth, cY + Preferences.SideBars.HalfHeight, Preferences.SideBars.Width);            
    
                    Screen('Flip',my_window);
                    send_trigger(sprintf('showing binocular aftermask %d',frame), 1, Preferences);
                
                end
            end
            %Target未出现之前按键太早
            if frame < (this_random_period + this_fixed_period)
                %TooEarly
                Preferences.Block(block).Trials(trial,7) = 1;
                %beep negative
                beep = [MakeBeep(800,0.2) MakeBeep(550,0.3)];
                Snd('Play',beep);
                WaitSecs(0.8);
                send_trigger('response too fast', 1, Preferences);
            else
                Preferences.Block(block).Trials(trial,7) = 0;
                send_trigger('response valid', 1, Preferences);
            end
            %CatchTrial 按键TooEarly
            if Preferences.Block(block).Trials(trial,5) == 0
                if frame < this_N_Frames
                    Preferences.Block(block).Trials(trial,7) = 1;
                    %beep negative
                    beep = [MakeBeep(800,0.2) MakeBeep(550,0.3)];
                    Snd('Play',beep);
                    WaitSecs(0.8);
                    send_trigger('response on catch', 1, Preferences);
                end
            end

            send_trigger('END_TRIAL', 1, Preferences);

    end %trial

    send_trigger('END_BLOCK', 1, Preferences);
end %block
