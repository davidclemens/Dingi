function runTestsLocally(varargin)
% runTestsLocally  Run all available tests locally
%   RUNTESTSLOCALLY Finds all unit tests and runs them locally with several
%   options.
%
%   Syntax
%     RUNTESTSLOCALLY
%     RUNTESTSLOCALLY(__,Name,Value)
%
%   Description
%     RUNTESTSLOCALLY  runs all unit tests locally with default options.
%     RUNTESTSLOCALLY(__,Name,Value)  specifies additional properties using
%       one or more Name,Value pair arguments.
%
%   Example(s)
%     RUNTESTSLOCALLY
%     RUNTESTSLOCALLY('StopOnFailure',true)
%
%
%   Input Arguments
%
%
%   Output Arguments
%
%
%   Name-Value Pair Arguments
%     StopOnFailure - Stops test execution upon a failure
%       false (default) | true
%         Stops test execution upon a vailed test or an execution
%         exception.
%
%     CreateReport - Create a test report
%       true (default) | false
%         Create a .pdf report in '+Tests/reports/' with the test results.
%
%     AnalyzeTestCoverage - Analyze test coverage
%       false (default) | true
%         Analyzes test coverage and outputs it either in the MATLAB
%         Profiler (default) or as .xml Cobertura file, depending on the
%         'TestCoverageFormat' Name-Value Pair. If a coverage report is
%         generated, it is placed in '+Tests/coverage/'.
%
%     TestCoverageFormat - Set the test coverage report format
%       'Profiler' (default) | 'Cobertura'
%         Set the test coverage format. Available formats are:
%           - Profiler              MATLAB Profiler
%           - Cobertura             .xml Cobertura file
%
%
%   See also RUNTESTFORPACKAGE
%
%   Copyright (c) 2021-2022 David Clemens (dclemens@geomar.de)
%

    import internal.stats.parseArgs
    import matlab.unittest.TestSuite
    import matlab.unittest.TestRunner
    import matlab.unittest.plugins.CodeCoveragePlugin
    import matlab.unittest.plugins.codecoverage.ProfileReport
    import matlab.unittest.plugins.codecoverage.CoberturaFormat
    import matlab.unittest.plugins.StopOnFailuresPlugin
    import matlab.unittest.plugins.TestReportPlugin
    
    % parse Name-Value pairs
    optionName          = {'CreateReport','StopOnFailure','AnalyzeTestCoverage','TestCoverageFormat'}; % valid options (Name)
    optionDefaultValue  = {true,false,false,'Profiler'}; % default value (Value)
    [createReport,...
     stopOnFailure,...
     analyzeTestCoverage,...
     testCoverageFormat ...
     ]     	= parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments

    ignorePackages    = {'Tests'};

    % Determine packages
    toolboxInfo = what('Dingi');
    packages    = toolboxInfo.packages;
    packages    = packages(~ismember(packages,ignorePackages));

    tests       = TestSuite.fromPackage('Tests',...
                    'IncludingSubpackages', true);

    runner   	= TestRunner.withTextOutput;
    
    resultsfolder   = [fileparts(mfilename('fullpath')),'/'];
    filename        = [datestr(datetime('now'),'yyyymmddHHMMSS'),'_fullTest_'];
    
    if createReport
        reportFile     = [resultsfolder,'reports/',filename,'report.pdf'];
        plugin = TestReportPlugin.producingPDF(...
            reportFile,...
            'IncludingPassingDiagnostics',  true,...
            'PageOrientation',              'portrait',...
            'IncludingCommandWindowText',   false);
        runner.addPlugin(plugin);
    end
    
    if stopOnFailure
        runner.addPlugin(StopOnFailuresPlugin)
    end
    
    if analyzeTestCoverage
        switch testCoverageFormat
            case 'Profiler'
                plugin	= CodeCoveragePlugin.forPackage(packages,...
                        	'Producing',	ProfileReport);
            case 'Cobertura'
                plugin	= CodeCoveragePlugin.forPackage(packages,...
                           	'Producing',  	CoberturaFormat([resultsfolder,'coverage/',filename,'coverage_cobertura.xml']));
            otherwise
                error('Dingi:Tests:runTestsLocally:invalidTestCoverageFormat',...
                    'The requested test coverage format ''%s'' is invalid.',testCoverageFormat)
        end
        runner.addPlugin(plugin)
    end

    result  = runner.run(tests);

    display(result);
end