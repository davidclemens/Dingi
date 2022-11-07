function tbl = measuringDevicesCalibration()

    R = {'VariableNames',       'VariableUnits',        'VariableFormatSpec',   'VariableDescriptions', };
    C = { ...
        'Cruise',               '',                     '%C',                   'Cruise id.';...
        'Gear',                 '',                     '%C',                   'Gear id.';...
        'Type',                 '',                     '%C',                   'Measuring device type. As defined in GearKit.measuringDeviceType.';...
        'SerialNumber',         '',                     '%C',                   'The serial number of the measuring device.';...
        'CalibrationTimeId',    '',                     '%u8',                  'Time point of calibration (e.g. before & after the deployment).';...
        'CalibrationStart',     'UTC',                  '%D',                   'Time of calibration start.';...
        'CalibrationEnd',       'UTC',                  '%D',                   'Time of calibration end.';...
        'SignalVariableId',     '',                     '%u16',                 'The variable reported by the sensor. As defined in DataKit.Metadata.variable.';...
        'Signal',               '',                     '%f',                   'The value reported by the sensor.';...
        'ValueVariableId',      '',                     '%u16',                 'The actual sensor variable. As defined in DataKit.Metadata.variable.';...
        'Value',                '',                     '%f',                   'The actual sensor value.';...
        'Temperature',          '°C',                   '%f',                   'Calibration temperature.';...        
        'Comment',              '',                     '%s',                   'Comments.'...
    };
    tbl = cell2table(C',...
        'VariableNames',    C(:,1)',...
        'RowNames',         R);
end