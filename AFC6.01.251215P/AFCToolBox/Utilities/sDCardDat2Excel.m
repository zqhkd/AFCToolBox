function sDCardDat2Excel()
% 读取并转换存储在SD Card上的十六进制数据为Excel
%   . 读取SD Card 详细信息;
%   . 将读取信息返回，并转存至同名的Excel文件中
%  程序设计：王赛、曾庆华
%  版    本：V1.01.231014
%  
[datFile,filePath] = uigetfile('*.dat');
fileName = [filePath datFile];
fid = fopen(fileName,'r');

if(fid~=0)
    varNum = double(fread(fid,1));
    firstLine = fgetl(fid);    % 假设首行变量定义栏
    varStr = split(firstLine,',');

    name = split(datFile,'.');
    excelName = fullfile(filePath,[name{1} '.xlsx']);
    writecell(varStr', excelName, 'WriteMode', 'overwrite');
    
    while ~feof(fid)
        A = fread(fid,"float");
        A = A';
        num_to_pad = varNum - mod(length(A), varNum);
        if num_to_pad < varNum
            A = [A, NaN(1,num_to_pad)];
        end
        matrix = reshape(A,  varNum,[]);
        writematrix(matrix', excelName, 'WriteMode', 'append');
    end
    fclose(fid);
    disp('给定的dat文件已经转换成了xlsx文件！');
end
end