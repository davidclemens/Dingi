classdef (SharedTestFixtures = { matlab.unittest.fixtures.PathFixture(subsref(strsplit(mfilename('fullpath'),'/+'),substruct('{}',{':'}))) }) calculateFluxes_test < matlab.unittest.TestCase
	% calculateFluxes_test  Tests bigoFluxAnalysis.calculateFluxes behaviour
    % The CALCULATEFLUXES_TEST test class tests the functionality of the
    % AnalysisKit.bigoFluxAnalysis.calculateFluxes method.
    %
    % Run the tests: 
    %   Run and stop if verification fails:
    %     tests     = matlab.unittest.TestSuite.fromClass(?Tests.AnalysisKit.bigoFluxAnalysis.calculateFluxes_test);
    %     runner    = matlab.unittest.TestRunner.withTextOutput;
    %     runner.addPlugin(matlab.unittest.plugins.StopOnFailuresPlugin);
    %     runner.run(tests)
    %   Run:
    %     tests     = matlab.unittest.TestSuite.fromClass(?Tests.AnalysisKit.bigoFluxAnalysis.calculateFluxes_test);
    %     run(tests)
    
    properties
        BigoFluxAnalysisInstance
        FluxParameter = {'Oxygen'};
        ExpectedRate
        ExpectedFlux struct
        Tolerance = 1e-6
    end
    properties (MethodSetupParameter)
        
    end
    properties (TestParameter)
        TimeUnit = {'h','d'};
    end
    
    methods (TestClassSetup)
        function createBigoFluxAnalysisInstance(testCase)
            
            import AnalysisKit.bigoFluxAnalysis
            import GearKit.hardwareConfiguration
            
            bigoDeployment = GearKit.bigoDeployment;
            
            % Create sample data and add it to the deployment
            sampleData  = [60^2.*linspace(1,36,8);linspace(295,50,8)]';
            bigoDeployment.data.addVariable({'Time','Oxygen'},sampleData,...
                'VariableType',             {'Indep','Dep'},...
                'VariableMeasuringDevice', 	repmat(GearKit.measuringDevice('BigoOptode','01','','BenthicWaterColumn','Chamber1'),1,2),...
                'VariableOrigin',           {datetime(2022,01,01,12,00,00),0});
            
            sampleData  = [60^2.*linspace(2,37,8);linspace(295,50,8)]';
            bigoDeployment.data.addVariable({'Time','Oxygen'},sampleData,...
                'VariableType',             {'Indep','Dep'},...
                'VariableMeasuringDevice', 	repmat(GearKit.measuringDevice('BigoOptode','02','','BenthicWaterColumn','Chamber2'),1,2),...
                'VariableOrigin',           {datetime(2022,01,01,12,00,00),0});
            
            bigoDeployment.HardwareConfiguration   = hardwareConfiguration(bigoDeployment);
            
            % Create sample chamber metadata
            chamberArea       	= pi.*([29;29]./2.*1e-2).^2; % m^2
            chamberHeight       = nanmean([1;1].*10e-1./chamberArea,2); % cm
            chamberData         = table();
            chamberData.DeviceDomain            = GearKit.deviceDomain.fromProperty('Abbreviation',{'Ch1';'Ch2'});
            chamberData.Height                  = chamberHeight;
            chamberData.Area                    = chamberArea;
            chamberData.VolumeViaHeight         = chamberArea.*1e2.*chamberHeight.*1e-1;
            chamberData.VolumeViaConductivity	= NaN(2,1);
            chamberData.VolumeMethod            = repmat({'ViaHeight'},2,1);
            chamberData.ExperimentStart         = repmat(datetime(2022,01,01,12,00,00),2,1);
            chamberData.ExperimentEnd           = repmat(datetime(2022,01,03,15,00,00),2,1);
            bigoDeployment.HardwareConfiguration.DeviceDomainMetadata	= chamberData;
            
            
            % Expected values
            testCase.ExpectedRate       = -7; % µM/h
            testCase.ExpectedFlux(1).h     = testCase.ExpectedRate.*chamberData.VolumeViaHeight./chamberData.Area.*1e-3; % mmol/(h*m2)
            testCase.ExpectedFlux(1).d     = testCase.ExpectedFlux.h.*24; % mmol/(d*m2)
            
            testCase.BigoFluxAnalysisInstance = bigoFluxAnalysis(bigoDeployment,...
                'FitInterval',          hours([0,37]));
        end
    end
    methods (TestMethodSetup)
        
    end
    methods (TestMethodTeardown)
    end
    
    methods (Test)
        function testFluxValue(testCase,TimeUnit)
            testCase.BigoFluxAnalysisInstance.TimeUnit = TimeUnit;
            act = testCase.BigoFluxAnalysisInstance.FluxStatistics(:,1);
            exp = testCase.ExpectedFlux.(TimeUnit);
            testCase.verifyTrue(all(exp - act < testCase.Tolerance));
        end
	end
end