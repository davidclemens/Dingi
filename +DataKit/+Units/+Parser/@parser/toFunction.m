function func = toFunction(obj)

    switch obj.Type
        case 'Expression'
            func = obj.Tree.eval(@DataKit.Units.Parser.parser.evalToken,obj.OperatorMap,obj.UnaryOperatorMap);
    end
end
