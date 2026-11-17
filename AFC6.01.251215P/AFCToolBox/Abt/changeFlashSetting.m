function changeFlashSetting()
    burner = {'JLink烧写器','ST-Link烧写器'};

    [choice,tf] = listdlg("PromptString",'请选择下载Hex文件的烧写器：',...
    'ListString',burner,'SelectionMode','single','ListSize',[170 70]);
    remFlag = 'No';
    if(tf == 1)
        remFlag = questdlg('确认更改下载设置？');
    end
    if (remFlag == 'Yes')
        save("settingFile.mat","choice","tf","remFlag");
    end
end