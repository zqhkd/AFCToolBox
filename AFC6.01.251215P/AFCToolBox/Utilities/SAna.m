function flightData = SAna(CsvOfCh5,remStepCounter,CsvOfXyz)
% 程序名称：飞行数据分析器脚本函数
% 程序功能：
%    (1) 将当前目录下的所有csv文件自动批量转换到mldatx，并启动信号分析器
%    (2) 如果给定了遥控初始化开关CH5所在文件CsvOfCh5时，程序会自动查找最后一段CH5值大于1000的时间段，并仅对这段信号进行分析；
%    (3) 如果在CsvOfCh5后还定义了参数remStepCounter，则在指定有效CH5时间段前后增加remStepCounter个采样时间；
%        当带remStepCounter时，该值为默认值100；
%    (4) 如果不带任何参数，则默认对全部采集数据进行信号分析。
%
% 版   本： 
%       V1.01.240713：
%          实现了全采集时段的信号分析
%       V1.02.240925: 
%          (1)将信号分析器中的时间单位改为秒；
%          (2)如果配置了一个CsvOfCh5的字符串，则表示要仅取包含遥控器CH5通道的csv文件从352跳变为1695时间段的数据
%          (3)只截取从CH5遥控开关最后有效时段从地面初始复位的前100个采集步长开始至其切断时刻后100个采集步长的数据进行信号分析；
%             如果配置了remStepCounter, 则表示CH5遥控开关最后有效时段的前后remStepCounter个采集步长。
%             即没有配置remStepCounter时，缺省为100。
% 示例：
%      flightData = SAna('D2',100,'D3');           % 早期单机飞控地面站版本
%      flightData = SAna('D0_2',100,'D0_3');       % 多机飞控地面站版本
% 程序设计：曾庆华
% 日   期： 20240925

%%  注：
%   如果csv文件第一行变量名称定义栏中，存在诸如中文字符、***_°等标识符变量名称时，
%     相关不符合MATLAB标识规定的变量名称被强行更改了，用户可正常使用。文件转换时警告信息如下：
%       >> 在为表创建变量名称之前，对文件中的列标题进行了修改，以使其成为有效的 MATLAB 标识符。
%       >> 原始列标题保存在 VariableDescriptions 属性中。
%       >> 将 'VariableNamingRule' 设置为 'preserve' 以使用原始列标题作为表变量名称。
%%    
    clc
    if nargin == 0
        CsvOfCh5 = '';
    elseif nargin == 1
        remStepCounter = 100;   % 在给定条件的前后预留一定时间间隔的采样步数, 及CH5所在通道采样
    end
    files = dir('*.csv');
    filesName = {};
    if ~isempty(files)
        % 遍历文件结构体数组，将文件名添加到元胞数组中
        for i = 1:length(files)
            filesName{end+1} = files(i).name; % 添加文件名到元胞数组
        end
        if isempty(CsvOfCh5)
            Num = Csv2MldatxPro(filesName);  % 批量处理文件转换操作
            if nargin == 3
                flightData = SPlot(CsvOfXyz);
            else
                flightData = 0;
            end
        else
            [Num,startMinute,endMinute] = Csv2MldatxGivenZones(filesName,CsvOfCh5,remStepCounter);  % 处理给定时间段的文件转换操作
            if nargin == 3
                flightData = SPlot(CsvOfXyz,startMinute,endMinute);
            else
                flightData = 0;
            end
        end
        disp(['已完成文件格式的转换操作，处理文件数量总计为：', num2str(Num)]);
    else
        disp('当前目录下没有csv文件！');
    end
end

