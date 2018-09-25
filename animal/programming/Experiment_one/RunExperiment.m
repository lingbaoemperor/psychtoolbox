function RunExperiment(SubjectID, DominantEye)
%eyetracker calibration and binocular pupil drift estimation

if ~ismember(DominantEye, [1, -1])
    fprintf ('please input -1 for left dominant-eye or 1 for right dominant-eye!!');
    return
end

%Screen('Preference', 'SkipSyncTests', 1);
%Set preferences and perform PTB initialization

% disp('STRANGE GRPAHICS!!');
%  Screen('Preference', 'ConserveVRAM', 64);
% pause
 
 
Preferences.Experiment.Name = 'CFS_Target_With_Expectation_And_GrayBk';

%special debugging parameters
Preferences.Automatic=false; %if this is true, the program will never wait for subject keypresses. DANGEROUS

%global parameters
Preferences.SkipPTBSyncTests=1;
Preferences.whichScreen=0;
Preferences.Desired_Screen_Resolution_X=1536; %put the desired horizontal screen resolution here.
Preferences.Desired_Screen_Resolution_Y=864; %put the desired vertical screen resolution here.
Preferences.Desired_Screen_RefreshRate=60; %put the actual screen refresh rate here. Important for various timings.
Preferences.Screen_Distance=57; %nominal value of the screen-to-subject distance. Not important for this software, as the computer doesn't know where the subject actually is.


%parameters for Logfile
Preferences.SubjectID=SubjectID;
Preferences.DominantEye = DominantEye; %-1 for left eye, 1 for right eye
Preferences.Now = now;
Preferences.Logfile_Name=[Preferences.Experiment.Name '_' SubjectID '_' datestr(Preferences.Now,'dd-mm-yyyy--HH-MM')];
Preferences.Logfile=open_logfile(Preferences.Logfile_Name);

%%Initialize Psychtoolbox screen
[my_window,Preferences,success]=initialize_ptb(Preferences);


%save preferences, might help with debugging
save([Preferences.Logfile_Name '_Preferences'],'Preferences');

%let's define some colors for later
red=[255 0 0];
green=[0 255 0];
blue=[0 0 255];
black=[0 0 0];
white=[255 255 255];
%by this point we either crashed or were aborted or else we are ready to go!


%%%%%%%Now actually run the experiment
try

	CFS_XPlus

%%%%%%%This only happens if there was a critical error in the experiment code
catch exception
	%oops! bailing out....
	sca;
	close_logfile(Preferences);
    save([Preferences.Logfile_Name '_Result_CRASH'],'Preferences');
	rethrow(exception)
end



%and finally shutdown

%return to the normal screen by closing all PTB screens
sca

%close the logfile
close_logfile(Preferences);
save([Preferences.Logfile_Name '_Result'],'Preferences');
fprintf('DONE - %s %s\n',Preferences.Experiment.Name,Preferences.SubjectID)
