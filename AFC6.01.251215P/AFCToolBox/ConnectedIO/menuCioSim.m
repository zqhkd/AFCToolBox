function menuCioSim
    % 需要首先运行过menuCioDelpoy.m，在该函数中会设置环境变量
    [~,~,prjPath] = setEnvPath(2);
    % prjPath = getenv('AFC5ProjectPath');   % 需要用户配置安装路径
    % 启动ConnectedIO引擎
    comPort = get_param(bdroot(gcs), 't_comPort');
    comBaud = get_param(bdroot(gcs), 't_comBaud');

    StartEngine([prjPath,'\AFCToolBox\ConnectedIO'], comPort,comBaud);

    %运行仿真
    pause(2);
    set_param(gcs, 'SimulationCommand', 'start');
end