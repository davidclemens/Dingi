function runTestsLocally(varargin)

    import internal.stats.parseArgs
    import matlab.unittest.TestSuite
    import matlab.unittest.TestRunner
    import matlab.unittest.plugins.StopOnFailuresPlugin
    import matlab.unittest.plugins.CodeCoveragePlugin
    import matlab.unittest.plugins.codecoverage.ProfileReport
    import matlab.unittest.plugins.codecoverage.CoberturaFormat
    
    % parse Name-Value pairs
    optionName          = {'StopOnFailure','AnalyzeTestCoverage','TestCoverageFormat'}; % valid options (Name)
    optionDefaultValue  = {false,false,'Profiler'}; % default value (Value)
    [stopOnFailure,...
     analyzeTestCoverage,...
     testCoverageFormat ...
     ]     	= parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments

    ignorePackages    = {'Tests'};

    % Determine packages
    toolboxInfo = what('toolboxes');
    packages    = toolboxInfo.packages;
    packages    = packages(~ismember(packages,ignorePackages));

    tests       = TestSuite.fromPackage('Tests',...
                    'IncludingSubpackages', true);

    runner   	= TestRunner.withTextOutput;
    
    if stopOnFailure
        runner.addPlugin(StopOnFailuresPlugin)
    end
    
    if analyzeTestCoverage
        coveragePath    = [tests(1).BaseFolder,'/+Tests/'];
        switch testCoverageFormat
            case 'Profiler'
                plugin	= CodeCoveragePlugin.forPackage(packages,...
                        	'Producing',	ProfileReport);
            case 'Cobertura'
                plugin	= CodeCoveragePlugin.forPackage(packages,...
                           	'Producing',  	CoberturaFormat([coveragePath,'cobertura.xml']));
            otherwise
                error('Tests:runTestsLocally:invalidTestCoverageFormat',...
                    'The requested test coverage format ''%s'' is invalid.',testCoverageFormat)
        end
        runner.addPlugin(plugin)
    end

    result  = runner.run(tests);

    display(result);
end