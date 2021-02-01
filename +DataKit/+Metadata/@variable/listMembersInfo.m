function tbl = listMembersInfo()
    
    import DataKit.enum.core_listMembersInfo
    
    classname   = mfilename('class');
    tbl         = core_listMembersInfo(classname);
end