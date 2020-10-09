function s = plus(obj1,obj2)
    if strcmp(obj1.id,obj2.id) && strcmp(obj1.serialNumber,obj2.serialNumber)
        [~,sInd]	= sort(cat(1,obj1.time,obj2.time));
        s           = cat(1,obj1.data,obj2.data);
        s           = s(sInd,:);
    else
        error('GearKit:sensor:plus:nonIdenticalSensor',...
            'Addition is only defined for sensors with the same id and serial number.')
    end
end