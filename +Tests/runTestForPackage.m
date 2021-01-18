function result = runTestForPackage(package)

    import matlab.unittest.TestSuite
    import matlab.unittest.TestRunner
    import matlab.unittest.plugins.CodeCoveragePlugin
    import matlab.unittest.plugins.codecoverage.ProfileReport
    import matlab.unittest.plugins.codecoverage.CoberturaFormat

    if ischar(package)
        package = cellstr(package);
    elseif iscellstr(package)
    else
        error('Tests:runTestForPackage:invalidInputType',...
            '''package'' must either be a char or cellstr.')
    end
    
    nPackages       = numel(package);
    
    for pp = 1:nPackages
        testPath        = ['Tests.',package{pp}];

        suite           = TestSuite.fromPackage(testPath,...
                            'IncludingSubpackages',	true);
        runner          = TestRunner.withTextOutput;

        plugin          = CodeCoveragePlugin.forPackage(package{pp},...
                            'Producing',            ProfileReport);

        runner.addPlugin(plugin)
        result  = runner.run(suite);
    end
end
