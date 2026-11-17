function loadCSVToWorkspace(filename)
    % 检查文件是否存在
    if ~isfile(filename)
        error('文件不存在: %s', filename);
    end
    
    % 读取CSV文件并保留原始列名
    dataTable = readtable(filename, 'VariableNamingRule', 'preserve');
    
    % 获取变量名
    variableNames = dataTable.Properties.VariableNames;
    
    % 将每个变量分配到工作区
    for k = 1:length(variableNames)
        originalName = variableNames{k};
        
        % 预处理变量名使其有效
        varName = makeValidVarName(originalName);
        
        % 分配变量到工作区
        assignin('base', varName, dataTable.(originalName));
        fprintf('已加载: %s -> %s\n', originalName, varName);
    end
end

function validName = makeValidVarName(name)
    % 替换常见无效字符为下划线
    validName = regexprep(name, '[\(\)\{\}\.\-\s]', '_');
    
    % 确保不以数字开头
    if ~isempty(regexp(validName, '^\d', 'once'))
        validName = ['x' validName];
    end
    
    % 确保名称是唯一的（避免重复替换导致的冲突）
    validName = matlab.lang.makeValidName(validName);
    
    % 可选: 缩短过长的变量名
    if length(validName) > 63
        validName = validName(1:63);
    end
end