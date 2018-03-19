function logfile = open_logfile(filename)

logfile=fopen([filename '.log'],'w');


timestamp = datestr(now,'dd-mm-yyyy HH-MM-SS-FFF');


fprintf(logfile,'%s: Logfile %s opened.\n',timestamp,filename);

