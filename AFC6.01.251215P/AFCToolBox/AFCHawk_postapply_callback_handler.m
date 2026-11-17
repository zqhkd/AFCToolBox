% ==============================================================================================
%
%
% ==========================================================================

function AFCHawk_postapply_callback_handler(~, ~)

% update all AFC5 block to make sure their COM PORT to be the same with
% Configuration Parameter.
modelName = bdroot(gcs);
comPort = get_param(modelName, 't_comPort');

AFC5Blks_h = find_system(gcs, 'findall', 'on', 'regexp','on','ReferenceBlock', 'AFC5Toolbox');
AFC5Blks_num = length(AFC5Blks_h);
for ii = 1:AFC5Blks_num
    set_param(AFC5Blks_h(ii), 'g_comPort', num2str(comPort));
end

% undate AFC5 block info for connected IO and generate Buffer_IO.h
% AFC5Blks_info = getIOBufferInfo(modelName, destFolder);
destFolder = pwd;  % path to modify in the future, not designed yet.
getIOBufferInfo(modelName, destFolder);
end