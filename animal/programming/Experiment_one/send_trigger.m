function send_trigger(message, code, Preferences)


%nothing here yet
timestamp = datestr(now,'dd-mm-yyyy HH-MM-SS-FFF');

fprintf(Preferences.Logfile,'send_trigger: %s | %3d | %s |\n',timestamp, code, message);

