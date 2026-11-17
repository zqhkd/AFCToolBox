%%
% 程序功能：运行后弹出文件选择对话框，用户可选择1个或多个s-function文件,
% 程序根据用户选择的c文件，自动批量进行mex处理,并返回转换的c文件数量
% 版本号V1.01.240105
% 注1：若c文件与当前脚本路径不一致，则程序生成.mex64文件前回自动切换到c文件路径、且最后回切回当前脚本路径。
% 注2: 已知bug，如果c文件不是s-function函数，且其函数名与文件名不一致(即c函数本身有问题)，则程序会给出警告以及已生成.mex64文件的提示信息，但实际上并未生成

currentFolder = pwd;  %获取并保存当前脚本的绝对路径
currentFolder = sprintf('%s\\',currentFolder);

[file,path] = uigetfile('*.c','请选择一个或多个s-function文件', ...
    'MultiSelect', 'on');

if ~isequal(file,0)
    disp(['用户已选择文件夹路径为：', path]);

    flagPath = strcmp(currentFolder, path);  %1表示m文件与脚本文件路径一致，0表示不一致
    if ~flagPath  %路径一致则不需要切换
      cd(path);  %切换到目标路径，若目标路径与脚本路径不一致，则无法在目标路径生成p文件
    end

    Num = C2Mex64(file);  % 批量mex所有文件

    disp(['已完成mex操作的s-function文件数量总计为：', num2str(Num)]);

    if ~flagPath
       cd(currentFolder);  %切回原来路径
    end
else
    disp('用户取消选择');
end
%%
% 根据输入的m文件绝对路径，将其生成p文件,并返回转换的文件数量
% m文件路径  fileName
% m文件数量  fileNum
function fileNum = C2Mex64(fileName)
    if ~isempty(fileName)
        switch class(fileName)  %用户选择N个c文件，若N>=2则file为1*N的元胞数组，若N=1则file为字符数组
            case 'cell'
                fileNum = size(fileName,2);
                for i = 1:fileNum
                    tmps = ['mex ' fileName{1,i} ' -lConnectedIO_Base.lib'];
                    eval(tmps);
                    disp(['已完成第', num2str(i),'个s-function模块函数的mex操作：', fileName{1,i}]);
                end
            case 'char'
                fileNum = 1;
                tmps = ['mex ' fileName ' -lConnectedIO_Base.lib'];
                eval(tmps);
                disp(['已完成1个s-function模块函数的mex操作：', file]);
            otherwise
                fileNum = 0;
        end
    else
        fileNum = 0;
    end
end