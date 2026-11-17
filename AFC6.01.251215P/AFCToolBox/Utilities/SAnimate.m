function SAnimate(flightLogData, varargin)
    % SAnimate 动态显示x-y平面曲线和z-t高度时间曲线图
    % flightData 是飞行记录数据
    % varargin 用于处理可选参数 xCol, yCol, zCol，缺省情况为第6、7、8列分别对应x、y、z坐标值
    % 使用示例：
    %    SAnimate(flightData); % 使用默认列索引
    %    SAnimate(flightData, 'xCol', 4, 'yCol', 5, 'zCol', 6); % 指定列索引
    
    % 设置默认值
    defaultCols = [6, 7, 8];
    
    % 检查是否提供了可选参数，如果没有，则使用默认值
    cols = inputParser;
    addOptional(cols, 'xCol', defaultCols(1), @(x) isnumeric(x) && x > 0);
    addOptional(cols, 'yCol', defaultCols(2), @(x) isnumeric(x) && x > 0);
    addOptional(cols, 'zCol', defaultCols(3), @(x) isnumeric(x) && x > 0);
    parse(cols, varargin{:});
    
    xCol = cols.Results.xCol;
    yCol = cols.Results.yCol;
    zCol = cols.Results.zCol;

    % 创建一个图形窗口并分成两个子图
    subplot(1, 2, 1); % 第一个子图用于x-y平面曲线
    hAx1 = gca; % 获取当前坐标轴句柄
    hLineXY = animatedline('Color', 'b', 'Marker', '.');

    % 设置x-y平面曲线的坐标轴范围和标签
    xMin = min(flightLogData{:, xCol});  xMax = max(flightLogData{:, xCol});
    yMin = min(flightLogData{:, yCol});  yMax = max(flightLogData{:, yCol});
    xReg = (xMax - xMin) * 0.05;  yReg = (yMax - yMin) * 0.05;
    xlim(hAx1, [xMin-xReg xMax+xReg]);
    ylim(hAx1, [yMin-yReg yMax+yReg]);
    xlabel(hAx1, 'X Position');
    ylabel(hAx1, 'Y Position');
    title(hAx1, 'X-Y Plane');

    subplot(1, 2, 2); % 第二个子图用于z-t高度时间曲线
    hAx2 = gca; % 获取当前坐标轴句柄
    hLineZT = animatedline('Color', 'r', 'Marker', '.');

    tMin = min(flightLogData{:, 1});  tMax = max(flightLogData{:, 1});
    zMin = min(flightLogData{:, zCol});  zMax = max(flightLogData{:, zCol});
    tReg = (tMax - tMin) * 0.05;  zReg = (zMax - zMin) * 0.05;
    xlim(hAx2, [tMin tMax+tReg]);
    ylim(hAx2, [zMin-zReg zMax+zReg]);

    xlabel(hAx2, 'Time');
    ylabel(hAx2, 'Z Position');
    title(hAx2, 'Height-Time Curve');

    % 逐行读取数据并更新 animatedline 对象
    for i = 1:height(flightLogData)
        % 更新x-y平面曲线
        addpoints(hLineXY, flightLogData{i, xCol}, flightLogData{i, yCol});
        % 更新z-t高度时间曲线
        addpoints(hLineZT, flightLogData{i, 1}, flightLogData{i, zCol});
        
        % 更新图形的显示
        drawnow;
        
        % 根据需要暂停一小段时间以模拟动态效果
        pause(0.01);
    end
end
