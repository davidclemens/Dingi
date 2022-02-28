function [tf,info] = validate(propertyname,value)

    import DataKit.enum.core_validate
    
    classname = mfilename('class');
    
    [tf,info] = core_validate(classname,propertyname,value);
end