
import matlab.unittest.TestSuite
import matlab.unittest.TestRunner
import matlab.unittest.plugins.CodeCoveragePlugin
import matlab.unittest.plugins.codecoverage.CoberturaFormat

try
    tests   = TestSuite.fromPackage('Tests',...
                'IncludingSubpackages', true);
    runner	= TestRunner.withTextOutput;
    plugin 	= CodeCoveragePlugin.forPackage(package{pp},...
            	'Producing',            'cobertura.xml');
        
	runner.addPlugin(plugin)
    result  = runner.run(tests);
    
    display(result);
catch ME
    disp(getReport(ME,'extended'));
    exit(1);
end
exit(any([result.Failed]));
