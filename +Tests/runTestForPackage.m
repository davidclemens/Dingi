function result = runTestForPackage(package,varargin)
% runTestsLocally  Run all available tests locally
%   RUNTESTFORPACKAGE Finds all unit tests and runs them locally with several
%   options.
%
%   Syntax
%     RUNTESTFORPACKAGE(package)
%     RUNTESTFORPACKAGE(__,Name,Value)
%
%   Description
%     RUNTESTFORPACKAGE(package)  runs all unit tests for package 'package'
%       locally with default options. Specify 'package' in dot notation.
%     RUNTESTFORPACKAGE(__,Name,Value)  specifies additional properties
%       using one or more Name,Value pair arguments.
%
%   Example(s)
%     RUNTESTFORPACKAGE('DataKit.dataPool')
%     RUNTESTFORPACKAGE('DataKit.dataPool','StopOnFailure',true)
%
%
%   Input Arguments
%     Package - The package for which the test should be run
%       char | cellstr
%         Specify the package(s) for which the test(s) should be run either
%         als char (single package) or cellstr (multiple packages). Each
%         package is specified in dot notation (e.g. 'DataKit.dataPool').
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
%   See also RUNTESTSLOCALLY
%
%   Copyright (c) 2021 David Clemens (dclemens@geomar.de)
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
     testCoverageFormat...
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
    
    resultsfolder   = [fileparts(mfilename('fullpath')),'/'];
    
    for pp = 1:nPackages
        testPath        = ['Tests.',package{pp}];
        tmp             = strrep(package{pp},'.',[filesep,'+']);
        tmp             = regexprep(tmp,[filesep,'\+([^',filesep,']+)$'],[filesep,'\@$1']);
        packagePath     = [toolboxInfo,[filesep,'+'],tmp];

        suite           = TestSuite.fromPackage(testPath,...
                            'IncludingSubpackages',	true);
        runner          = TestRunner.withTextOutput;
        
        filename        = [datestr(datetime('now'),'yyyymmddHHMMSS'),'_forPackageTest_'];
        
        if createReport
            reportFile     = [resultsfolder,'reports/',filename,'report_',package{pp},'.pdf'];
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
                    plugin	= CodeCoveragePlugin.forFolder(packagePath,...
                               	'Producing',  	ProfileReport);
                case 'Cobertura'
                    plugin	= CodeCoveragePlugin.forFolder(packagePath,...
                                'Producing',  	CoberturaFormat([resultsfolder,'coverage/',filename,'coverage_',package{pp},'_cobertura.xml']));
                    
                otherwise
                    error('Dingi:Tests:runTestForPackage:invalidTestCoverageFormat',...
                        'The requested test coverage format ''%s'' is invalid.',testCoverageFormat)
            end
            runner.addPlugin(plugin)
        end
        result  = runner.run(suite);
    end
end
