function SAna()
% 程序名称：飞行数据分析器脚本函数
% 程序功能：将当前目录下的所有csv文件自动批量转换到mldatx，并启动信号分析器
% 版   本： V1.01.240713
% 程序设计：曾庆华  20240713
% 注：
%     如果csv文件第一行变量名称定义栏中，存在诸如中文字符、***_°等标识符变量名称时，
%       相关不符合MATLAB标识规定的变量名称被强行更改了，用户可正常使用。文件转换时警告信息如下：
%           >> 在为表创建变量名称之前，对文件中的列标题进行了修改，以使其成为有效的 MATLAB 标识符。
%           >> 原始列标题保存在 VariableDescriptions 属性中。
%           >> 将 'VariableNamingRule' 设置为 'preserve' 以使用原始列标题作为表变量名称。
%   
    clc
    clear all
    
    files = dir('*.csv');
    fileNames = {};
    if ~isempty(files)
        % 遍历文件结构体数组，将文件名添加到元胞数组中
        for i = 1:length(files)
            fileNames{end+1} = files(i).name; % 添加文件名到元胞数组
        end
        Num = Csv2MldatxPro(fileNames);  % 批量处理文件转换操作
        disp(['已完成文件格式的转换操作，处理文件数量总计为：', num2str(Num)]);
    else
        disp('当前目录下没有csv文件！');
    end
end

%%
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
