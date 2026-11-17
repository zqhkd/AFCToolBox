function SAni(flightLogData, varargin)
    % SAni 动态显示x-y平面曲线、z-t高度时间曲线图和3D动画曲线图
    % 版本信息：
    %     V1.01:   SAnimate->动态显示x-y平面曲线和z-t高度时间曲线图
    %     V1.02:   拆解为SAni2D.m完成SAnimate功能、SAni3D.m完成动态显示x-y-z三维实时动画图
    %     V1.03:   将2D和3D显示合并在一起
    % flightData 是飞行记录数据
    % varargin 用于处理可选参数 xCol, yCol, zCol，缺省情况为第6、7、8列分别对应x、y、z坐标值
    % 使用示例：
    %    SAni(flightData); % 使用默认列索引
    %    SAni(flightData, 'xCol', 4, 'yCol', 5, 'zCol', 6); % 指定列索引
    
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


     % 由于高度值是用北东地坐标系来定义的，高度值为负，先对其处理成正值
    curHeight(:) = -flightLogData{:, zCol};

    % 创建一个新的图形窗口
    tiledlayout(3,2);  % 创建3行2列的图块

    % 创建一个图形窗口并分成两个子图
    hAx1 = nexttile; % 第一个子图用于x-y平面曲线。获取当前坐标轴句柄
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

    hAx2 = nexttile; % 第二个子图用于z-t高度时间曲线
    hLineZT = animatedline('Color', 'r', 'Marker', '.');

    tMin = min(flightLogData{:, 1});  tMax = max(flightLogData{:, 1});
    zMin = min(curHeight(:));  zMax = max(curHeight(:));
    tReg = (tMax - tMin) * 0.05;  zReg = (zMax - zMin) * 0.05;
    xlim(hAx2, [tMin tMax+tReg]);
    ylim(hAx2, [zMin-zReg zMax+zReg]);

    xlabel(hAx2, 'Time');
    ylabel(hAx2, 'Z Position');
    title(hAx2, 'Height-Time Curve');

    hAx3 = nexttile(3,[2 2]);  % 第三个图块占据2行2列，获取当前坐标轴句柄
     % 创建一个animatedline对象来绘制轨迹
    lineObj = animatedline(hAx3,'Color', 'b', 'LineWidth', 2);
    % 设置坐标轴标签和标题
    xlabel('X 轴');    ylabel('Y 轴');    zlabel('Z 轴');
    title('无人机实时运动轨迹三维动画','FontSize',14,'FontWeight','bold');
    xlim([xMin-xReg xMax+xReg]);    ylim([yMin-yReg yMax+yReg]);    zlim([zMin-zReg zMax+zReg]);

    % 初始化视角
    view(3);
    
    % 创建一个立方体来代表无人机
    % 定义立方体的顶点
    vertices = [0 0 0; 1 0 0; 1 1 0; 0 1 0; ...
                0 0 1; 1 0 1; 1 1 1; 0 1 1]/10;
    % 定义立方体的面
    faces = [1 2 3 4; 5 6 7 8; 1 2 6 5; 2 3 7 6; ...
             3 4 8 7; 4 1 5 8];

    % % 假设你的STL文件名为 'drone_model.stl'
    % filename = 'drone_model.stl';
    % % 导入STL文件
    % [vertices, faces] = stlread(filename);

    % 创建一个patch对象
    droneObj = patch('Vertices', vertices, 'Faces', faces, 'FaceColor', 'r');

    % 创建一个line对象用于表示当前高度
    hHeightLine = line('XData', [0, 0], 'YData', [0, 0], 'ZData', [0, 0], ...
                   'Color', 'k', 'LineStyle', '--', 'LineWidth', 1.5);
    % 创建一个文本框用于显示坐标
    hText = text(0, 0, 0, ' ', 'HorizontalAlignment', 'left', ...
             'VerticalAlignment', 'bottom', 'Parent',hAx3);


    % 逐行读取数据并更新 animatedline 对象
    for i = 1:height(flightLogData)
        % 更新x-y平面曲线
        addpoints(hLineXY, flightLogData{i, xCol}, flightLogData{i, yCol});
        % 更新z-t高度时间曲线
        addpoints(hLineZT, flightLogData{i, 1}, curHeight(i));


         % 更新3D动画轨迹
        addpoints(lineObj, flightLogData{i, xCol}, flightLogData{i, yCol}, curHeight(i));
        % 更新无人机模型的位置
        set(droneObj, 'XData', vertices(:, 1)  + flightLogData{i, xCol} - 0.05, ...
                      'YData', vertices(:, 2)  + flightLogData{i, yCol} - 0.05, ...
                      'ZData', vertices(:, 3)  + curHeight(i));
        % 更新当前高度的虚线
        set(hHeightLine, 'XData',  [flightLogData{i, xCol}, flightLogData{i, xCol}], ...
                         'YData',  [flightLogData{i, yCol}, flightLogData{i, yCol}], ...
                         'ZData',  [0, curHeight(i)]);
        % 更新显示坐标的文本框
        posStr = sprintf('x: %.2f, y: %.2f, z: %.2f', flightLogData{i, xCol}, flightLogData{i, yCol}, curHeight(i));
        set(hText,'String', posStr, 'Position', [flightLogData{i, xCol}, flightLogData{i, yCol}, curHeight(i)]);

        
        % 更新图形的显示
        drawnow;
        
        % 根据需要暂停一小段时间以模拟动态效果
        pause(0.01);
    end
end
