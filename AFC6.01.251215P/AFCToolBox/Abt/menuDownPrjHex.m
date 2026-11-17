function menuDownPrjHex()
% /******************** (C) COPYRIGHT 2023 ACG Tech Group.**********************************************
%  * 作    者 ： 曾庆华
%  * 文 件 名 ： menuDownPrjHex.m
%  * 描    述 ： 从Simulink菜单启动下载HEX文件至硬件板
%  * 版    本 ： V1.01.231011   初版基本功能程序
%  * 官    网 ：www.acecreator.com
%  * 淘    宝 ：acecreator.taobao.com
%  * 公 众 号 ：无人飞行控制
% **********************(C) COPYRIGHT 2023 ACG Tech Group.**********************************************/
   [hexFileName,filePath] = uigetfile('*.hex');   % 用户选择待烧写的hex文件
   if hexFileName ~= 0
       autoDownPrjHex(filePath,hexFileName);   % 生成的hex文件在ModelName_ert_rtw目录的obj子目录下
   end
end