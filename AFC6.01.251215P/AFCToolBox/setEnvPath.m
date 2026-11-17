function [modelName,destPath,prjPath] = setEnvPath(iPublishSel)
% /******************** (C) COPYRIGHT 2023 ACG Tech Group.**********************************************
%  * 作    者 ： 曾庆华
%  * 文 件 名 ： setEnvPath.m
%  * 描    述 ： 自动部署工具主程序
%  * 版    本 ： V1.01.250425   初版基本功能程序
%  * 输入参数：发布方式，分别为
%      0--普通用户发布（需运行安装程序，指定KeilCC、STLinkProgramer或JLinkProgramer、AFCProjectPath等环境变量）
%      1--内部测试版，已固定KeilCC、STLinkProgramer或JLinkProgramer等环境变量，而AFCProjectPath为\AFC-6PRJ\AFC.APP路径
%      2--内部开发版，已固定KeilCC、STLinkProgramer或JLinkProgramer等环境变量，而AFCProjectPath为\AFC-6Full路径
%  * 官    网 ：www.acecreator.com
%  * 淘    宝 ：acecreator.taobao.com
%  * 公 众 号 ：无人飞行控制
% **********************(C) COPYRIGHT 2023 ACG Tech Group.**********************************************/
    modelName = bdroot(gcs);    
    destPath = [modelName, '_ert_rtw'];
    % 自动生成代码为当前工作目录
    destPath = fullfile(pwd, destPath);    %  pwd获取当前工作目录，当前工作目录一般与ModelName用户模型文件所在目录一致。

    % 发布方式iPulishSel选择包括：
    %     0 -- 正常发布，环境变量已在用户安装过程中进行了定义，此处不用强行定义
    %     1 -- AFC-6PRJ工程发布版，也称内部版。主要是Keil工程文件路径在...\AFC\AFC-6PRJ\AFC.APP
    %     2 -- AFC-6FULL源工程版，也称开发版。主要是Keil工程文件路径在...\AFC\AFC-6FULL
    if(iPublishSel)
        % 环境变量设置后续将移至到安装包中
        setenv('KeilCC','C:\Keil_v5\UV4');      % 配置KeilCC编译器的环境变量，以便后续使用
        setenv('STLinkProgramer','C:\Program Files (x86)\STMicroelectronics\STM32 ST-LINK Utility\ST-LINK Utility');   %设置STLink编程器安装路径。
        setenv('JLinkProgramer','C:\Program Files\SEGGER\JLink');
    end   

    % 正式开始进行处理
    if(iPublishSel==1)
        setenv('AFCProjectPath','D:\AFC\AFC-6PRJ\AFC.APP');    %设置Keil工程的安装路径。这是曾庆华联想电脑T490发布版本的工程路径
    end
    if(iPublishSel==2)
        setenv('AFCProjectPath','D:\AFC\AFC-6FULL');  %设置Keil工程的安装路径。这是曾庆华联想电脑T490源工程版本路径
    end

    prjPath = getenv('AFCProjectPath');   % 需要用户配置安装路径
end