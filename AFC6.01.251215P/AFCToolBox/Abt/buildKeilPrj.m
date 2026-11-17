function buildState = buildKeilPrj(buildMode,prjPath,projName)
% This function start to build the specified Keil project
% Using UV4 command line to write batch file first
% Then run the batch file.
% projName is the fullpath.
% zqh 20230825
    % you can prepared enviroment:
    %    [ModelName,destPath,prjPath] = setEnvPath(2);
    %    newFileName = [ModelName, '_Keil.uvprojx'];
    %    projName = fullfile(destPath,newFileName); 

% **************************************************%
% 更改时间：2024年4月10日
% 更改内容：（1）将报错/警告弹窗与显示编译信息窗口分离，
%           保证读取不到报错信息时也能显示报错/警告弹窗
%           （2）对部分情况下读取报错信息时变量为stuct时
%           的情况进行处理，使之可以正常显示
% 更改人员：喻靖
% **************************************************%
    str = [getenv('KeilCC') '\UV4 -b -j0 ' projName ' -o buildLog.txt'];   % -j0可以隐藏Keil集成环境
    disp(str);
    prjPath = [prjPath '\MDK-ARM'];

    % 如果存在buildLog.txt文件，则将其删除
    logFile = fullfile(prjPath,'buildLog.txt');
    if(exist(logFile,'file'))
        delete(logFile);
    end
    
    batFile = fullfile(prjPath,'buildKeilProj.bat');
    fid = fopen(batFile,'w');
    fprintf(fid, '%s\n',str);
    fclose(fid);
    % check file exist
    assert(exist(batFile, 'file'), ['[AutoBuildTool-buildKeilProj]: File Missing! Bat command file ' batFile ' does not exist.']);
    % run the bat file in shell environment.
    buildState = system(batFile);
    % Display compiller information
    %logCmd = ['start /wait type ' prjPath '\buildLog.txt'];
    %system(logCmd)
    if(buildMode == 0)
        ertNumber = strfind(projName, "ert_rtw") + 7;
        logPath = strcat(projName(1:ertNumber),"buildlog.txt");
    end

    if(buildMode == 1)
        logPath = fullfile(prjPath,'\Simulink\buildlog.txt');
    end
    
    buildLog = importdata(logPath);
    if(class(buildLog) == "struct")
        buildLog = buildLog.textdata;
    end 
    switch buildState
       case 0
           return
       case 1
           mbox = msgbox('编译出现警告！关闭此弹窗显示编译信息…', 'Warning!', "warn");
       case 2
           mbox = msgbox('编译出错！关闭此弹窗显示编译信息…', 'Error!', "error");
        otherwise
           mbox = msgbox('编译出现严重错误！关闭此弹窗显示编译信息…', 'Error!', "error");
    end
    % waitfor(mbox);
    msgbox(buildLog);
end