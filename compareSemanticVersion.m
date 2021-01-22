function r = compareSemanticVersion(verA,verB)
% compareSemanticVersion  Compares two semantic version strings
%   COMPARESEMANTICVERSION compares semantic version string verA and verB
%   and returns r = 0 if they are equal, r = -1 if verA < verB and r = 1 if
%   verA > verB.
%
%   Syntax
%     r = COMPARESEMANTICVERSION(verA,verB)
%
%   Description
%     r = COMPARESEMANTICVERSION(verA,verB) compares version verA and
%       version verB and returns r = 0 if they are equal, r = -1 if verA <
%       verB and r = 1 if verA > verB.
%
%   Example(s)
%     r = COMPARESEMANTICVERSION('1.3.2','1.3.2.0') returns r = 0
%     r = COMPARESEMANTICVERSION('0.3.2','1') returns r = -1
%     r = COMPARESEMANTICVERSION('2.34.0','2.33.9') returns r = 1
%
%
%   Input Arguments
%     [varA,verB] - semantic version string
%       char
%         Semantic version strings to be compared specified as numeric
%         characters seperated by dots.
%
%
%   Output Arguments
%     r - comparison result
%       -1 | 0 | 1
%         Result of the comparison: r = 0 if they are equal, r = -1 if
%         verA < verB and r = 1 if verA > verB.
%
%
%   Name-Value Pair Arguments
%
%
%   See also <a href="https://semver.org">Symanitic versioning website</a>
%
%   Copyright (c) 2021 David Clemens (dclemens@geomar.de)
%

    if ~ischar(verA) || ~ischar(verB)
        error('compareSemanticVersion:invalidInputType',...
            'Inputs need to be char.')
    end
    
    verANum     = versionstring2versionnumber(verA);
    verBNum     = versionstring2versionnumber(verB);
    
    nA          = numel(verANum);
    nB          = numel(verBNum);
    nCompare    = max([nA,nB]);
    if nA < nCompare
        d = nCompare - nA;
        verANum = cat(2,verANum,zeros(1,d));
    end
    if nB < nCompare
        d = nCompare - nB;
        verBNum = cat(2,verBNum,zeros(1,d));
    end
    
    AstB = sum(2.^(nCompare - 1:-1:0).*(verANum(1:nCompare) < verBNum(1:nCompare)));
    AgtB = sum(2.^(nCompare - 1:-1:0).*(verANum(1:nCompare) > verBNum(1:nCompare)));
    
    if AstB > AgtB
        r = -1;
    elseif AstB < AgtB
        r = 1;
    else
        r = 0;
    end
    
    function ver = versionstring2versionnumber(s)
        v = strsplit(s,'.');
        v2  = repmat({'0'},1,3*numel(v));
        b = cellfun(@(str) strsplit(str,{'b','-b','beta','-beta'}),v,'un',0);
        a = cellfun(@(str) strsplit(str,{'a','-a','alpha','-alpha'}),v,'un',0);
        for ii = 1:numel(v)
            if numel(b{ii}) > 1 && numel(a{ii}) > 1
                error('compareSemanticVersion:invalidVersionString',...
                    'Only 1 sublevel (alpha/beta) per level allowed.')
            elseif numel(b{ii}) > 1
                v2(3*(ii - 1) + 1) 	= b{ii}(1);
                v2(3*(ii - 1) + 2)  = b{ii}(2);
            elseif numel(a{ii}) > 1
                v2(3*(ii - 1) + 1) 	= a{ii}(1);
                v2(3*(ii - 1) + 3)  = a{ii}(2);
            else
                v2(3*(ii - 1) + 1)  = v(ii);
            end
        end
        ver = str2double(v2);
    end
end