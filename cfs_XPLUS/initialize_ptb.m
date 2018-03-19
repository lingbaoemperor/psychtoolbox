function [my_window,Preferences,success]=initialize_ptb(Preferences)

    success=1;

    %%%%%Initialize PTB%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %send_trigger('Initializing PTB...',251,Preferences);
    % command does not work until eyelink is initialized!
    if (Preferences.SkipPTBSyncTests==1)
	Screen('Preference', 'SkipSyncTests', 1);
    end

    whichScreen = Preferences.whichScreen;
    my_window = Screen(whichScreen, 'OpenWindow');


    white = [255 255 255]; % pixel value for white
    black = [0 0 0]; % pixel value for black
    gray = [128 128 128];
    green = [0 255 0];
    red = [255 0 0];
    magenta = [255 0 255];
    yellow = [255 255 0];

    [window_width, window_height]=Screen('WindowSize', my_window);                   
    [screen_width, screen_height]=Screen('DisplaySize', Preferences.whichScreen);   
    FrameRate_hz=Screen('FrameRate', my_window);
    NominalFrameRate_hz=Screen('NominalFrameRate', my_window);
    Preferences.Screen_Resolution_X=window_width; %pixel
    Preferences.Screen_Resolution_Y=window_height;
    Preferences.Screen_RefreshRate=FrameRate_hz;
  
    
    %draw 1-pixel red border just to make sure resolution is set right
    Screen(my_window,'FillRect',magenta);
    Screen(my_window,'FillRect',white,[0,0,Preferences.Desired_Screen_Resolution_X,Preferences.Desired_Screen_Resolution_Y]);
    Screen(my_window,'FillRect',black,[1,1,Preferences.Desired_Screen_Resolution_X-1,Preferences.Desired_Screen_Resolution_Y-1]);
    
    
    if (Preferences.Desired_Screen_Resolution_X~=Preferences.Screen_Resolution_X)
        success=0;
        disp('resolution mismatch(x)');
        Preferences
    end
    if (Preferences.Desired_Screen_Resolution_Y~=Preferences.Screen_Resolution_Y)
        success=0;
        disp('resolution mismatch(y)');
        Preferences
    end
    if (Preferences.Desired_Screen_RefreshRate~=Preferences.Screen_RefreshRate)
        success=0;
        disp('refresh mismatch');
        Preferences
    end
    

	%Check if the detected values match those requested by the user
	errors_found=false;
    

	DrawFormattedText(my_window, 'PTB initialized and using the following values:', 'center', 50, white, black);

	if (FrameRate_hz==Preferences.Desired_Screen_RefreshRate)
		signal=white;
	else
		signal=red;
		errors_found=true;
	end
	DrawFormattedText(my_window,sprintf('Detected FrameRate:         %3.1fHz',FrameRate_hz), 'center', Preferences.Screen_Resolution_Y/2-75, signal, black);
	DrawFormattedText(my_window,sprintf('Nominal/reported FrameRate: %3.1fHz',NominalFrameRate_hz), 'center', Preferences.Screen_Resolution_Y/2-50, signal, black);

	if (Preferences.Desired_Screen_Resolution_X==Preferences.Screen_Resolution_X) && (Preferences.Desired_Screen_Resolution_Y==Preferences.Screen_Resolution_Y)
		signal=white;
	else
		signal=red;
		errors_found=true;
	end
	DrawFormattedText(my_window,sprintf('Window Size: %dx%d',window_width,window_height), 'center', Preferences.Screen_Resolution_Y/2-25, signal, black);
	DrawFormattedText(my_window,sprintf('Screen Size: %dx%d',screen_width,screen_height), 'center', Preferences.Screen_Resolution_Y/2, signal, black);

	if (~errors_found)
		signal=green;
	else
		signal=red;
	end

	DrawFormattedText(my_window,sprintf('User-requested: %dx%d@%dHz at %dcm',Preferences.Desired_Screen_Resolution_X,Preferences.Desired_Screen_Resolution_Y,Preferences.Desired_Screen_RefreshRate, Preferences.Screen_Distance), 'center', Preferences.Screen_Resolution_Y/2+50, signal, black);
                                   

    % Hide mousepointer
    HideCursor;

    DrawFormattedText(my_window,'Press key to continue', 'center', Preferences.Screen_Resolution_Y/2+100, [255 255 0], black);
    Screen(my_window,'Flip');
    KbWait([],2);

    Screen(my_window,'FillRect',black);
    %send_trigger('Initialized PTB.',252,Preferences);
   % command does not work until eyelink is initialized!
