clear

import matlab.unittest.TestSuite
import matlab.unittest.TestRunner
import matlab.unittest.plugins.CodeCoveragePlugin
import matlab.unittest.plugins.codecoverage.ProfileReport
import matlab.unittest.plugins.codecoverage.CoberturaFormat

ignorePackages    = {'Tests'};

% Determine packages
tmp         = dir();
names       = {tmp.name}';
packages    = regexp(names,'^\+([A-Za-z]+$)','tokens');
packages    = cat(1,packages{:});
packages    = cat(1,packages{:});
packages    = packages(~ismember(packages,ignorePackages));
    
tests       = TestSuite.fromPackage('Tests',...
                'IncludingSubpackages', true);
            
            
coveragePath    = [tests(1).BaseFolder,'/+Tests/coverage/'];
runner          = TestRunner.withTextOutput;
% pluginA         = CodeCoveragePlugin.forPackage(packages,...
%                     'Producing',            ProfileReport);
% pluginB         = CodeCoveragePlugin.forPackage(packages,...
%                     'Producing',            CoberturaFormat([coveragePath,'cobertura.xml']));
        
% runner.addPlugin(pluginA)
% runner.addPlugin(pluginB)
result  = runner.run(tests);

display(result);
