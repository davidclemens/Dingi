function handlePropertyChangeEvents(src,evnt)
    
    obj = evnt.AffectedObject;
    switch src.Name
        case 'Index'
            switch evnt.EventName
                case 'PreGet'
                    if obj.IndexNeedsUpdating
                        obj.updateIndex;
                    end
            end
    end
end