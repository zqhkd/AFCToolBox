function menuCioDeploy
    % 使用前在主函数里先配置好工作路径
    % 2023-11-23
    % 与StripToolTab挂接作为ConnectedIO模式下的RUN按钮的Callback来启动自动编译过程。
    %                               对文件和函数名进行了部分调整，使其命名更为合理。
    %  * 输入参数：发布方式，分别为
    %      0--普通用户发布（需运行安装程序，指定KeilCC、STLinkProgramer或JLinkProgramer、AFC5ProjectPath等环境变量）
    %      1--内部测试版，已固定KeilCC、STLinkProgramer或JLinkProgramer等环境变量，而AFC5ProjectPath为\AFC-5PRJ\AFC.APP路径
    %      2--内部开发版，已固定KeilCC、STLinkProgramer或JLinkProgramer等环境变量，而AFC5ProjectPath为\AFC-5Full路径
    clc;
    iPublishSel = 2;
    
    [ModelName,~,prjPath] = setEnvPath(iPublishSel);
   
    destFolder = [prjPath,'\Simulink'];   % 自动生成代码Simulink的目标文件夹
    deleteToEmpty(destFolder);      % 删除掉上次用户产生的所有文件

    % 生成上下位机需要的数据传输文件
    AFC5Blks_info = getIOBufferInfo(ModelName, destFolder);
    
    % Update AFC5 block PortNumber
    AFC5Blks_h = find_system(gcs, 'findall', 'on', 'regexp','on','ReferenceBlock', 'AFC5Toolbox');

    AFC5Blks_num = length(AFC5Blks_h);
    comPort = get_param(ModelName, 't_comPort');
    comBaud = get_param(ModelName, 't_comBaud');
    for ii = 1:AFC5Blks_num
        set_param(AFC5Blks_h(ii), 'g_comPort', num2str(comPort));
    end
    
    targetFile = cioProcess(prjPath, destFolder, ModelName);
    %UpdateSimuAlgorithm.integrateProcess(ModelName, destFolder, intFileName);
    buildKeilPrj(1,prjPath,targetFile);
    
    downloadPath = [destFolder,'\obj'];    hexFileName = [ModelName,'.hex'];
    autoDownPrjHex(downloadPath,hexFileName);   % 生成的hex文件在prjPath\Simulink\目录的obj子目录下

    pause(5);

    % 启动ConnectedIO引擎
    StartEngine([prjPath,'\AFCToolBox\ConnectedIO'], comPort,comBaud);

    %运行仿真
    set_param(gcs, 'SimulationCommand', 'start');
end