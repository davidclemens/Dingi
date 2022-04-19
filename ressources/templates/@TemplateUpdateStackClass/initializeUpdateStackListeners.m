function initializeUpdateStackListeners(obj,props,eventType)
% initializeUpdateStackListeners  Initialize event listeners
%   INITIALIZEUPDATESTACKLISTENERS initializes event listeners that influence
%   the update stack

    nProps = numel(props);
    for pp = 1:nProps
       addlistener(obj,props{pp},eventType{pp},@TemplateUpdateStackClass.handleUpdateStackListenerEvents);
    end
end
