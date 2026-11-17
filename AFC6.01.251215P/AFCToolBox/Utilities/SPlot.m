function data = SPlot(fileName,startTim,endTim)
% 程序名称：飞行数据分析器脚本函数
% 程序功能：将当前目录下的所有csv文件自动批量转换到mldatx，并启动信号分析器
% 版   本： V1.01.240929
% 程序设计：曾庆华  20240929
% 注：
%    撰写一个matlab脚本函数，该函数的第一个变量为csv文件名，csv文件的第一列为毫秒为单位的时间；
%      第二个变量为待分析的起始时间（单位为min），第三个变量为结束时间（单位为min）。
%      第2、3个变量可以配置，也可不配置；
%      如果第一个变量未配置时则从第一行开始，第二个变量未配置时默认最后一行。
%   
    clc

    % 检查输入参数的数量
    if nargin < 1
        error('至少需要一个输入参数（csv文件名）！');
    end
    
    % 读取CSV文件
    dataTable = readtable(fileName,'VariableNamingRule','preserve');
    
    % 如果未提供起始时间，则默认为第一行
    switch nargin
    % 未定义起始时间和结束时间，则默认为首行和最后一行
        case 1
            startTime = dataTable{1, 1};
            endTime = dataTable{end, 1};
    % 未定义结束时间，则默认为最后一行
        case 2
            startTime = startTim * 60 * 1000;  % 假设startTim单位为min
            endTime = dataTable{end, 1};
        case 3
            startTime = startTim * 60 * 1000;  % 假设startTim单位为min
            endTime = endTim * 60 * 1000;  % 假设endTim单位为min, 将其转换为ms单位
        otherwise
            error('输入参数过多！');
    end
    
    % 读入时间列变量，假设单位为ms
    timeColumn = dataTable{:, 1}; 
    
    % 找到起始和结束时间的索引
    startIndex = find(timeColumn >= startTime, 1, 'first');
    endIndex = find(timeColumn <= endTime, 1, 'last');
    
    % 检查是否有有效的时间范围
    if isempty(startIndex) || isempty(endIndex)
        error('提供的起始或结束时间不在数据范围内。');
    end
    
    % 提取指定时间范围内的数据
    data = dataTable(startIndex:endIndex, :);
end
