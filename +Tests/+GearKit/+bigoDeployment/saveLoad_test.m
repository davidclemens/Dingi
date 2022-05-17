classdef (SharedTestFixtures = { ...
            matlab.unittest.fixtures.PathFixture(subsref(strsplit(mfilename('fullpath'),'/+'),substruct('{}',{':'})))
        }) saveLoad_test < matlab.unittest.TestCase

    % run:
    % tests = matlab.unittest.TestSuite.fromClass(?Tests.GearKit.bigoDeployment.saveLoad_test);
    % run(tests)

    properties
        GearDeploymentInstances
        GearDeploymentInstance
        TemporaryFolder
        Filenames
    end
    properties (ClassSetupParameter)
        
    end
    properties (MethodSetupParameter)
        % !!! WARNING !!!
        % These two parameters are hardcoded and need to be synced with
        % Test.GearKit.generateSampleGearDeployments
        SubclassNames = struct(...
            'bigo',     'bigoDeployment',...
            'ec',       'ecDeployment')
        
        DataSetNames = struct(...
            'IsDs_ImDs',    1,...
            'IsDs_IsDm',    2,...
            'IsDs_ImDm',    3,...
            'ImDs_IsDm',    4,...
            'ImDs_ImDm',    5,...
            'IsDm_ImDm',    6)
    end
    properties (TestParameter)
        
    end
    
    methods (TestClassSetup)
        function setDebuggerLevel(~)
            DebuggerKit.Debugger('Level','FatalError');
        end
        function createTemporaryDirectory(testCase)

            import matlab.unittest.fixtures.TemporaryFolderFixture

            testCase.TemporaryFolder = testCase.applyFixture(TemporaryFolderFixture);
        end
        function createGearDeployments(testCase)
            import Tests.GearKit.generateSampleGearDeployments
            
            gd	= generateSampleGearDeployments();
            testCase.GearDeploymentInstances = gd;
        end
    end
    methods (TestMethodSetup, ParameterCombination = 'pairwise')
        function selectDeployment(testCase,SubclassNames,DataSetNames)
            testCase.GearDeploymentInstance = testCase.GearDeploymentInstances.(SubclassNames)(DataSetNames);
        end
        function saveDeployment(testCase)
            filenames = testCase.GearDeploymentInstance.save(testCase.TemporaryFolder.Folder);

            testCase.Filenames = filenames;
        end
    end
    methods (TestMethodTeardown)

    end

    methods (Test)
        function testLoadedDeploymentContent(testCase)
            
            [~,~,ext] = fileparts(testCase.Filenames{1});
            switch ext
                case '.bigo'
                    loadedGearDeployment	= GearKit.bigoDeployment.load(testCase.Filenames{1});
                case '.ec'
                    loadedGearDeployment	= GearKit.ecDeployment.load(testCase.Filenames{1});
                otherwise
                    error('The subclass with file extension ''%s'' is not implemented yet.',ext)
            end

            metadata        = eval(['?',class(loadedGearDeployment)]);
            propertyNames   = {metadata.PropertyList.Name}';
            needsComparing  = find(~any(cat(2,cat(1,metadata.PropertyList.Transient),...
                                              cat(1,metadata.PropertyList.Constant),...
                                              cat(1,metadata.PropertyList.Dependent),...
                                              strcmp(propertyNames,'MatFile'),...
                                              strcmp(propertyNames,'LoadFile'),...
                                              strcmp(propertyNames,'SaveFile'),...
                                              strcmp(propertyNames,'DataStructureVersion')),2));
                                    
            nProperties     = numel(needsComparing);
            propertyIsEqual = false(nProperties,1);
            for ii = 1:nProperties
                propertyIsEqual(ii)     = isequal(loadedGearDeployment.(propertyNames{needsComparing(ii)}),testCase.GearDeploymentInstance.(propertyNames{needsComparing(ii)}));
                
                testCase.verifyTrue(propertyIsEqual(ii),sprintf('''%s'' is not equal.',propertyNames{ii}));
            end
        end
	end
end
