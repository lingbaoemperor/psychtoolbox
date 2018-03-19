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

Preferences.Target.X.image =    imread('X_Target_Gray127.png');
Preferences.Target.Plus.image = imread('PLUS_Target_Gray127.png');
Preferences.Mask.Cardinal.Directory = 'Masks_Cardinal/';
Preferences.Mask.Oblique.Directory = 'Masks_Oblique/';


Preferences.RandomSeed = sum(100*clock);
%2012包括以后的版本用getGlobalStream
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

Preferences.Paradigm.FixationWait.Fixed = 0.8;
Preferences.Paradigm.FixationWait.Random = 0.2;

Preferences.Paradigm.NumberOfBlocks = 2;
Preferences.Paradigm.TargetA_TrialsPerBlock = 20;
Preferences.Paradigm.TargetB_TrialsPerBlock = 20;
Preferences.Paradigm.Catch_TrialsPerBlock = 10;

Preferences.Paradigm.RefreshRate = 60; %assume this many Hz screen refresh
Preferences.Paradigm.FramesPerMask = [10];  %one mask should be visible for this many frames. At 120hz, 20 Frames correspond to 6Hz.
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
    [AllMasks(1).the_masks, AllMasks(1).N]=load_image_dir(Preferences.Mask.Cardinal.Directory,'');
    [AllMasks(2).the_masks, AllMasks(2).N]=load_image_dir(Preferences.Mask.Oblique.Directory,'');
    %%%%%%%  save all "MakeTexture" in advance
    send_trigger(sprintf('loaded mask images.'), 1, Preferences);

Preferences.Mask.Size.X=size(AllMasks(1).the_masks,2);
Preferences.Mask.Size.Y=size(AllMasks(1).the_masks,1);

%convert masks to textures
for n = 1:AllMasks(1).N
    CardinalTextures(n) = Screen('MakeTexture',my_window,squeeze(AllMasks(1).the_masks(:,:,:,n)));
end    
for n = 1:AllMasks(2).N
    ObliqueTextures(n) = Screen('MakeTexture',my_window,squeeze(AllMasks(2).the_masks(:,:,:,n)));
end    
%convert targets to textures
Preferences.Target.X.texture = Screen('MakeTexture',my_window,Preferences.Target.X.image);
Preferences.Target.Plus.texture = Screen('MakeTexture',my_window,Preferences.Target.Plus.image);

send_trigger(sprintf('created textures.'), 1, Preferences);


%temporary override: make sure images are shown in appropriate size. X:Y = 1:1.25
Preferences.Target.Size.X=288;
Preferences.Target.Size.Y=360;



