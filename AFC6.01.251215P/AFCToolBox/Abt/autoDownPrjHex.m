function autoDownPrjHex(downloadPath,hexFileName)
%输入：工程路径prjPath，模型文件名modelName
%    待烧写的文件在prjPath\
%功能：将输入的hex文件烧写入通过ST-LINK调试器下载到主控芯片中
%版本：V1.0
%作者：喻 靖, 曾庆华
%%
    %输入待烧写文件路径
    
    hexFile = fullfile(downloadPath, hexFileName);   %要烧写文件路径及其名称
    burner = {'JLink烧写器','ST-Link烧写器'};
    if(exist("settingFile.mat", "file"))
        flashSettings = load('settingFile.mat');
        if flashSettings.remFlag == "Yes"
            choice = flashSettings.choice;
            tf = flashSettings.tf;
            remFlag = flashSettings.remFlag;
        end
    else
        [choice,tf] = listdlg("PromptString",'请选择下载Hex文件的烧写器：',...
        'ListString',burner,'SelectionMode','single','ListSize',[170 70]);
        remFlag = questdlg('是否记住您的选择，下次直接下载？');
    end
    if(remFlag == "Yes")
        save("settingFile.mat","choice","tf","remFlag");
    end
    
    if(tf)
        switch choice
            case 1
                flashcmd = [getenv('JLinkProgramer') '\JLink.EXE -autoconnect 1 -device STM32H743VI -if swd -speed 4000 -commandfile '];
                flashCmd = [flashcmd downloadPath '\download.jlink'];
                flashLogCmd = [ 'Log "' downloadPath 'flashLog.txt"'];

                % 以下注释行为显示jlink加载信息
                % flashLogTypeCmd = ['start /wait type ' downloadPath '\flashLog.txt']; 

                jlinkFile = fullfile(downloadPath,'download.jlink');
                fid = fopen(jlinkFile,'w');
                fprintf(fid, '%s\n',flashLogCmd);
                fprintf(fid, '%s\n','reset');
                fprintf(fid, '%s\n','erase');
                str = ['loadfile ' hexFile ' 0x08000000'];
                fprintf(fid, '%s\n',str);
                fprintf(fid, '%s\n','r');
                fprintf(fid, '%s\n','go');
                fprintf(fid, '%s\n','qc');
                fclose(fid);
                % check file exist

                %调用Window命令提示符，写入上述命令进行烧写
                system(flashCmd);    
            case 2
                %将文件路径与烧写命令进行拼接
                %flashCmd = [getenv('STLinkProgramer') '\ST-LINK_CLI.EXE -c SWD HOTPLUG -ME -V "after_programming" -P ' hexFile ' 0X08000000 -Rst'];
                flashCmd = strcat('"',getenv("STLinkProgramer"),'\ST-LINK_CLI.EXE', '"', ' -V "after_programming" -P ', " ", hexFile, ' 0X08000000 -Rst');

                %调用Window命令提示符，进行连接、擦除、烧写、复位操作
                connectFlag  = 100;
                eraseFlag = 100;
                downloadFlag  = 100;
                resetFlag = 100;
                h = waitbar(0,'正在连接AFC-5……');
                connectCmd = strcat('"',getenv("STLinkProgramer"),'\ST-LINK_CLI.EXE', '"',' -c SWD HOTPLUG');
                connectFlag = system(connectCmd);
                if connectFlag == 1
                    errordlg('找不到ST-Link下载工具，请检查相关配置！')
                else
                    if connectFlag == 2
                        errordlg('连接失败，请检查线路……');
                        close(h);
                    end
                    waitbar(0.2,h,'正在擦除板上程序……');

                    % eraseCmd = strcat('"',getenv("STLinkProgramer"),'\ST-LINK_CLI.EXE', '"',' -ME');
                    eraseCmd = strcat('"',getenv("STLinkProgramer"),'\ST-LINK_CLI.EXE', '"',' -SE 0-13');
                    eraseFlag = system(eraseCmd);
                    if eraseFlag == 11
                        errordlg('擦除失败！');
                        close(h);
                    end
                    waitbar(0.5,h,'下载中……');
                    
                    downloadFlag  = system(flashCmd);
                    if downloadFlag == 12
                        errordlg('下载失败！');
                        close(h);
                    end
                    waitbar(0.8,h,'正在复位AFC-5……');
                    resetCmd = strcat('"',getenv("STLinkProgramer"),'\ST-LINK_CLI.EXE', '"',' -Rst');
                    resetFlag = system(resetCmd);
                    if resetFlag == 6
                        errordlg('复位失败！');
                        close(h);
                    end
                    waitbar(1,h,'完成！');
                    close(h);
                end
            otherwise
                tf = 0;
        end
    end

    % 请增加烧写后的提示信息
    if(tf)
        %调用Window命令提示符，写入上述命令进行烧写
        %system(flashCmd);
        %system(flashLogTypeCmd);
        disp('[Your HEX file has been downloaded to the target board]: Download done!');
    else
        disp('[Your HEX file hasn''t been downloaded]: Not Run Download!');
    end
end