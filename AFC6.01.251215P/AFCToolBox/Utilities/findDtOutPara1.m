%%
%查找DTComOut及其连接的Mux信号名
clc;clear;

modelPath = pwd;
modelName = bdroot;
blockName = gcb; %加载当前模块路径bywt

load_system(modelName);
%%
allLines = find_system(modelName,'IncludeCommented','off',...
    'FindAll','On','type','line');

%获取模型中所有信号线属性
for i = 1 : length(allLines)
    tempData(i).Identifier =  allLines(i);
    sourceData = get_param(tempData(i).Identifier,'SrcBlockHandle');
    destinationData = get_param(tempData(i).Identifier,'DstBlockHandle');
    sourcePortData = get_param(tempData(i).Identifier,'SrcportHandle');
    destinationPortData = get_param(tempData(i).Identifier,'DstportHandle');
    tempData(i).SourceBlock =  get_param(sourceData, 'Name');
    tempData(i).DestinationBlock = get_param(destinationData,'Name') ;
    tempData(i).SourcePort =  get_param(sourcePortData, 'Name');
    tempData(i).DestinationPort =  get_param(destinationPortData, 'Name');
    tempData(i).DestinationBlockType =  get_param(destinationData, 'ReferenceBlock');
    tempData(i).SourceBlockType = get_param(sourceData, 'BlockType');%新增获取源模块类型bywt
    
    %get_param(destinationData, 'g_frameType')
    %fprintf();
end
[~, num] = size(tempData);
counter = 0;    %DTComOutNum计数器
%%
%该段功能：从信号线的起点和终点查找是否存在信号及其信号名
for i = 1:num

    MuxFlag = contains(tempData(1,i).SourceBlockType,'Mux');%改为使用源模块类型做判断bywt
    DTComOutFlag = contains(tempData(1,i).DestinationBlockType,'DTComOut'); %信号线的终点模块，如果为SimuOut模块，则使用SimuOut替换DTComOut即可

    if DTComOutFlag %如果信号线终点是DTComOut

        if MuxFlag  %如果信号线起点是Mux
            counter = counter + 1;
            DTComOutSlxLine{counter,1} = tempData(1,i).SourceBlock;   %第1列：不含路径的源模块名称
            DTComOutSlxLine{counter,2} = tempData(1,i).DestinationBlock;   %第2列：不含路径的DTComOut名称

            DTComOutSlxLine{counter,3} = getfullname(tempData(1,i).Identifier);   %第3列：含路径的源模块名称
            DTComOutSlxLine{counter,3} = strrep(DTComOutSlxLine{counter,3}, '/1', '');%删除最后的'/1'

            %第4列：含路径的DTComOut名称
            %注：使用时必须保证Mux与其相连的DTComOut处于同一级子系统；
            %查找绝对路径
            tempIndex = strfind(DTComOutSlxLine{counter,3},'/');
            [~, col] = size(tempIndex);
            if col >= 1
                Index = tempIndex(1,col);
                DTComOutSlxLine{counter,4} = extractBefore(DTComOutSlxLine{counter,3},Index);
            end

            %拼接
            DTComOutSlxLine{counter,4} = [DTComOutSlxLine{counter,4} '/' DTComOutSlxLine{counter,2}];

            %第5列：根据对应的Mux查找其对应的信号名称，并写入第5列
            DTComOutSlxLine{counter,5} = get_param(DTComOutSlxLine{counter,3},'InputSignalNames')';

        else
            counter = counter + 1;
            DTComOutSlxLine{counter,1} = tempData(1,i).SourceBlock;    %第1列：不含路径的源模块名称
            DTComOutSlxLine{counter,2} = tempData(1,i).DestinationBlock;   %第2列：不含路径的DTComOut名称

            DTComOutSlxLine{counter,3} = getfullname(tempData(1,i).Identifier);    %第3列：含路径的源模块名称
            DTComOutSlxLine{counter,3} = strrep(DTComOutSlxLine{counter,3}, '/1', '');%删除最后的'/1'

            %第4列：含路径的DTComOut名称
            %注：使用时必须保证Mux与其相连的DTComOut处于同一级子系统；
            %查找绝对路径
            tempIndex = strfind(DTComOutSlxLine{counter,3},'/');
            [~, col] = size(tempIndex);
            if col >= 1
                Index = tempIndex(1,col);
                DTComOutSlxLine{counter,4} = extractBefore(DTComOutSlxLine{counter,3},Index);
            end

            %拼接
            DTComOutSlxLine{counter,4} = [DTComOutSlxLine{counter,4} '/' DTComOutSlxLine{counter,2}];

            %第5列：由于不存在mux，故使用信号线的名称，该情况仅在不使用mux而是直接在信号线上添加信号名
            DTComOutSlxLine{counter,5} = tempData(1,i).SourcePort;

        end

        DTComOutSlxLine{counter,6} = i;%新增一个读line中index元素bywt

    end

end
%%
% 判断帧类型bywt
for i=1:counter

    Dt_Out_type(i) = string(get_param(DTComOutSlxLine{i,4}, 'g_frameType'))

end
if (length(Dt_Out_type)-length(unique(Dt_Out_type))) ~= 0

    disp("Dtcomout帧类型不能相同！")

end

%%
% 输出当前选中Dtout的信号源为向量

Current_block = get_param(blockName,'handle');%获取当前模块句柄

