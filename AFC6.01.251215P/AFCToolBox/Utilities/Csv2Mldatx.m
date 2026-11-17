%%
% 程序功能：运行后弹出文件选择对话框，用户可选择1个或多个csv文件,
% 程序根据用户选择的csv文件，自动批量进行csv格式到mldatx处理,并返回转换的csv文件数量
% 版本号：
%     V1.01.240322
%     V1.02.240506: 更改了单个文件处理错误以及VariableNamingRule警告问题
% 注1：若csv文件与当前脚本路径不一致，则程序生成.mldatx文件前回自动切换到csv文件路径、且最后回切回当前脚本路径。
% 注2：
%     如果csv文件第一行变量名称定义栏中，存在诸如中文字符、***_°等标识符变量名称时，
%       相关不符合MATLAB标识规定的变量名称被强行更改了，用户可正常使用。文件转换时警告信息如下：
%           >> 在为表创建变量名称之前，对文件中的列标题进行了修改，以使其成为有效的 MATLAB 标识符。
%           >> 原始列标题保存在 VariableDescriptions 属性中。
%           >> 将 'VariableNamingRule' 设置为 'preserve' 以使用原始列标题作为表变量名称。
%   
clc
clear all

currentFolder = pwd;  %获取并保存当前脚本的绝对路径
currentFolder = sprintf('%s\\',currentFolder);

[file,path] = uigetfile('*.csv','请选择一个或多个csv文件', ...
    'MultiSelect', 'on');

if ~isequal(file,0)
    disp(['用户已选择文件夹路径为：', path]);

    flagPath = strcmp(currentFolder, path);  %1表示m文件与脚本文件路径一致，0表示不一致
    if ~flagPath  %路径一致则不需要切换
      cd(path);  %切换到目标路径，若目标路径与脚本路径不一致，则无法在目标路径生成p文件
    end

    Num = Csv2MldatxPro(file);  % 批量处理文件转换操作

    disp(['已完成文件格式的转换操作，处理文件数量总计为：', num2str(Num)]);

    if ~flagPath
       cd(currentFolder);  %切回原来路径
    end
else
    disp('用户取消选择');
end
%%
% 根据输入的m文件绝对路径，将其生成p文件,并返回转换的文件数量
% m文件路径  fileName
% m文件数量  fileNum
function fileNum = Csv2MldatxPro(fileName)
    if ~isempty(fileName)
        switch class(fileName)  %用户选择N个c文件，若N>=2则file为1*N的元胞数组，若N=1则file为字符数组
            case 'cell'
                fileNum = size(fileName,2);
                tableList = {};
                for i = 1:fileNum
                    idx = find('.'==fileName{1,i});
                    timeTableName = fileName{1,i}(1:idx-1);
                    tmps = [timeTableName,'=csv2TimeTable(''',fileName{1,i},''');'];
                    eval(tmps);
                    tableList{end+1} = timeTableName;
                    disp(['已完成第', num2str(i),'个csv模块的转换操作：', fileName{1,i}]);
                end
                % 处理多个实验数据文件timetable
                if ~isempty(timeTableName)
                    tmps = ['signalAnalyzer(' strjoin(tableList, ',') ');'];
                    eval(tmps);
                    disp(['已完成',num2str(fileNum),'个csv文件的转换操作!']);
                end
            case 'char'
                fileNum = 1;
                idx = find('.'==fileName);
                timeTableName = fileName(1:idx-1);

                if ~isempty(timeTableName)
                    tmps =  [timeTableName,'=csv2TimeTable(''',fileName,''');'];
                    % timeTableName = csv2TimeTable(fileName);
                    eval(tmps);
                    tmps = ['signalAnalyzer(',timeTableName,');'];
                    eval(tmps);
                    disp(['已完成1个csv文件的转换操作：', fileName]);
                end
            otherwise
                fileNum = 0;
        end
    else
        fileNum = 0;
    end
end

function timeTable = csv2TimeTable(fileName)
    opts = detectImportOptions(fileName);    opts.VariableNamesLine=1; 
    opts.VariableNamingRule = 'preserve';
    sigtable = readtable(fileName,opts);
    sigName = sigtable.Properties.VariableNames;
    % tim = seconds(sigtable.time/1000);
    tim = seconds(sigtable{:,1}/1000);
    
    signals = {};
    % Loop through the variables to find numeric arrays (or adapt this to your criteria)
    len = width(sigtable) - 1;
    for i = 1:len
    % Add variable names to the list if they meet the criteria
        signals{end+1} = strjoin(['sigtable.',sigName(i+1)]);
    % signals{end+1} = strjoin(sigName(i+1));
    end
    
    if ~isempty(signals)
        commandToRun = ['timetable(tim,',strjoin(signals,','),');'];
        timeTable = eval(commandToRun);
        allVars = 1:width(timeTable);
        timeTable = renamevars(timeTable,allVars,sigName(2:len+1));
    else
        timeTable = null;
    end
end
