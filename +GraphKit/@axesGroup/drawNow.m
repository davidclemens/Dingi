function drawNow(obj)
% DRAWNOW
    
    obj.Parent.Visible	= 'off';
    
    
	obj = getAxesData(obj);
    
    obj = initializeAxesAppearance(obj);
    
    maxIterations = 10;
    iiter = 1;
    while obj.AxesPositionDelta >= 0.01 && iiter <= maxIterations
        % TODO: add an event listener to the obj.AxesPositionDelta property
        %       that triggers the drawNow method if the delta is above a
        %       threshold instead
        currentUnits = get(obj.Children,{'Units'});
        set(obj.Children,...
            {'Units'},          {'centimeters'},...
            {'Position'},       num2cell(obj.AxesPosition,2))
        set(obj.Children,...
            {'Units'},          currentUnits)
        drawnow limitrate
        iiter = iiter + 1;
    end
    if iiter == maxIterations + 1
        warning('Dingi:GraphKit:axesGroup:drawNow:maxIterationReached',...
            'The axesGroup layout did not converge after the maximum iterations of %g.',maxIterations)
    end
    
    obj.Parent.Visible  = 'on';
end