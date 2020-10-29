function obj = saveobj(obj)
    stack       = dbstack('-completenames');
    callerLine  = evalc('dbtype(stack(2).file,num2str(stack(2).line))');
   
    % isolate save arguments
    expression      = 'save(\(?)(\s?)(?<arguments>.+)(?(1)\));?\n$';
    saveArgument    = regexp(callerLine,expression,'names');
    saveArgument    = struct2cell(saveArgument)';
    
    % process save arguments
    expression          = '(?<operator1>\[?)(?<operator2>\''?)(?<filename>(?(operator1).+?)(?(operator2).+?|.+))(?(operator1)\])(?(operator2)\'')';
    filenameExpression 	= regexp(saveArgument,expression,'names','once');
    filenameExpression 	= cat(1,filenameExpression{:});
    operator            = {filenameExpression.operator1}';
    filenameExpression	= {filenameExpression.filename}';
    
    % build filename expression
    filenameIsArray = ismember(operator,'[');
    filenameExpression(filenameIsArray) = strcat({'['},filenameExpression(filenameIsArray),{']'});
    
    % evaluate filename expression in callers workspace
   	filename = evalin('caller',filenameExpression{:});
    
    % add default file extension if not there
    filename = regexprep(filename,'(/.+)(?!\.mat)$','$1.mat');
    
    
    obj.dataFolderInfo.saveFile = filename;
end