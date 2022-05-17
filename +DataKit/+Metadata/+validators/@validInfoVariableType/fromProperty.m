function obj = fromProperty(propertyname,value)

    import DataKit.enum.core_fromProperty
    
    classname = mfilename('class');
    
    obj = core_fromProperty(classname,propertyname,value);
end