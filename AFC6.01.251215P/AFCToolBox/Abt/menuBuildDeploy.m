function menuBuildDeploy()
% /******************** (C) COPYRIGHT 2023 ACG Tech Group.**********************************************
%  * 作    者 ： 曾庆华
%  * 文 件 名 ： abt_main.m
%  * 描    述 ： 自动部署工具主程序
%  * 版    本 ： V1.01.230920   初版基本功能程序
%  *             V1.01.230924   根据ACG团队需求，对初版程序进行更改，包括：
%                                 (1) 使用前在主函数里先配置好工作路径
%                                 (2) 与StripToolTab挂接作为其Callback来启动自动编译过程。
%                                 (3) 增加了Ctrl+B启动自动编译功能。
%  *             V1.02.230926   基于V1.01版针对AFC系列产品特点，按照AFC-5自动部署总体设计思路
%                               进行了全面修改，通过setenv的设置，基本具备自动部署功能。
%  *             V1.03.231002   基于V1.02,考虑三种不同发布模式，并将大部分外部m函数进行了整合处理，
%                               对文件和函数名进行了部分调整，使其命名更为合理。
%  * 输入参数：发布方式，分别为
%      0--普通用户发布（需运行安装程序，指定KeilCC、STLinkProgramer或JLinkProgramer、AFC5ProjectPath等环境变量）
%      1--内部测试版，已固定KeilCC、STLinkProgramer或JLinkProgramer等环境变量，而AFC5ProjectPath为\AFC-5PRJ\AFC.APP路径
%      2--内部开发版，已固定KeilCC、STLinkProgramer或JLinkProgramer等环境变量，而AFC5ProjectPath为\AFC-5Full路径
%  * 官    网 ：www.acecreator.com
%  * 淘    宝 ：acecreator.taobao.com
%  * 公 众 号 ：无人飞行控制
% **********************(C) COPYRIGHT 2023 ACG Tech Group.**********************************************/
    ModelName = bdroot(gcs);
    % 初始化全局变量
    initWorkSpaceVariables(ModelName);

    % 启动代码生成
    activeConfigObj = getActiveConfigSet(ModelName);
    set_param(activeConfigObj,'t_BuildCPrj2Hex','on');
    set_param(activeConfigObj,'t_DownLoad2Target','on');
    rtwbuild(ModelName);
end
