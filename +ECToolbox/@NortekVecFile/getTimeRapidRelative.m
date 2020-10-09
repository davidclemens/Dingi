function timeRapidRelative = getTimeRapidRelative(obj)
    timeRapidRelative      	= seconds(obj.timeRapid - obj.timeSlow(1));
end