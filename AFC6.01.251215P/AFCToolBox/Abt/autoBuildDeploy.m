function autoBuildDeploy(iPublishSel)
% /******************** (C) COPYRIGHT 2023 ACG Tech Group.**********************************************
%  * 作    者 ： 曾庆华
%  * 文 件 名 ： autoBuildDeploy.m
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
%      0--普通用户发布（需运行安装程序，指定KeilCC、STLinkProgramer或JLinkProgramer、AFCProjectPath等环境变量）
%      1--内部测试版，已固定KeilCC、STLinkProgramer或JLinkProgramer等环境变量，而AFCProjectPath为\AFC-5PRJ\AFC.APP路径
%      2--内部开发版，已固定KeilCC、STLinkProgramer或JLinkProgramer等环境变量，而AFCProjectPath为\AFC-5Full路径
%  * 官    网 ：www.acecreator.com
%  * 淘    宝 ：acecreator.taobao.com
%  * 公 众 号 ：无人飞行控制
% **********************(C) COPYRIGHT 2023 ACG Tech Group.**********************************************/

    [ModelName,destPath,prjPath] = setEnvPath(iPublishSel);
    
    % clear simulik folder & generate SimMode.h into simulink folder. 
    simulinkFolder = [prjPath,'\Simulink'];   % 自动生成代码Simulink的目标文件夹
    deleteToEmpty(simulinkFolder);      % 删除掉上次用户产生的所有文件
    fid = fopen(fullfile(simulinkFolder, 'SimMode.h'),'w');    % each time rewrite existing file.
    fprintf(fid, '#define __AUTO_BUILD_DEPLOY__\n\n');
    fclose(fid);

    if(bChkEnvVariableValid())   % 当未正常安排Keil C及AFC-5工程文件时，会导致报错
        buildCPrjFlg = strcmp(get_param(ModelName, 't_BuildCPrj2Hex'),'on');     % 获取当前模型文件AFC-5配置项：自动编译C工程
        autoDownFlg = strcmp(get_param(ModelName, 't_DownLoad2Target'),'on');     % 获取当前模型文件AFC-5配置项：自动下载目标文件
        
        % 进行模型自定义规则检查，如同类模块的帧类型码是否相同，参数定义是否完备等等

        modelChecked = procDtOutParaName(ModelName,prjPath,50);
        if(modelChecked)
            try
            %    rtwbuild(bdroot(gcs));
                XMLMsgDTComInSignal(ModelName,prjPath);
                if(buildCPrjFlg)
                    targetFile = abtProcess(prjPath, destPath, ModelName);
                    
                    buildStatus = buildKeilPrj(0, prjPath,targetFile);
                    if buildStatus == 0
                        fig = msgbox("编译成功！","Build succeed!");
                        if(autoDownFlg)
                            downloadPath = [destPath '\obj'];
                            hexFileName = [ModelName '.hex'];
                            autoDownPrjHex(downloadPath,hexFileName);   % 生成的hex文件在ModelName_ert_rtw目录的obj子目录下
                        end
                        cd(destPath);   % 切换为RTW所要求的工作路径
                        pause(5);
                        close(fig);
                    end
                end
            catch
                disp('自动代码生成过程中编译或下载错误！');
            end
        end
    end
end

function bChkFlg = bChkEnvVariableValid()
% This function is to check environment variables 
% Zeng QingHua 20231007
    bChkFlg = true;
    fileName = [getenv('KeilCC') '\UV4.exe'];
    if(exist(fileName,'file')~=2)
        bChkFlg = false;
        disp('[Keil C Setup Error]: 未正常安装Keil C编译器或环境变量KeilCC设置错误!');
    end

    fileName = fullfile(getenv('AFCProjectPath'),'AFCToolBox\AFCSystem.inf');
    if(exist(fileName,'file')~=2)
        bChkFlg = false;
        disp('[AFC Project Setup Error]: 未正常安装AFC工程文件或环境变量AFCProjectPath设置错误!');
    end

    fileName = [getenv('STLinkProgramer') '\ST-LINK_CLI.EXE'];
    flg1 = (exist(fileName,'file')~=2);
    if(flg1)
        disp('[STLink Programmer Setup Warning]: 未正常安装STLink编程器或环境变量STLinkProgramer设置错误!');
    end
    % fileName = [getenv('JLinkProgramer') '\JLink.EXE'];
    % flg2 = (exist(fileName,'file')~=2);
    % if(flg2)
    %     disp('[JLink Programmer Setup Warning]: 未正常安装Jlink编程器或环境变量JLinkProgramer设置错误!');
    % end
end

