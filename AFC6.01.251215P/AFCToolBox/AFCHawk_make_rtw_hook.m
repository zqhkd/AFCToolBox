function AFCHawk_make_rtw_hook(hookMethod, ...
                           modelName, ...
                           rtwroot, ...
                           templateMakefile, ...
                           buildOpts, ...
                           buildArgs, ...
                           buildInfo) %#ok<INUSL,INUSD> 
  switch hookMethod
   case 'error'
    % Called if an error occurs anywhere during the build.  If no error occurs
    % during the build, then this hook will not be called.  Valid arguments
    % at this stage are hookMethod and modelName. This enables cleaning up
    % any static or global data used by this hook file.
    msg = DAStudio.message('RTW:makertw:buildAborted', modelName);
    disp(msg);
   case 'entry'
    % Called at start of code generation process (before anything happens.)
    % Valid arguments at this stage are hookMethod, modelName, and buildArgs.
    msg = DAStudio.message('RTW:makertw:enterRTWBuild', modelName);
    disp(msg);
    
    option = LocalParseArgList(buildArgs);
    
    if ~strcmp(option,'none')
        ert_unspecified_hardware(modelName);
        cs = getActiveConfigSet(modelName);
        cscopy = cs.copy;
        ert_auto_configuration(modelName,option);
        locReportDifference(cscopy, cs);
    end
    
   case 'before_tlc'
    % Called just prior to invoking TLC Compiler (actual code generation.)
    % Valid arguments at this stage are hookMethod, modelName, and
    % buildArgs
    
   case 'after_tlc'
    % Called just after to invoking TLC Compiler (actual code generation.)
    % Valid arguments at this stage are hookMethod, modelName, and
    % buildArgs
    cd ..
    autoBuildDeploy(0);   % 使用发布版模式

   case 'before_make'
    % Called after code generation is complete, and just prior to kicking
    % off make process (assuming code generation only is not selected.)  All
    % arguments are valid at this stage.

   case 'after_make'
    % Called after make process is complete. All arguments are valid at 
    % this stage.
    
    
   case 'exit'
    % Called at the end of the build process.  All arguments are valid
    % at this stage.
    if strcmp(get_param(modelName,'GenCodeOnly'),'off')
        msgID = 'RTW:makertw:exitRTWBuild';
    else
        msgID = 'RTW:makertw:exitRTWGenCodeOnly';
    end
    msg = DAStudio.message(msgID,modelName);
    disp(msg);
  end


% Simple parse function to find:
%   optimized_fixed_point=1
%   optimized_floating_point=1
function option = LocalParseArgList(args)
  
  if contains(args,'optimized_fixed_point=1')
    option = 'optimized_fixed_point';
  elseif contains(args,'optimized_floating_point=1')
    option = 'optimized_floating_point';
  else
    option = 'none';
  end

% local function: report difference between the configuration set settings
% before and after running auto-configuration script.  
function locReportDifference(cs1, cs2)
    [iseq, diffs] = slprivate('diff_config_sets', cs1, cs2, 'string');
    if ~iseq
        msg = DAStudio.message('RTW:makertw:incompatibleParamsUpdated', diffs);
        summary = DAStudio.message('RTW:makertw:autoconfigSummary');
        rtwprivate('rtw_disp_info',...
                   get_param(cs2.getModel, 'Name'),...
                   summary,...
                   msg);
    end
