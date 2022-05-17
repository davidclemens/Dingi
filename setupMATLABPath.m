function setupMATLABPath()
% setupMATLABPath  Adds Dingi to the MATLAB path
%   SETUPMATLABPATH adds Dingi to the MATLAB path.
%
%   Syntax
%     SETUPMATLABPATH
%
%   Description
%     SETUPMATLABPATH adds Dingi to the MATLAB path
%
%   Example(s)
%     SETUPMATLABPATH
%
%
%   Input Arguments
%
%
%   Output Arguments
%
%
%   Name-Value Pair Arguments
%
%
%   See also ADDPATH, SAVEPATH
%
%   Copyright (c) 2021-2022 David Clemens (dclemens@geomar.de)
%

    % Get the path to this script and cd to it
    scriptPath      = fileparts(mfilename('fullpath'));
    originalPath    = cd(scriptPath);
    
    % Add relevant paths to MATLABs search path
    addpath(scriptPath);
    savepath;
    
    % Change back to original path
    cd(originalPath);
end
