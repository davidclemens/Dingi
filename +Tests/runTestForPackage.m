function result = runTestForPackage(package,varargin)

    import internal.stats.parseArgs
    import matlab.unittest.TestSuite
    import matlab.unittest.TestRunner
    import matlab.unittest.plugins.CodeCoveragePlugin
    import matlab.unittest.plugins.codecoverage.ProfileReport
    import matlab.unittest.plugins.codecoverage.CoberturaFormat

    % parse Name-Value pairs
    optionName          = {'StopOnFailure','AnalyzeTestCoverage'}; % valid options (Name)
    optionDefaultValue  = {false,false}; % default value (Value)
    [stopOnFailure,...
     analyzeTestCoverage ...
     ]     	= parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments

    if ischar(package)
        package = cellstr(package);
    elseif iscellstr(package)
    else
        error('Dingi:Tests:runTestForPackage:invalidInputType',...
            '''package'' must either be a char or cellstr.')
    end
    
    nPackages       = numel(package);
    
    toolboxInfo     = what('Dingi');
    toolboxInfo     = toolboxInfo.path;
    
    for pp = 1:nPackages
        testPath        = ['Tests.',package{pp}];
        tmp             = strrep(package{pp},'.',[filesep,'+']);
        tmp             = regexprep(tmp,[filesep,'\+([^',filesep,']+)$'],[filesep,'\@$1']);
        packagePath     = [toolboxInfo,[filesep,'+'],tmp];

        suite           = TestSuite.fromPackage(testPath,...
                            'IncludingSubpackages',	true);
        runner          = TestRunner.withTextOutput;
        
        if stopOnFailure
            runner.addPlugin(StopOnFailuresPlugin)
        end
        if analyzeTestCoverage
            plugin          = CodeCoveragePlugin.forFolder(packagePath,...
                                'Producing',            ProfileReport);
            runner.addPlugin(plugin)
        end
        result  = runner.run(suite);
    end
end