for block = 1:Preferences.Paradigm.NumberOfBlocks

    send_trigger(sprintf('START_BLOCK: %d',block), 1, Preferences);
    
    %compute mask and duration randomization for this entire block
    
    %this vector contains the target types. This is the base of the experiment; each of these
    %target types should be run a given number of times for each masking condition.
    %size 50 0 1 2
	Ordered_Target_Type_Sequence = [ones(1,Preferences.Paradigm.TargetA_TrialsPerBlock)*1 ones(1,Preferences.Paradigm.TargetB_TrialsPerBlock)*2 ones(1,Preferences.Paradigm.Catch_TrialsPerBlock)*0];
    %size 100 1 2
	Ordered_Mask_Type_Sequence = [ones(1,length(Ordered_Target_Type_Sequence))*1 ones(1,length(Ordered_Target_Type_Sequence))*2];
    %size 100 0 1 2
	Ordered_Target_Type_Sequence = [Ordered_Target_Type_Sequence Ordered_Target_Type_Sequence];
	
	%now we create a vector-structure, containing the sequence in which each mask is shown.
	%we also create a fourth vector-structure, which contains a list of timings for each mask. The timings are created according to 
	%the respective condition, as stored in the above condition sequence.
	%from these two vectors, we then create the final "playback" vector, which is a list of mask IDs to be shown at each frame of this trial.

	send_trigger('Creating mask playback vectors...',1,Preferences);

    %size 30 1-->30
	MaskVector = 1:AllMasks(1).N;
    %size 30 1---30
	this_shuffle = Shuffle(MaskVector);
	
    %1:100
	for k = 1:length(Ordered_Target_Type_Sequence)
	
        this_mask_vector = Shuffle(MaskVector);
        while length(this_mask_vector)<Preferences.Paradigm.NumberOfMasks
        
            this_shuffle = Shuffle(MaskVector) %create a randomized sequence of all masks
            while this_shuffle(1)==this_mask_vector(end)
                this_shuffle = Shuffle(MaskVector);
            end
            
            this_mask_vector = [this_mask_vector this_shuffle];
            
        end
        %this_mask_vector >60 1---30
        
        this_playback_vector =[];
        for frame = 1:length(this_mask_vector)
            
            this_playback_vector = [this_playback_vector ones(1,Preferences.Paradigm.FramesPerMask)*this_mask_vector(frame)];
            
        end
        Ordered_Masking_Sequence(k).MaskPlaybackVector =  this_playback_vector(1:Preferences.Paradigm.NumberOfMaskFrames); %random selection of masks 
	
	end

	%okay, now we have an ordered playback sequence for all the trials. The only thing missing now is the randomization of the trial order,
	%and the selection of the actual targets from their respective target classes.
	%first, randomize trial order
	
	Preferences.Block(block).This_Block_Trial_Permutation = randperm(length(Ordered_Target_Type_Sequence));
    %目标显示顺序（100次）0 1 2
	Preferences.Block(block).Target_Type_Sequence = Ordered_Target_Type_Sequence(Preferences.Block(block).This_Block_Trial_Permutation);
    %mask类型顺序(100次)1 2
	Preferences.Block(block).Mask_Type_Sequence = Ordered_Mask_Type_Sequence(Preferences.Block(block).This_Block_Trial_Permutation);
    %mask显示顺序，100次，每次都是一个960的数组，一次mask又960帧，每帧显示1--30类型的mask
	Preferences.Block(block).Masking_Sequence = Ordered_Masking_Sequence(Preferences.Block(block).This_Block_Trial_Permutation);

	send_trigger('Trial sequence prepared!',1,Preferences);
	

    %%%% give 30s break between blocks!S
    if block ~= 1
        
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
    
    done = false;
    KbWait([],1);
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
   
    Preferences.Results.Block(block).Mask.Eccentricity.X = Preferences.Mask.Eccentricity.X ;
    Preferences.Results.Block(block).Mask.Eccentricity.Y = Preferences.Mask.Eccentricity.Y ;
  
    %100个trial
    for trial = 1:length(Preferences.Block(block).Target_Type_Sequence)
        
        send_trigger(sprintf('START_TRIAL: %d of block %d',trial,block), 1, Preferences);

        %randomize the timing of this trial
        this_random_period = randi(ceil(Preferences.Paradigm.PreStimulusMasks.Random*Preferences.Paradigm.RefreshRate));
        this_fixed_period = ceil(Preferences.Paradigm.PreStimulusMasks.Fixed*Preferences.Paradigm.RefreshRate);
        this_N_Frames = length(Preferences.Block(block).Masking_Sequence(trial).MaskPlaybackVector);
        this_MaskPlaybackVector = Preferences.Block(block).Masking_Sequence(trial).MaskPlaybackVector;
		
		this_Target = 0;
		if Preferences.Block(block).Target_Type_Sequence(trial) == 1;
            this_Target = Preferences.Target.X.texture;
        elseif Preferences.Block(block).Target_Type_Sequence(trial) == 2;
            this_Target = Preferences.Target.Plus.texture;
        end
   
        
        this_random_frame = randi(this_N_Frames); %this is only for the automatic mode.
        
        
        %build contrast vector for this trial(size <= 960)
        this_ContrastVector = [zeros(1,this_fixed_period) zeros(1,this_random_period) Preferences.Paradigm.ContrastRamp]; %start with zero, then add the ramp to 50%
		this_ContrastVector = [this_ContrastVector ones(1,this_N_Frames - length(this_ContrastVector))];
		
         if Preferences.Block(block).Target_Type_Sequence(trial) == 0 %if this is a catch trial...
            this_ContrastVector = this_ContrastVector * 0; %...then set all contrasts to zero and...
            Preferences.Results.Block(block).Trial(trial).CatchTrial = 1; %...remember that this WAS a catch trial
        else
            Preferences.Results.Block(block).Trial(trial).CatchTrial = 0; %...remember this was NOT a catch trial
        end    

        Preferences.Results.Block(block).Trial(trial).ContrastVector = this_ContrastVector; %save for later.

        save GARBAGE Preferences
        
        %%%%PARADIGM
        %Step 1: show fixation for randomized interval


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
			JanKbWait(Preferences.Automatic);
			send_trigger(sprintf('SUBJECT START'), 1, Preferences);

            WaitSecs(Preferences.Paradigm.FixationWait.Fixed);
            send_trigger('waited_fixed', 1, Preferences);
            WaitSecs(rand(1)*Preferences.Paradigm.FixationWait.Random);
            send_trigger('waited_random', 1, Preferences);


        %Step 2: Stimulus Presentation

            response_flag = false;
            for frame = 1:this_N_Frames

                %%%DRAW GRAY BACKGROUND
                Screen('FillRect', my_window, [127 127 127],[cX-Preferences.Desired_Screen_Resolution_X/2,cY-Preferences.Desired_Screen_Resolution_Y/2,cX+Preferences.Desired_Screen_Resolution_X/2,cY+Preferences.Desired_Screen_Resolution_Y/2]);

                %%%SHOW STIMULI
                if Preferences.Block(block).Mask_Type_Sequence(trial) == 1
                    Screen('DrawTexture', my_window, CardinalTextures(this_MaskPlaybackVector(frame)), [], [cX-Preferences.Mask.Eccentricity.X-Preferences.Mask.Size.X/2, cY-Preferences.Mask.Eccentricity.Y-Preferences.Mask.Size.Y/2, cX-Preferences.Mask.Eccentricity.X+Preferences.Mask.Size.X/2-1, cY-Preferences.Mask.Eccentricity.Y+Preferences.Mask.Size.Y/2-1]);
                else
                    Screen('DrawTexture', my_window, ObliqueTextures(this_MaskPlaybackVector(frame)), [], [cX-Preferences.Mask.Eccentricity.X-Preferences.Mask.Size.X/2, cY-Preferences.Mask.Eccentricity.Y-Preferences.Mask.Size.Y/2, cX-Preferences.Mask.Eccentricity.X+Preferences.Mask.Size.X/2-1, cY-Preferences.Mask.Eccentricity.Y+Preferences.Mask.Size.Y/2-1]);
                end
                if Preferences.Results.Block(block).Trial(trial).CatchTrial == 0
                    Screen('DrawTexture', my_window, this_Target, [], [cX-Preferences.Target.Eccentricity.X-Preferences.Target.Size.X/2, cY-Preferences.Target.Eccentricity.Y-Preferences.Target.Size.Y/2, cX-Preferences.Target.Eccentricity.X+Preferences.Target.Size.X/2-1, cY-Preferences.Target.Eccentricity.Y+Preferences.Target.Size.Y/2-1],[],[], this_ContrastVector(frame));
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
                    
                    [keyIsDown, secs, keyCode, deltaSecs] = KbCheck();
                    if keyIsDown
                        response_flag = true;
                        send_trigger(sprintf('subject responded at frame %d',frame), 1, Preferences);
                        break;
                    end
                end
                Screen('Flip',my_window);
                send_trigger(sprintf('showing frame %d (T:%d M:%d) at contrast %1.3f',frame,this_Target,this_MaskPlaybackVector(frame),this_ContrastVector(frame)), 1, Preferences);
  
            end %frame

            Preferences.Results.Block(block).Trial(trial).Response_Frame = frame; %store result, this is important
            Preferences.Results.Block(block).Trial(trial).Target = this_Target; %this is redundant, but may be helpful for analysis and debugging
            
            
