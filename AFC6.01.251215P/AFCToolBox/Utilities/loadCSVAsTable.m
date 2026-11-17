function loadCSVAsTable(filename, varName)
    % 检查文件是否存在
    if ~isfile(filename)
        error('文件不存在: %s', filename);
    end
    
    % 读取CSV文件（自动处理列名）：保留原始列名
    dataTable = readtable(filename, 'VariableNamingRule', 'preserve');
    
    % 将整个Table赋给工作区变量
    assignin('base', varName, dataTable);
    
    % 显示成功信息
    fprintf('已成功加载CSV文件到工作区变量: %s\n', varName);
    disp(['变量大小: ' num2str(size(dataTable,1)) ' 行 × ' num2str(size(dataTable,2)) ' 列']);
end