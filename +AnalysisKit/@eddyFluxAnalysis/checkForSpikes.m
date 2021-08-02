function checkForSpikes(obj)

    obj.despike
    
    switch obj.DespikeMethod
    	case 'none'
            % Do nothing
        otherwise
            obj.replaceData('Spike')
    end
end