%show some masks to both eyes to erase afterimages
            
            
            for dummymask = 1:3
                for dummyframe = 1:Preferences.Paradigm.FramesPerMask

                    %%%DRAW GRAY BACKGROUND
                    Screen('FillRect', my_window, [127 127 127],[cX-Preferences.Desired_Screen_Resolution_X/2,cY-Preferences.Desired_Screen_Resolution_Y/2,cX+Preferences.Desired_Screen_Resolution_X/2,cY+Preferences.Desired_Screen_Resolution_Y/2])
                    %%%SHOW STIMULI
                    if Preferences.Block(block).Mask_Type_Sequence == 1
                        Screen('DrawTexture', my_window, CardinalTextures(dummymask), [], [cX-Preferences.Mask.Eccentricity.X-Preferences.Mask.Size.X/2, cY-Preferences.Mask.Eccentricity.Y-Preferences.Mask.Size.Y/2, cX-Preferences.Mask.Eccentricity.X+Preferences.Mask.Size.X/2-1, cY-Preferences.Mask.Eccentricity.Y+Preferences.Mask.Size.Y/2-1]);
                        Screen('DrawTexture', my_window, CardinalTextures(dummymask), [], [cX-Preferences.Target.Eccentricity.X-Preferences.Mask.Size.X/2, cY-Preferences.Target.Eccentricity.Y-Preferences.Mask.Size.Y/2, cX-Preferences.Target.Eccentricity.X+Preferences.Mask.Size.X/2-1, cY-Preferences.Target.Eccentricity.Y+Preferences.Mask.Size.Y/2-1]);
                    else
                        Screen('DrawTexture', my_window, ObliqueTextures(dummymask), [], [cX-Preferences.Mask.Eccentricity.X-Preferences.Mask.Size.X/2, cY-Preferences.Mask.Eccentricity.Y-Preferences.Mask.Size.Y/2, cX-Preferences.Mask.Eccentricity.X+Preferences.Mask.Size.X/2-1, cY-Preferences.Mask.Eccentricity.Y+Preferences.Mask.Size.Y/2-1]);
                        Screen('DrawTexture', my_window, ObliqueTextures(dummymask), [], [cX-Preferences.Target.Eccentricity.X-Preferences.Mask.Size.X/2, cY-Preferences.Target.Eccentricity.Y-Preferences.Mask.Size.Y/2, cX-Preferences.Target.Eccentricity.X+Preferences.Mask.Size.X/2-1, cY-Preferences.Target.Eccentricity.Y+Preferences.Mask.Size.Y/2-1]);
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
    
                    Screen('Flip',my_window);
                    send_trigger(sprintf('showing binocular aftermask %d',frame), 1, Preferences);
                
                end
            end
            
            if frame < (this_random_period + this_fixed_period)
                Preferences.Results.Block(block).Trial(trial).TooEarly = 1;
                %beep negative
                beep = [MakeBeep(800,0.2) MakeBeep(550,0.3)];
                Snd('Play',beep);
                WaitSecs(0.8);
                send_trigger('response too fast', 1, Preferences);
            else
                Preferences.Results.Block(block).Trial(trial).TooEarly = 0;
                send_trigger('response valid', 1, Preferences);
            end

            if Preferences.Results.Block(block).Trial(trial).CatchTrial == 1
                if frame < this_N_Frames
                    Preferences.Results.Block(block).Trial(trial).TooEarly = 1;
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
