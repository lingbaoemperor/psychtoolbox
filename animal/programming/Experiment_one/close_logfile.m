function close_logfile(Preferences)

timestamp = datestr(now,'dd-mm-yyyy HH-MM-SS-FFF');

fprintf(Preferences.Logfile,'\n%s | logfile closed.\n',timestamp);
fclose(Preferences.Logfile);

