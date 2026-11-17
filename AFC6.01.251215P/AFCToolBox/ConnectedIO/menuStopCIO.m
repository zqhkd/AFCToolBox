function menuStopCIO()

set_param(gcs, 'SimulationCommand', 'stop')
str = 'TASKKILL /F /IM ConnectedIO_engine_noDebug.exe /T'; 
disp(str);
batFile = 'StopEngine.bat';
fid = fopen(batFile,'w');
fprintf(fid, '%s\n',str);
fclose(fid);

assert(exist(batFile, 'file'), ['[StoptEngine]: File Missing! Bat command file ' batFile ' does not exist.']);

system(batFile);
end