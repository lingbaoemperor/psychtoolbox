function Pre_Experiment(SubjectID)
%Input
if isequal(SubjectID,[])
    fprintf ('please input your name!!!');
    return
end
%parameter
Preferences.Experiment.Name = 'TestValidPicture';
Preferences.SkipPTBSyncTests=1;
Preferences.whichScreen=0;
Preferences.Desired_Screen_Resolution_X=1536; %put the desired horizontal screen resolution here.
Preferences.Desired_Screen_Resolution_Y=864; %put the desired vertical screen resolution here.
Preferences.Desired_Screen_RefreshRate=60; %put the actual screen refresh rate here. Important for various timings.
Preferences.Screen_Distance=57; %nominal value of the screen-to-subject distance. Not important for this software, as the computer doesn't know where the subject actually is.
Preferences.SubjectID=SubjectID;
Preferences.Now = now;

% Preferences.ShowTime = 1;w
%0.1s
Preferences.ShowFrames = 0.1*60;
%%Initialize Psychtoolbox screen
[my_window,Preferences,success]=initialize_ptb(Preferences);


Screen('BlendFunction', my_window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

cX = Preferences.Desired_Screen_Resolution_X/2;
cY = Preferences.Desired_Screen_Resolution_Y/2;

Screen('FillRect', my_window, [127 127 127],[cX-Preferences.Desired_Screen_Resolution_X/2,cY-Preferences.Desired_Screen_Resolution_Y/2,cX+Preferences.Desired_Screen_Resolution_X/2,cY+Preferences.Desired_Screen_Resolution_Y/2]);
ShowText = 'Loading...';
Screen('TextSize', my_window , 50);
DrawFormattedText(my_window, ShowText, 'center', cY, [0 255 255]);
Screen('Flip', my_window);

Preferences.Target.Animal.Directory = 'G:\workdoc\matlab\psychtoolbox\animal\animal\transparent_cut\';
Preferences.Target.Vehicle.Directory = 'G:\workdoc\matlab\psychtoolbox\animal\vehicle\transparent_cut\';
% Preferences.RandomSeed = sum(100*clock);
%2010的版本用getDefaultStream，暂时不知道会不会有影响
% reset(RandStream.getDefaultStream,Preferences.RandomSeed);

Preferences.Paradigm.FixationWait = 0.8;
Preferences.Paradigm.NumberOfBlocks = 1;
Preferences.Paradigm.NumberOfPerTarget = 300;
Preferences.Paradigm.NumberOfType = 4;
Preferences.Paradigm.NumberOfAllTrials = 4*300;
Preferences.Paradigm.TrialsPerBlock = 4*300/1;
Preferences.Paradigm.OneTypePerBlock = 300/1;

Preferences.Background.Size.X = 512;
Preferences.Background.Size.Y = 512;
%Target在左,Bk在右
Preferences.Target.Eccentricity.X = 300;
Preferences.Target.Eccentricity.Y = 0;
Preferences.Background.Eccentricity.X = -300;
Preferences.Background.Eccentricity.Y = 0;

[Animal_Nature,Vehicle_Manmade,AllImages,N] = load_img_dir(Preferences);

for n = 1:N
    AllImages.Animal(n).Target = Screen('MakeTexture',my_window,squeeze(AllImages.Animal(n).Target));
    AllImages.Animal(n).Bk = Screen('MakeTexture',my_window,squeeze(AllImages.Animal(n).Bk));
end
for n = 1:N
    AllImages.Vehicle(n).Target = Screen('MakeTexture',my_window,squeeze(AllImages.Vehicle(n).Target));
    AllImages.Vehicle(n).Bk = Screen('MakeTexture',my_window,squeeze(AllImages.Vehicle(n).Bk));
end

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
clear TF;
clear LOC;
%4种组合
%每种300行5列
%target_index、vehicle_index、target_num、vehicle_num、type
Type1 = [Animal_With_Nature_Sequence Animal_Nature(Animal_With_Nature_Sequence(:,1),1) Animal_Nature(Animal_With_Nature_Sequence(:,1),1) ones(Preferences.Paradigm.NumberOfPerTarget,1)];
Type2 = [Vehicle_With_Manmade_Sequence Vehicle_Manmade(Vehicle_With_Manmade_Sequence(:,1),1) Vehicle_Manmade(Vehicle_With_Manmade_Sequence(:,1),1) ones(Preferences.Paradigm.NumberOfPerTarget,1)*2];

Type3 = [Animal_With_Manmade_Sequence Animal_Nature(Animal_With_Manmade_Sequence(:,1),:) ones(Preferences.Paradigm.NumberOfPerTarget,1)*3];
Type4 = [Vehicle_With_Nature_Sequence Vehicle_Manmade(Vehicle_With_Nature_Sequence(:,1),:) ones(Preferences.Paradigm.NumberOfPerTarget,1)*4];

Base = 1;
try
    for block=1:Preferences.Paradigm.NumberOfBlocks
        tmp = [Type1(Base:Base+Preferences.Paradigm.OneTypePerBlock-1,:);...
        Type2(Base:Base+Preferences.Paradigm.OneTypePerBlock-1,:);...
        Type3(Base:Base+Preferences.Paradigm.OneTypePerBlock-1,:);...
        Type4(Base:Base+Preferences.Paradigm.OneTypePerBlock-1,:)];
        Preferences.Block(block).Trials = Shuffle(tmp,2);
        Base = Base+Preferences.Paradigm.OneTypePerBlock;
        frame_time = 0;
        for trial=1:Preferences.Paradigm.TrialsPerBlock
            target_index = Preferences.Block(block).Trials(trial,1);
            exp_index = Preferences.Block(block).Trials(trial,2);
            switch Preferences.Block(block).Trials(trial,5)
                case 1
                    Target = AllImages.Animal(target_index).Target;
                    h = AllImages.Animal(target_index).Target_Size(1);
                    w = AllImages.Animal(target_index).Target_Size(2);
                    Bk = AllImages.Animal(exp_index).Bk;
                case 2
                    Target = AllImages.Vehicle(target_index).Target;
                    h = AllImages.Vehicle(target_index).Target_Size(1);
                    w = AllImages.Vehicle(target_index).Target_Size(2);
                    Bk = AllImages.Vehicle(exp_index).Bk;
                case 3
                    Target = AllImages.Animal(target_index).Target;
                    h = AllImages.Animal(target_index).Target_Size(1);
                    w = AllImages.Animal(target_index).Target_Size(2);
                    Bk = AllImages.Vehicle(exp_index).Bk;
                case 4
                    Target = AllImages.Vehicle(target_index).Target;
                    h = AllImages.Vehicle(target_index).Target_Size(1);
                    w = AllImages.Vehicle(target_index).Target_Size(2);
                    Bk = AllImages.Animal(exp_index).Bk;
                otherwise
                    fprintf('Error!!!');
                    clear;
                    Screen('CloseAll');
                    sca
            end
            Screen('FillRect', my_window, [127 127 127],[cX-Preferences.Desired_Screen_Resolution_X/2,cY-Preferences.Desired_Screen_Resolution_Y/2,cX+Preferences.Desired_Screen_Resolution_X/2,cY+Preferences.Desired_Screen_Resolution_Y/2]);
            Screen('DrawLine', my_window, [255 255 255],cX,cY-7,cX,cY+6,3);
            Screen('DrawLine', my_window, [255 255 255],cX-7,cY,cX+6,cY,3);
            Screen('Flip',my_window);
            WaitSecs(Preferences.Paradigm.FixationWait);
            for i=1:Preferences.ShowFrames
            Screen('FillRect', my_window, [127 127 127],[cX-Preferences.Desired_Screen_Resolution_X/2,cY-Preferences.Desired_Screen_Resolution_Y/2,cX+Preferences.Desired_Screen_Resolution_X/2,cY+Preferences.Desired_Screen_Resolution_Y/2]);
            Screen('DrawTexture', my_window, Target, [], [cX-Preferences.Target.Eccentricity.X-w/2, cY-Preferences.Target.Eccentricity.Y-h/2, cX-Preferences.Target.Eccentricity.X+w/2-1, cY-Preferences.Target.Eccentricity.Y+h/2-1]);
            Screen('DrawTexture', my_window, Bk, [], [cX-Preferences.Background.Eccentricity.X-Preferences.Background.Size.X/2, cY-Preferences.Target.Eccentricity.Y-Preferences.Background.Size.Y/2, cX-Preferences.Background.Eccentricity.X+Preferences.Background.Size.X/2-1, cY-Preferences.Background.Eccentricity.Y+Preferences.Background.Size.Y/2-1]);
            Screen('Flip',my_window);
%             if i==1
%                 [VBLTimestamp,sti,FlipTimestamp,Missed] = Screen('Flip',my_window);
%             elseif i==6
%                 [VBLTimestamp1,sti,FlipTimestamp,Missed] = Screen('Flip',my_window);
%                 disp(FlipTimestamp-VBLTimestamp);
%             else
%                 Screen('Flip',my_window);
%             end
%             WaitSecs(Preferences.ShowTime);
            end
            Screen('FillRect', my_window, [127 127 127],[cX-Preferences.Desired_Screen_Resolution_X/2,cY-Preferences.Desired_Screen_Resolution_Y/2,cX+Preferences.Desired_Screen_Resolution_X/2,cY+Preferences.Desired_Screen_Resolution_Y/2]);
            Screen('DrawLine', my_window, [255 255 255],cX,cY-7,cX,cY+6,3);
            Screen('DrawLine', my_window, [255 255 255],cX-7,cY,cX+6,cY,3);
            Screen('Flip',my_window);
            while(true)
                [secs,keyCode,deltaSecs] = KbWait([],2);
                response = KbName(keyCode);
                if isequal(response,'y')
                    Preferences.Block(block).Trails(trial,6) = 1;
                    break;
                elseif isequal(response,'n')
                    Preferences.Block(block).Trails(trial,6) = 2;
                    break;
                else
                    continue;
                end
            end
        end
    end
Screen('CloseAll');
save([Preferences.SubjectID '_' datestr(Preferences.Now,'dd-mm-yyyy--HH-MM')],'Preferences');
catch exception
    clear;
    Screen('CloseAll');
    disp(exception.message);
    sca;
end
end
