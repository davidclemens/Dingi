function varargout = waitForKeyPress()
%% WAITFORKEYPRESS halts the code until a keyboard key is pressed and
% optionally returns the name of the key.
%
% usage:
% KeyName = WAITFORKEYPRESS()
%
% example:
% KeyName = WAITFORKEYPRESS();
%
% (c) 2017 David Clemens
%          dclemens@geomar.de
%
% Changelog:
% - v1.00   01.02.2018	initial version. 
%
%   See also WAITFORBUTTONPRESS
%

%% FUNCTION
isKey   = false;
while ~isKey % wait until a keyboard key is pressed/ignores mouse clicks
    isKey  	= waitforbuttonpress();
end
KeyName	= get(gcf,'CurrentKey');

varargout{1}    = KeyName;

end