function StartEngine(srcFolder, comPort, comBaud)

% 以下行为不带终端显示的发布引擎
str = ['start ' srcFolder '\ConnectedIO_engine_noDebug.exe ' num2str(comPort) ' ' num2str(comBaud)];

% 以下行为带终端显示的引擎
% str = ['start ' srcFolder '\ConnectedIO_engine_terminal.exe ' num2str(comPort)]; 
disp(str);
batFile = 'StartEngine.bat';
fid = fopen(batFile,'w');
fprintf(fid, '%s\n',str);
fclose(fid);

assert(exist(batFile, 'file'), ['[StartEngine]: File Missing! Bat command file ' batFile ' does not exist.']);

system(batFile);
end