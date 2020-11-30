clear

import matlab.unittest.TestSuite

tests   = TestSuite.fromPackage('Tests',...
          	'IncludingSubpackages', true);
result  = run(suiteFolder);

