classdef (SharedTestFixtures = { ...
            matlab.unittest.fixtures.PathFixture(subsref(strsplit(mfilename('fullpath'),'/+'),substruct('{}',{':'})))
        }) poolInfo_test < matlab.unittest.TestCase
    
% run and stop if verification fails:
%     tests     = matlab.unittest.TestSuite.fromClass(?Tests.DataKit.Metadata.poolInfo.poolInfo_test);
%     runner    = matlab.unittest.TestRunner.withTextOutput;
%     runner.addPlugin(matlab.unittest.plugins.StopOnFailuresPlugin);
%     runner.run(tests)
% run:
%     tests     = matlab.unittest.TestSuite.fromClass(?Tests.DataKit.Metadata.poolInfo.poolInfo_test);
%     run(tests)
    
    properties
        PropertyNames = {'Variable','VariableRaw','VariableDescription','VariableMeasuringDevice','VariableOffset','VariableFactor','VariableOrigin','VariableCalibrationFunction','VariableType'}
    end
    properties (MethodSetupParameter)
        
        
    end
    properties (TestParameter)
        % Selectively only input some of the inputs
        UseType                 = struct('yes',true,'no',false)
        UseCalibrationFunction	= struct('yes',true,'no',false)
        UseDescription          = struct('yes',true,'no',false)
        UseMeasuringDevice      = struct('yes',true,'no',false)
        
        % Input data in scalar (S), horizontal/wide vector (H),
        % vertical/tall vector (V) and matrix (M) shape.
        Data	= struct(...
            'S',         	struct('Variable',              {{'Oxygen'}},...
                                   'Type',                  {{'Dependent'}},...
                                   'CalibrationFunction',  	{{@(x) 2*x}},...
                                   'Description',           {{'This is the description.'}},...
                                   'MeasuringDevice',      	{{GearKit.measuringDevice}}),...
            'H',        	struct('Variable',              {{'Oxygen','Nitrate','Time'}},...
                                   'Type',                  {{'Dependent','Dependent','Independent'}},...
                                   'CalibrationFunction',  	{{@(x) 2*x,@(x) x,@(x) 0.5./x}},...
                                   'Description',           {{'This is the description A.','This is the description B.','This is the description C.'}},...
                                   'MeasuringDevice',      	{{repmat(GearKit.measuringDevice,1,3)}}),...
            'V',        	struct('Variable',              {{'Oxygen','Nitrate','Time'}'},...
                                   'Type',                  {{'Dependent','Dependent','Independent'}'},...
                                   'CalibrationFunction',  	{{@(x) 2*x,@(x) x,@(x) 0.5./x}'},...
                                   'Description',           {{'This is the description A.','This is the description B.','This is the description C.'}'},...
                                   'MeasuringDevice',      	{{repmat(GearKit.measuringDevice,3,1)}}),...
            'M',            struct('Variable',              {{'Oxygen','Nitrate';'Time','Temperature'}},...
                                   'Type',                  {{'Dependent','Dependent';'Independent','Dependent'}'},...
                                   'CalibrationFunction',  	{{@(x) 2*x,@(x) x;@(x) 0.5./x,@(x) x}'},...
                                   'Description',           {{'This is the description A.','This is the description B.';'This is the description C.','This is the description D.'}'},...
                                   'MeasuringDevice',      	{{repmat(GearKit.measuringDevice,2,2)}}))
                                           
        TypeType	= struct(...
            'char',     'Dependent',...
            'cell',     {'Dependent'},...
            'enum',     DataKit.Metadata.validators.validInfoVariableType.Dependent)
        TypeVariable	= struct(...
            'char',     'Oxygen',...
            'cell',     {'Oxygen'},...
            'enum',     DataKit.Metadata.variable.Oxygen)
        TypeCalibrationFunction	= struct(...
            'native',   @(x) x)
        TypeDescription	= struct(...
            'char',     'Text',...
            'cell',     {'Text'})
        TypeMeasuringDevice	= struct(...
            'native',   GearKit.measuringDevice())
    end
    
    methods (TestClassSetup)
        
    end
    methods (TestMethodSetup)
        
    end
    methods (TestMethodTeardown)
        
    end
    
    methods (Test)
        function testEmpty(testCase)
        % Test the constructor method with the .empty method
            import DataKit.Metadata.poolInfo
            
            act     = poolInfo.empty;
            testCase.verifyEmpty(act)
        end
        function testNoArgument(testCase)
        % Test the constructor method with no input arguments
        
            import DataKit.Metadata.poolInfo
            
            act     = poolInfo();
            for prop = 1:numel(testCase.PropertyNames)
                testCase.verifyEmpty(act.(testCase.PropertyNames{prop}))
            end
        end
        function testPoolInfo(testCase,UseType,UseCalibrationFunction,UseDescription,UseMeasuringDevice,Data)
        % Test the constructor method with all input combinations
        
            import DataKit.Metadata.poolInfo
            
            parent  = 0;
            inputArguments = {parent,Data.Variable};
            if UseType
                inputArguments  = cat(2,inputArguments,'VariableType',{Data.Type});
                expType         = reshape(Data.Type,1,[]);
            else
                expType         = repmat({'undefined'},1,numel(Data.Variable));
            end
            if UseCalibrationFunction
                inputArguments  = cat(2,inputArguments,'VariableCalibrationFunction',{Data.CalibrationFunction});
                expCalibrationFunction  = reshape(Data.CalibrationFunction,1,[]);
            else
                expCalibrationFunction 	= repmat({@(x) x},1,numel(Data.Variable));
            end
            if UseDescription
                inputArguments  = cat(2,inputArguments,'VariableDescription',{Data.Description});
                expDescription  = reshape(Data.Description,1,[]);
            else
                expDescription 	= repmat({''},1,numel(Data.Variable));
            end
            if UseMeasuringDevice
                inputArguments  = cat(2,inputArguments,'VariableMeasuringDevice',Data.MeasuringDevice);
                expMeasuringDevice = reshape(Data.MeasuringDevice{:},1,[]);
            else
                expMeasuringDevice = repmat(GearKit.measuringDevice(),1,numel(Data.Variable));                
            end
            
            act     = poolInfo(inputArguments{:});
            
            % Test variable type
            testCase.verifyEqual(act.VariableType,DataKit.Metadata.validators.validInfoVariableType(expType))
            
            % Test variable calibration function
            testCase.verifyTrue(all(cellfun(@(fhA,fhB) strcmp(func2str(fhA),func2str(fhB)),act.VariableCalibrationFunction,expCalibrationFunction)));
            
            % Test variable description
            testCase.verifyEqual(act.VariableDescription,expDescription)
            
            % Test variable measuring device
            testCase.verifyEqual(act.VariableMeasuringDevice,expMeasuringDevice)
        end
        function testInputArgumentTypes(testCase,TypeType,TypeVariable,TypeCalibrationFunction,TypeDescription,TypeMeasuringDevice)
            
            import DataKit.Metadata.poolInfo
            
            act = poolInfo(0,TypeVariable,...
                'VariableType',                 TypeType,...
                'VariableCalibrationFunction',  TypeCalibrationFunction,...
                'VariableDescription',          TypeDescription,...
                'VariableMeasuringDevice',      TypeMeasuringDevice);
            
            testCase.verifyClass(act,'DataKit.Metadata.poolInfo')
        end
	end
end