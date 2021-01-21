
import matlab.unittest.TestSuite
import matlab.unittest.TestRunner
import matlab.unittest.plugins.CodeCoveragePlugin
import matlab.unittest.plugins.codecoverage.CoberturaFormat

ignorePackages    = {'Tests'};

try
    % Determine packages
    tmp         = dir();
    names       = {tmp.name}';
    packages    = regexp(names,'^\+([A-Za-z]+$)','tokens');
    packages    = cat(1,packages{:});
    packages    = cat(1,packages{:});
    packages    = packages(~ismember(packages,ignorePackages));

    tests   = TestSuite.fromPackage('Tests',...
                'IncludingSubpackages', true);
    runner	= TestRunner.withTextOutput;
    coberturaFilename = 'cobertura.xml';
    plugin 	= CodeCoveragePlugin.forPackage(packages,...
                'Producing',            CoberturaFormat(coberturaFilename));

    runner.addPlugin(plugin)
    result  = runner.run(tests);
    
    display(result);
    fixCoberturaFile(coberturaFilename)
catch ME
    disp(getReport(ME,'extended'));
    exit(1);
end
exit(any([result.Failed]));

function fixCoberturaFile(filename)

    fileId      = fopen(filename,'r+');
    rawText     = textscan(fileId,'%s','EndOfLine','','Delimiter','');
    lengthBefore    = numel(rawText{1}{:});
    fixedText       = strrep(rawText{1},'/</source>','</source>');
    lengthAfter     = numel(fixedText{1});
    lengthDiff      = lengthAfter - lengthBefore;
    if lengthDiff ~= -1
        warning('Tests:runTestsRemotely:fixCoberturaFile:invalidFileChange',...
            'Invalid change of characters detected. Detected %i, expected -1.',lengthDiff)
    end
    frewind(fileId);
    fprintf(fileId,'%s',fixedText{1});
    fclose(fileId);
end