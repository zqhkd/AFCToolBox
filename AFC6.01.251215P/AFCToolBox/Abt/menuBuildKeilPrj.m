function menuBuildKeilPrj()
% /******************** (C) COPYRIGHT 2023 ACG Tech Group.**********************************************
%  * 作    者 ： 曾庆华
%  * 文 件 名 ： menuBuildKeilPrj.m
%  * 描    述 ： 从Simulink菜单启动编译工程文件，获得HEX文件
%  * 版    本 ： V1.01.231011   初版基本功能程序
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
    set_param(activeConfigObj,'t_DownLoad2Target','off');
    rtwbuild(ModelName);
end
