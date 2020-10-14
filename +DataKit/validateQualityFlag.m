function [qualityFlagIsValid,varargout] = validateQualityFlag(qualityFlag)
% VALIDATEQUALITYFLAG
    
    nargoutchk(0,2)
    
   
    nRequestedQualityFlags	= numel(qualityFlag);
    
    
    validQualityFlags         = DataKit.importTableFile([getToolboxRessources('DataKit'),'/validQualityFlags.xlsx']);
     
    [qualityFlagIsValid,qualtiyFlagInfoIndex] = ismember(qualityFlag,validQualityFlags{:,'QualityFlag'});

    % initialize
    info(nRequestedQualityFlags + 1,:) = validQualityFlags(1,:);
    
    info(qualityFlagIsValid,:)      = validQualityFlags(qualtiyFlagInfoIndex(qualityFlagIsValid),:);
    info                            = info(1:end - 1,:);
    
    varargout{1}    = info;
end