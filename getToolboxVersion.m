function version = getToolboxVersion()
% getToolboxVersion  Return the Dingi version number
%   GETTOOLBOXVERSION returns the Dingi semantic version number.
%
%   Syntax
%     version = GETTOOLBOXVERSION
%
%   Description
%     version = GETTOOLBOXVERSION returns the Dingi semantic version number.
%
%   Example(s)
%     version = GETTOOLBOXVERSION
%
%
%   Input Arguments
%
%
%   Output Arguments
%     version - Dingi semantic version number
%       char
%         The Dingi semantic version number. See <a href="https://semver.org">https://semver.org</a>
%         for reference.
%
%
%   Name-Value Pair Arguments
%
%
%   See also VER
%
%   Copyright (c) 2021-2022 David Clemens (dclemens@geomar.de)
%
    
    info    = ver('Dingi');
    version = info.Version;
end
