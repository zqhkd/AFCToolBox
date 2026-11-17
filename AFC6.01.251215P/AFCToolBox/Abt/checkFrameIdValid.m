function checkFrameIdValid(moduleName,curVal)
% This function find current model's moduleName whether its frame ID is
% valid
% 20231001 Zeng QingHua
% Method: Find all S-Function Module, and then judge whether it is moduleName, then compare its frame type.

modelName = bdroot(gcs);
f = Simulink.FindOptions('SearchDepth',1);

% 获取全部S-Function的句柄
hSFunction = Simulink.findBlocksOfType(modelName,'S-Function',f);

for i = 1:length(hSFunction)
    sFunctionModuleName = get_param(hSFunction(i),'SFunctionModules');
    if strcmp(sFunctionModuleName,moduleName)
        oldVal = str2double(get_param(hSFunction(i),'g_frameType'));
        if(curVal==oldVal)
            warning ('输入帧类型码与前面同类模块重复，请更改类型码！');
        end
    end
end
    
% hSimuComOut = get_param('SimuComMultFrame/SimuComOut','Handle');  % 获取SimuComOut的句柄
% get(hSimuComOut)或者get(hSfunction(i));   % 获取SimuComOut的全部属性信息
% get_param('SimuComMultFrame/SimuComOut2','SFunctionModules');   % 获取SimuComOut2的模块名
