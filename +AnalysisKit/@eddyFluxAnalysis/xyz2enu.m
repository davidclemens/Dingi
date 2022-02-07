function ENU = xyz2enu(XYZ,pitch,roll,heading)

    % Pitch [-90,90], roll [-90,90], heading [0,360] in degrees

    validateattributes(XYZ,{'numeric'},{'size',[NaN,3]})
    validateattributes(pitch,{'numeric'},{'scalar','>=',-90,'<=',90})
    validateattributes(roll,{'numeric'},{'scalar','>=',-90,'<=',90})
    validateattributes(heading,{'numeric'},{'scalar','>=',0,'<',360})

    pitch       = deg2rad(pitch);
    roll        = deg2rad(roll);
    yaw         = deg2rad(heading - 90);
    
    % Make yaw matrix
    Y = [ cos(yaw)       sin(yaw)        0  ; ...
         -sin(yaw)       cos(yaw)        0  ; ...
          0              0               1  ];

    % Make pitch-roll matrix
    P = [ cos(pitch)	-sin(pitch)*sin(roll)	-cos(roll)*sin(pitch)   ;...
          0              cos(roll)              -sin(roll)              ;  ...
          sin(pitch)     sin(roll)*cos(pitch)    cos(pitch)*cos(roll)   ];
    
    % Final rotation matrix
    R = Y*P;

    % Rotate coordinates
    ENU     = R*XYZ';
    ENU     = ENU';
end