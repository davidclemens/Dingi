function timeSlowRelative = getTimeSlowRelative(obj)
    timeSlowRelative      	= seconds(obj.timeSlow - obj.timeSlow(1));
end