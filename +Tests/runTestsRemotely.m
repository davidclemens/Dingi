
import matlab.unittest.TestSuite

try
    tests   = TestSuite.fromPackage('Tests',...
                'IncludingSubpackages', true);
    result  = run(tests);
    display(result);
catch ME
    disp(getReport(ME,'extended'));
    exit(1);
end
exit(any([result.Failed]));
