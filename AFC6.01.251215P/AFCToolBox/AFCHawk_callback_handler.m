% ==============================================================================================
% * 作    者： 曾庆华
% * 文 件 名：AFCGlobalVar.h
% * 描    述：AFC-5快速原型组件配置参数修改
% * 版    本：
% * 官    网：www.acecreator.com
% * 淘    宝：acecreator.taobao.com
% * 公 众 号：无人飞行控制
% ==========================================================================

function AFCHawk_callback_handler(hDlg, hSrc)
% This file is the callback function for configuration options when choose AFCHawk.tlc
% Do not generate sample main.c
    slConfigUISetVal(hDlg, hSrc, 'GenerateSampleERTMain', 'off');
    slConfigUISetEnabled(hDlg, hSrc, 'GenerateSampleERTMain', false);
    
    slConfigUISetVal(hDlg, hSrc, 'GenCodeOnly', 'On');
    slConfigUISetEnabled(hDlg, hSrc, 'GenCodeOnly', false);
    
    slConfigUISetVal(hDlg, hSrc, 'ProdHWDeviceType', 'STMicroelectronics->ST10/Super10');
    slConfigUISetEnabled(hDlg, hSrc, 'ProdHWDeviceType', false);
    
    % V5.05.240818: 参数配置页面的数据有效性中"精度损失"设置为'无'
    slConfigUISetVal(hDlg, hSrc, 'ParameterPrecisionLossMsg', 'none');

     % V5.05.240818: 参数配置页面的数据有效性中"定点常数精度损失"设置为'无'
    slConfigUISetVal(hDlg, hSrc, 'FixptConstPrecisionLossMsg', 'none');

    % % V5.05.240818: 参数配置页面的代码生成>>优化中"默认参数行为"设置为'可调'，这样确保initUserModelNamePara.m函数中的工作空间变量不要生成为常数
    % slConfigUISetVal(hDlg, hSrc, 'DefaultParameterBehavior', 'Tunable');

end