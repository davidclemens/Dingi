classdef (SharedTestFixtures = { ...
            matlab.unittest.fixtures.PathFixture(subsref(strsplit(mfilename('fullpath'),'/+'),substruct('{}',{':'})))
        }) addVariable_test < matlab.unittest.TestCase
    

% run and stop if verification fails:
%     tests     = matlab.unittest.TestSuite.fromClass(?Tests.DataKit.Metadata.poolInfo.addVariable_test);
%     runner    = matlab.unittest.TestRunner.withTextOutput;
%     runner.addPlugin(matlab.unittest.plugins.StopOnFailuresPlugin);
%     runner.run(tests)
% run:
%     tests     = matlab.unittest.TestSuite.fromClass(?Tests.DataKit.Metadata.poolInfo.addVariable_test);
%     run(tests)
    
    properties
        PropertyNames = {'Variable','VariableRaw','VariableDescription','VariableMeasuringDevice','VariableOffset','VariableFactor','VariableOrigin','VariableCalibrationFunction','VariableType'}
        PoolInfoInstance
    end
    properties (MethodSetupParameter)
        
        InitialInstanceType	= struct('empty',1,'noData',2,'normal',3)
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
                     'S',               struct('Variable',              {{'Oxygen'}},...
                                               'Type',                  {{'Dependent'}},...
                                               'CalibrationFunction',  	{{@(x) 2*x}},...
                                               'Description',           {{'This is the description.'}},...
                                               'MeasuringDevice',      	{{GearKit.measuringDevice}}),...
                     'H',               struct('Variable',              {{'Oxygen','Nitrate','Time'}},...
                                               'Type',                  {{'Dependent','Dependent','Independent'}},...
                                               'CalibrationFunction',  	{{@(x) 2*x,@(x) x,@(x) 0.5./x}},...
                                               'Description',           {{'This is the description A.','This is the description B.','This is the description C.'}},...
                                               'MeasuringDevice',      	{{repmat(GearKit.measuringDevice,1,3)}}),...
                     'V',               struct('Variable',              {{'Oxygen','Nitrate','Time'}'},...
                                               'Type',                  {{'Dependent','Dependent','Independent'}'},...
                                               'CalibrationFunction',  	{{@(x) 2*x,@(x) x,@(x) 0.5./x}'},...
                                               'Description',           {{'This is the description A.','This is the description B.','This is the description C.'}'},...
                                               'MeasuringDevice',      	{{repmat(GearKit.measuringDevice,3,1)}}),...
                     'M',               struct('Variable',              {{'Oxygen','Nitrate';'Time','Temperature'}},...
                                               'Type',                  {{'Dependent','Dependent';'Independent','Dependent'}'},...
                                               'CalibrationFunction',  	{{@(x) 2*x,@(x) x;@(x) 0.5./x,@(x) x}'},...
                                               'Description',           {{'This is the description A.','This is the description B.';'This is the description C.','This is the description D.'}'},...
                                               'MeasuringDevice',      	{{repmat(GearKit.measuringDevice,2,2)}}))
    end
    
    methods (TestClassSetup)
        
    end
    methods (TestMethodSetup)
        function createPoolInfoInstance(testCase,InitialInstanceType)
            
            import DataKit.Metadata.poolInfo
            
            switch InitialInstanceType
                case 1
                    testCase.PoolInfoInstance = poolInfo.empty;
                case 2
                    testCase.PoolInfoInstance = poolInfo();
                case 3
                    testCase.PoolInfoInstance = ...
                        poolInfo(0,{'Time','Oxygen'},...
                            'VariableType',         {'Independent','Dependent'});
            end
        end        
    end
    methods (TestMethodTeardown)
        
    end
    
    methods (Test)
        function testPoolInfo(testCase,UseType,UseCalibrationFunction,UseDescription,UseMeasuringDevice,Data)
        % Test the constructor method with all input combinations
        
            import DataKit.Metadata.poolInfo
            
            inputArguments = {Data.Variable};
            if UseType
                inputArguments  = cat(2,inputArguments,'VariableType',{Data.Type});
                expType         = reshape(Data.Type,1,[]);
            else
                expType         = repmat({'undefined'},1,numel(Data.Variable));
            end
            if ~isempty(testCase.PoolInfoInstance)
                expType     = cat(2,testCase.PoolInfoInstance.VariableType,expType);
            else
                expType     = DataKit.Metadata.validators.validInfoVariableType(expType);
            end
            if UseCalibrationFunction
                inputArguments  = cat(2,inputArguments,'VariableCalibrationFunction',{Data.CalibrationFunction});
                expCalibrationFunction  = reshape(Data.CalibrationFunction,1,[]);
            else
                expCalibrationFunction 	= repmat({@(x) x},1,numel(Data.Variable));
            end
            expCalibrationFunction     = cat(2,testCase.PoolInfoInstance.VariableCalibrationFunction,expCalibrationFunction);
            if UseDescription
                inputArguments  = cat(2,inputArguments,'VariableDescription',{Data.Description});
                expDescription  = reshape(Data.Description,1,[]);
            else
                expDescription 	= repmat({''},1,numel(Data.Variable));
            end
            expDescription     = cat(2,testCase.PoolInfoInstance.VariableDescription,expDescription);
            if UseMeasuringDevice
                inputArguments  = cat(2,inputArguments,'VariableMeasuringDevice',Data.MeasuringDevice);
                expMeasuringDevice = reshape(Data.MeasuringDevice{:},1,[]);
            else
                expMeasuringDevice = repmat(GearKit.measuringDevice(),1,numel(Data.Variable));                
            end
            expMeasuringDevice     = cat(2,testCase.PoolInfoInstance.VariableMeasuringDevice,expMeasuringDevice);
            
            try
            act     = testCase.PoolInfoInstance.addVariable(inputArguments{:});
            catch ME
                
            end
            
            % Test variable type
            testCase.verifyEqual(act.VariableType,expType)
            
            % Test variable calibration function
            testCase.verifyTrue(all(cellfun(@(fhA,fhB) strcmp(func2str(fhA),func2str(fhB)),act.VariableCalibrationFunction,expCalibrationFunction)));
            
            % Test variable description
            testCase.verifyEqual(act.VariableDescription,expDescription)
            
            % Test variable measuring device
            testCase.verifyEqual(act.VariableMeasuringDevice,expMeasuringDevice)
        end
	end
end