%%
% 不带给定时间段切片要求时，显示全部数据
% m文件路径  fileName, m文件数量  fileNum
function fileNum = Csv2MldatxPro(filesName)
    if ~isempty(filesName)
        switch class(filesName)  %用户选择N个c文件，若N>=2则file为1*N的元胞数组，若N=1则file为字符数组
            case 'cell'
                fileNum = size(filesName,2);
                tableList = {};
                for i = 1:fileNum
                    idx = find('.'==filesName{1,i});
                    timeTableName = filesName{1,i}(1:idx-1);
                    tmps =  [timeTableName,'=csv2TimeTable(''',filesName{1,i},''');'];
                    eval(tmps);
                    tableList{end+1} = timeTableName;
                    disp(['已完成第', num2str(i),'个csv模块的转换操作：', filesName{1,i}]);
                end
                % 处理多个实验数据文件timetable
                if ~isempty(timeTableName)
                    tmps = ['signalAnalyzer(' strjoin(tableList, ',') ');'];
                    eval(tmps);
                    disp(['已完成',num2str(fileNum),'个csv文件的转换操作!']);
                end
            case 'char'
                fileNum = 1;
                idx = find('.'==filesName);
                timeTableName = filesName(1:idx-1);

                if ~isempty(timeTableName)
                    tmps =  [timeTableName,'=csv2TimeTable(''',filesName,''');'];
                    % timeTableName = csv2TimeTable(fileName);
                    eval(tmps);
                    tmps = ['signalAnalyzer(',timeTableName,');'];
                    eval(tmps);
                    disp(['已完成1个csv文件的转换操作：', filesName]);
                end
            otherwise
                fileNum = 0;
        end
    else
        fileNum = 0;
    end
end

% 查找时间序列值突然减小情况
function n = findAbonormTime(timeColumn)
    % 初始化n为0
    n = 0;
    % 遍历时间序列，找出需要删除的行数
    for i = 2:length(timeColumn)
        if timeColumn(i) < timeColumn(i-1) % 如果当前行的时间小于前一行的时间
            n = i-1; % 记录需要删除的行数
            break; % 跳出循环
        end
    end
    n = n + 1;
end

% 不带时间区间的Csv2MldatxPro函数的单个文件转换模块
function timeTable = csv2TimeTable(fileName)
    opts = detectImportOptions(fileName);    opts.VariableNamesLine=1; 
    opts.VariableNamingRule = 'preserve';
    data = readtable(fileName,opts);
    sigName = data.Properties.VariableNames;
%    tim = seconds(sigtable{:,1}/1000);
    tim = seconds(data{:,1}/1000);
    
% 删除时间序列突然减小的数据点，V2.01后地面站软件出现可能部分数据为前面飞控发送的残留数据，时标一般较大
    n = findAbonormTime(tim);    data = data(n:end,:);

    signals = {};
    % Loop through the variables to find numeric arrays (or adapt this to your criteria)
    len = width(data);
    for i = 2:len
    % Add variable names to the list if they meet the criteria
        signals{end+1} = strjoin(['data.',sigName(i)]);
    % signals{end+1} = strjoin(sigName(i+1));
    end
    
    if ~isempty(signals)
        commandToRun = ['timetable(tim,',strjoin(signals,','),');'];
        timeTable = eval(commandToRun);
        allVars = 1:width(timeTable);
        timeTable = renamevars(timeTable,allVars,sigName(2:len));
    else
        timeTable = null;
    end
end

% 给定时间段切片要求时，显示指定区域的数据
function [fileNum,startMinute,endMinute] = Csv2MldatxGivenZones(filesName,CsvOfCh5,remStepCounter)
    % 首先根据CsvOfCh5文件中Ch5通道给定条件查找最后一段时间段
    [startTick,endTick,sampleInterval] = findZones(CsvOfCh5,remStepCounter);  % 在CsvOfCh5给定文件中查找起始时间点

    startMinute = startTick/60000.;  endMinute = endTick/60000.;  % 将ms单位转换为分钟单位
    
    fileNum = size(filesName,2);
    tableList = {};

    for i = 1:fileNum
        idx = find('.'==filesName{1,i});
        timeTableName = filesName{1,i}(1:idx-1);
        tmps =  [timeTableName,'=csv2TimeTableByZones(''',filesName{1,i},''',',num2str(startTick/1000),',',num2str(endTick/1000),',',num2str(sampleInterval/1000),');'];
        eval(tmps);
        tableList{end+1} = timeTableName;
        disp(['已完成第', num2str(i),'个csv模块的转换操作：', filesName{1,i}]);
    end

    % 处理多个实验数据文件timetable
    if ~isempty(tableList)
        tmps = ['signalAnalyzer(' strjoin(tableList, ',') ');'];
        eval(tmps);
    end    

end

% 查找通道5所在文件中CH5的值由低变高所在起始行列（一般有三个值0，352，1695.仅取1695所在区间的起始行数）
function [startTick,endTick,sampleInterval] = findZones(CsvOfCh5,remStepCounter)
  try
    opts = detectImportOptions(CsvOfCh5);    opts.VariableNamesLine=1; 
    opts.VariableNamingRule = 'preserve';
    data = readtable(CsvOfCh5,opts);
    % 获取表头
    headers = data.Properties.VariableNames;
    % 查找CH5列的位置，不区分大小写
    ch5Column = find(strcmpi(headers, 'CH5'));
    if isempty(ch5Column)
        error('%s文件中没有找到名为CH5的列。',CsvOfCh5);
    end
    % 获取所有CH5列的数据
    startTick = 0; endTick = 0;
    ch5Data = data{:, ch5Column};
    sampleInterval = median(diff(data{:,1}));
    len = length(ch5Data);
    % 查找最后一段出现大于1000的CH5数据段的起始行和结束行
    for i = len:-1:1
        if ch5Data(i) > 1500
           % 如果找到一个大于1000的值，则检查是否是结束行
           if endTick == 0
               endTick = data{i,1} + min(remStepCounter,len - i - 1)*sampleInterval;
           end
        end
        % 找到>1000的最后时刻后，就要继续向前查找
        if (endTick > 0) && (ch5Data(i) < 1500)
            startTick = data{i,1} - min(remStepCounter, i - 1)*sampleInterval;
            break;
        end
    end
    if (startTick==0) || (endTick==0)
        error('%s文件中没有找到最后一段出现大于1000的CH5数据。',CsvOfCh5);
    end    
  catch
      error('读取%s文件时发生错误！',CsvOfCh5);
  end
end

% 带时间区间的Csv2MldatxGivenZones函数的单个文件转换模块:
%     该函数首先根据给定起始时间，按照给定采样率对原始数据进行插值重采样，并将其数据保存到一个时间表变量中

% 目前还存在问题：采集频率不一样，起始行是不一样的。需要提取时间来处理........
function timeTable = csv2TimeTableByZones(fileName,startTick,endTick,sampleInterval)
    opts = detectImportOptions(fileName);    opts.VariableNamesLine=1; 
    opts.VariableNamingRule = 'preserve';
    data = readtable(fileName,opts);

    % 删除时间序列突然减小的数据点，V2.01后地面站软件出现可能部分数据为前面飞控发送的残留数据，时标一般较大
    n = findAbonormTime(data{:,1});    data = data(n:end,:);

    % 以sampleInterval为间隔生成统一时间戳序列
    tim = startTick:sampleInterval:endTick;
    uniTimeStamps = seconds(tim');  % 将ms转换成秒的时间序列

    % 手动添加标题栏
    sigName = data.Properties.VariableNames(2:end);
    
    timeStamps = seconds(data{:,1}/1000);
    signalData = data{:,2:end};

    signals = {};
    len = width(signalData);
    for j = 1:len
%       reSampleData(:,j) = interp1(timeStamps, signalData(:,j), uniTimeStamps, 'linear', 'extrap');
       reSampleData(:,j) = interp1(timeStamps, signalData(:,j), uniTimeStamps, 'linear');

       signals{j} = ['reSampleData(:,',num2str(j),')'];
     % resampleTable.(signalData.Properties.VariableNames(j)) = resampledData;
    end
      
    if ~isempty(signals)
        commandToRun = ['timetable(uniTimeStamps,',strjoin(signals,','),');'];
        timeTable = eval(commandToRun);

        allVars = 1:width(timeTable);
        timeTable = renamevars(timeTable,allVars,sigName(1:len));
    else
        timeTable = null;
    end
end
