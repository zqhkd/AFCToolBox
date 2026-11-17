function Data = readFlightData(CsvOfCh5,CsvOfFly)
   % 读取飞行数据，且规定
    %% 昊顺
    % AFC4_flightdata0 = xlsread(strcat(dir, px4_num, '_AFC-4.csv'));
    
    if nargin == 0
        CsvOfCh5 = 'D_2.csv';
        CsvOfFly = 'D_3.csv';
    elseif nargin == 1
        CsvOfFly = 'D_3.csv';
    end

    HS_T0x2 = readmatrix(CsvOfCh5);  % 包含通道ch5
    HS_T0x3 = readmatrix(CsvOfFly);

    % 首先根据CsvOfCh5文件中Ch5通道给定条件查找最后一段时间段
    ch5Column = 23;   % T0x2中CH5在该表的第23列
    [startIdx,endIdx] = findZones(HS_T0x2,ch5Column,100);  % 在CsvOfCh5给定文件中查找起始时间点
    Data.time = HS_T0x2(startIdx:endIdx,1)/1000;
    Data.time1 = HS_T0x3(startIdx:endIdx,1)/1000;
    
    %遥控器通道
    Data.ch1 = HS_T0x2(startIdx:endIdx,16);
    Data.ch2 = HS_T0x2(startIdx:endIdx,17);
    Data.ch3 = HS_T0x2(startIdx:endIdx,18);
    Data.ch4 = HS_T0x2(startIdx:endIdx,19);
    Data.ch5 = HS_T0x2(startIdx:endIdx,23);
    Data.ch6 = HS_T0x2(startIdx:endIdx,22);
    Data.ch7 = HS_T0x2(startIdx:endIdx,21);
    Data.ch8 = HS_T0x2(startIdx:endIdx,20);
    Data.CHcmd1 = HS_T0x2(startIdx:endIdx,24);
    Data.CHcmd2 = HS_T0x2(startIdx:endIdx,25);
    Data.CHcmd3 = HS_T0x2(startIdx:endIdx,26);
    Data.CHcmd4 = HS_T0x2(startIdx:endIdx,27);

    %姿态, 注意在D_2.csv中
    Data.roll = HS_T0x2(startIdx:endIdx,13);
    Data.pitch = HS_T0x2(startIdx:endIdx,14);
    Data.yaw = HS_T0x2(startIdx:endIdx,15);

    %速度
    Data.velxcmd = HS_T0x3(startIdx:endIdx,9);
    Data.velycmd = HS_T0x3(startIdx:endIdx,10);
    Data.velzcmd = HS_T0x3(startIdx:endIdx,11);
    Data.velx = HS_T0x3(startIdx:endIdx,12);
    Data.vely = HS_T0x3(startIdx:endIdx,13);
    Data.velz = HS_T0x3(startIdx:endIdx,14);
    
    %位置
    Data.posx = HS_T0x3(startIdx:endIdx,6);
    Data.posy = HS_T0x3(startIdx:endIdx,7);
    Data.posz = HS_T0x3(startIdx:endIdx,8);
    
    % AFC5Sts状态字
    Data.iSts = HS_T0x3(startIdx:endIdx,22);
    Data.hoverThrottle = HS_T0x3(startIdx:endIdx,26);
    Data.Sts = getAFC5Status(Data.iSts);

end

% 查找通道5所在文件中CH5的值由低变高所在起始行列（一般有三个值0，352，1695.仅取1695所在区间的起始行数）
function [startIdx,endIdx] = findZones(data,ch5Column,remStepCounter)
    % 获取所有CH5列的数据
    startIdx = 0; endIdx = 0;

    ch5Data = data(:, ch5Column);   % ch5Colum为CH5通道所在列
    len = length(ch5Data);
    % 查找最后一段出现大于1000的CH5数据段的起始行和结束行
    for i = len:-1:1
        if ch5Data(i) > 1500
           % 如果找到一个大于1000的值，则检查是否是结束行
           if endIdx == 0
               endIdx = i  + min(remStepCounter,len - i - 1);
           end
        end
        % 找到>1000的最后时刻后，就要继续向前查找
        if (endIdx > 0) && (ch5Data(i) < 1500)
            startIdx = i - min(remStepCounter, i - 1);
            break;
        end
    end
    if (startIdx==0) || (endIdx==0)
        error('%s文件中没有找到最后一段出现大于1000的CH5数据。',CsvOfCh5);
    end    
end

function afc5_status = getAFC5Status(statusColumn)
 % 初始化结构体数组
    numRecords = size(statusColumn, 1);
    afc5_status = struct('bSystemInitSts', {}, 'bLandComplete', {}, 'bArmedEnable', {}, ...
                         'bDcmFastGroundGains', {}, 'bLimitRollPitch', {}, 'bLimitYaw', {}, ...
                         'bLimitThrottleLower', {}, 'bLimitThrottleUpper', {}, ...
                         'bMotorSlowStart', {}, 'Reserved', {}, ...
                         'iSbusErrNum', {}, 'iSdCardWriteErr', {}, 'iTaskOverTimeNo', {});
    % 解析状态字
    for i = 1:numRecords
        statusWord = statusColumn(i);
        afc5_status(i).bSystemInitSts = bitget(statusWord, 1);
        afc5_status(i).bLandComplete = bitget(statusWord, 2);
        afc5_status(i).bArmedEnable = bitget(statusWord, 3);
        afc5_status(i).bDcmFastGroundGains = bitget(statusWord, 4);
        afc5_status(i).bLimitRollPitch = bitget(statusWord, 5);
        afc5_status(i).bLimitYaw = bitget(statusWord, 6);
        afc5_status(i).bLimitThrottleLower = bitget(statusWord, 7);
        afc5_status(i).bLimitThrottleUpper = bitget(statusWord, 8);
        afc5_status(i).bMotorSlowStart = bitget(statusWord, 9);
        afc5_status(i).Reserved = bitget(statusWord, [10, 11, 12]);
        afc5_status(i).iSbusErrNum = bitget(statusWord, 13:16);
        afc5_status(i).iSdCardWriteErr = bitget(statusWord, 17:24);
        afc5_status(i).iTaskOverTimeNo = bitget(statusWord, 25:32);
    end
end