if(get_param(Current_block,'BlockType') == "S-Function" && get_param(Current_block,'ReferenceBlock') == "AFC5Toolbox/DTComOut")%判断当前打开模块是否为DTcomout


    DTComout_index = find(blockName == string(DTComOutSlxLine(:,4)) == 1);%获取当前Dtcomout连接线在DTComout线数组中的位置

    Line_index = cell2mat(DTComOutSlxLine(DTComout_index,6));%获取Dtcomout连接线在line数组中的位置

    if(tempData(1,Line_index).SourceBlockType == "Mux")%如果线左端是Mux
    
        Muxhandle = cell2mat(get_param(DTComOutSlxLine(DTComout_index,3),'handle'));%读Mux地址，获取Mux的句柄

        Line_conn2mux = get_param(Muxhandle,'LineHandles').Inport;%将输入Mux的线的句柄赋给Line_conn2mux
        
        judge_vector = [];

        for l = Line_conn2mux

            judge_vector = [judge_vector,get_param(get_param(l,'SrcBlockHandle'), 'BlockType') == "Mux"];%判断是否没有mux连接
            
        end

        while(any(judge_vector))%有线连接mux

            index_vector = find(judge_vector == 1);%找出连接mux的线在judge_vector的坐标

            for i = index_vector

                Line_conn2mux = [Line_conn2mux,get_param(get_param(Line_conn2mux(i),'SrcBlockHandle'),'LineHandles').Inport];

                Line_conn2mux(i) = [];

            end%把连接的Mux的输入加入Line_conn2mux,删除原线

            judge_vector =[];

            for l = Line_conn2mux

            judge_vector = [judge_vector,get_param(get_param(l,'SrcBlockHandle'), 'BlockType') == "Mux"];%判断是否没有mux连接
            
            end%遍历，看有没有连接Mux的

        end
    else%如果不是mux,输出信号名

        Line_conn2mux = tempData(1,Line_index).Identifier;%将该线的id赋给Line_conn2mux

    end

end


%%
% 创建结构体,放置线的id和名字
for i = 1:length(Line_conn2mux)

    conn2mux_struct(i).id = Line_conn2mux(i);%id

    conn2mux_struct(i).Name = string(get_param(Line_conn2mux(i), 'Name'));%名字

end

%对空的数据进行处理
if any([conn2mux_struct.Name] == "")%有Name为空的线
    
    Name_index = find(([conn2mux_struct.Name] == "") == 1);

end

%%
% %生成需要的SignalName.txt文件
% fid = fopen([modelName '_SignalNames.txt'],'wt');
% 
% xmlData = {};
% 
% for i = 1:counter    %counter为DTComOut个数
%     elementNum = length(DTComOutSlxLine{i,5});%当前Mux所含的信号个数
% 
%     fprintf(fid,'%s,%d',DTComOutSlxLine{i,4},elementNum);%依次写入：DTComOut绝对路径，信号数目，信号名称（如果有的话）
% 
%     tempStr = '';
% 
%     switch class(DTComOutSlxLine{i,5})
%         case 'cell'
%             for j = 1:elementNum
%                 tempStr = [tempStr ',' DTComOutSlxLine{i,5}{j,1}];%表示有Mux的多个信号
%             end
%         case 'char'
%             tempStr = [tempStr ',' DTComOutSlxLine{i,5}];%表示有一个标量直连的信号
%         otherwise
%             tempStr = '';%表示没有Mux，也没有标记的信号
%     end
%     fprintf(fid,'%s\n',tempStr);%依次写入信号名
% end
% fclose(fid);
% 
% fprintf('Success:The file %s_SignalNames.txt has been created. And the DTComOut number is %d!\n', modelName, counter);

%%
%生成并写入DTComOut的信号名xml文件

xmlName = string([modelName '_SignalNames.xml']);

docNode = com.mathworks.xml.XMLUtils.createDocument('obj');
docRootNode = docNode.getDocumentElement;
%docRootNode.setAttribute('attr_name','attr_value');

IDNumberNode = docNode.createElement('DTComOutNumber'); %写入数量
IDNumberNode.appendChild(docNode.createTextNode(sprintf('%d',counter)));
docRootNode.appendChild(IDNumberNode);

for i = 1:counter    %counter为DTComOut个数

    IDNode = docNode.createElement('ID');   %写入当前DTComOut的路径名
    IDNode.appendChild(docNode.createTextNode(sprintf('%s',DTComOutSlxLine{i,4})));
    docRootNode.appendChild(IDNode);

    elementNum = length(DTComOutSlxLine{i,5});%当前Mux所含的信号个数

    objNmNode = docNode.createElement('SignalNumber');  %写入当前DTComOut的信号数量
    objNmNode.appendChild(docNode.createTextNode(sprintf('%d',elementNum)));
    docRootNode.appendChild(objNmNode);

    switch class(DTComOutSlxLine{i,5})  %判断当前DTComOut的信号数量、并写入
        case 'cell' %若为cell类型，则表示有多于1个的信号
            thisElement = docNode.createElement(sprintf('SignalName'));
            docRootNode.appendChild(thisElement);

            for j = 1:elementNum
                dataNode = docNode.createElement(sprintf('Name_%d',j));
                dataNode.appendChild(docNode.createTextNode(DTComOutSlxLine{i,5}{j,1}));
                thisElement.appendChild(dataNode);
            end

        case 'char' %若为char类型，则表示有1个的信号
            if ~isempty(DTComOutSlxLine{i, 5})
                thisElement = docNode.createElement(sprintf('SignalName'));
                docRootNode.appendChild(thisElement);

                dataNode = docNode.createElement(sprintf('Name_%d',1));
                dataNode.appendChild(docNode.createTextNode(DTComOutSlxLine{i,5}));
                thisElement.appendChild(dataNode);
            end

        otherwise   %否则，无信号

    end
end

docNode.appendChild(docNode.createComment('AFC5_DTComOut_SignalNames'));    %添加注释

xmlwrite(xmlName,docNode);  %写入xml文件

fprintf('Success:The file %s has been created. And the DTComOut number is %d!\n', xmlName, counter);
%type(xmlName);