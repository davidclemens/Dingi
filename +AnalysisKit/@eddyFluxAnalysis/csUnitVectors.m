function [i,j,k] = csUnitVectors(obj)
% CSUNITVECTORS

    import AnalysisKit.eddyFluxAnalysis.csPlanarFitUnitVectorK
    import AnalysisKit.eddyFluxAnalysis.csPlanarFitUnitVectorIJ
    
    switch obj.CoordinateSystemRotationMethod
        case 'none'
            i   = [1 0 0];
            j   = [0 1 0];
            k   = [0 0 1];
        case 'planar fit'            
            % find the mean velocities for each window
            velocityMean    = shiftdim(nanmean(reshape(shiftdim(cat(1,obj.VelocityDownsampled,NaN(obj.WindowPaddingLength,3)),-1),obj.WindowLength,obj.WindowN + 1,[]),1));
            
            % first find the unit vector k (Z-Axis) over all windows of the timeseries
            [k,~]   = csPlanarFitUnitVectorK(velocityMean);
            k       = repmat(k,obj.WindowN + 1,1);
            
            % now find the unit vectors i (x axis) and j (y axis) which change for each
            % window
            i       = NaN(obj.WindowN,3);
            j       = NaN(obj.WindowN,3);
            for win = 1:obj.WindowN + 1
                [i(win,:),j(win,:)]   = csPlanarFitUnitVectorIJ(velocityMean(win,:),k(win,:));
            end
        otherwise
            error('Dingi:GearKit:eddyFluxAnalysis:csUnitVectors:unknownCoordinateSystemRotationMethod',...
                'The coordinate system rotation method ''%s'' is not defined.',obj.CoordinateSystemRotationMethod)
            %{
            figure(3)
            clf
            
            stem3(i(1),i(2),i(3),'r')
            hold on
            plot3([0,i(1)],[0,i(2)],[0,i(3)],'r')
            
            stem3(j(1),j(2),j(3),'g')
            plot3([0,j(1)],[0,j(2)],[0,j(3)],'g')
            
            stem3(k(1),k(2),k(3),'b')
            plot3([0,k(1)],[0,k(2)],[0,k(3)],'b')
            
            hax                 = gca;
            hax.DataAspectRatio = ones(1,3);
  
            figure(2)
            clf
            
            data    = {velocityMovMean;velocityMean;obj.velocity};
            nData   = numel(data);
            spnx    = 1;
            spny    = nData;
            spi   	= reshape(1:spnx*spny,spnx,spny)';
            
         	n       = 10;
            func    = cell(nData,1);
            linC      = NaN(3,nData);
            
            col     = 1;
            for row = 1:spny
                dat = row;
                subplot(spny,spnx,spi(row,col),...
                    'NextPlot',     'add')
                
                    XData   = data{dat}(:,1);
                    YData   = data{dat}(:,2);
                    ZData   = data{dat}(:,3);
                    scatter3(XData,YData,ZData,...
                        'Marker',           'o',...
                        'MarkerEdgeColor',  'k')
                    hold on

                    [sXData,sYData]             = meshgrid(linspace(nanmin(XData(:)),nanmax(XData(:)),n),linspace(nanmin(YData(:)),nanmax(YData(:)),n));
                    [func{dat},linCoeff(:,dat)]	= fitLinear([XData,YData],ZData);
                    sZData                      = reshape(func{dat}([sXData(:),sYData(:)]),n,n);

                    surf(sXData,sYData,sZData,...
                        'EdgeColor',        'k',...
                        'FaceColor',        'none')

                    axis image
                    xlabel('u')
                    ylabel('v')
                    zlabel('w')
                    view(3)
            end
            %}
    end
end