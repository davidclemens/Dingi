function [qualityFlagIsValid,varargout] = validateQualityFlag(qualityFlag)
% VALIDATEQUALITYFLAG
    
    import UtilityKit.Utilities.table.readTableFile
    import UtilityKit.Utilities.toolbox.*
    
    nargoutchk(0,2)
   
    nRequestedQualityFlags	= numel(qualityFlag);
    
    validQualityFlags         = readTableFile([toolbox.ressources('DataKit'),'/validQualityFlags.xlsx']);
     
    [qualityFlagIsValid,qualtiyFlagInfoIndex] = ismember(qualityFlag,validQualityFlags{:,'QualityFlag'});

    % initialize
    info(nRequestedQualityFlags + 1,:) = validQualityFlags(1,:);
    
    info(qualityFlagIsValid,:)      = validQualityFlags(qualtiyFlagInfoIndex(qualityFlagIsValid),:);
    info                            = info(1:end - 1,:);
    
    varargout{1}    = info;
end
