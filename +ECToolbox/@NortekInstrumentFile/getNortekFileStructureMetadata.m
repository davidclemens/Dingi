function meta = getNortekFileStructureMetadata()
% GETNORTEKFILESTRUCTUREMETADATA Returns metadata on Nortek binary files
% Returns metadata on Nortek binary files.
%
% Syntax
%   meta = GETNORTEKFILESTRUCTUREMETADATA()
%
% Description
%   meta = GETNORTEKFILESTRUCTUREMETADATA() returns metadata on Nortek
%       binary files.
%
%
% Example(s) 
%
%
% Input Arguments
%
%
% Name-Value Pair Arguments
%
% 
% See also
%
% Copyright (c) 2020-2021 David Clemens (dclemens@geomar.de)

    metaTVarN   = {'Id',    'IdHex',	'SizeWords',    'SizeBytes',	'HasSizeInfoInData',	'Type',                     'Name'};
    metaT       = {NaN,     '05',       NaN,            48,             true,                   'generic',                  'Hardware Configuration';...
                   NaN,     '04',       NaN,            224,            true,                   'generic',                  'Head Configuration';...
                   NaN,     '00',       NaN,            512,            true,                   'generic',                  'User Configureation';...
                   NaN,     '01',       NaN,            42,             true,                   'Aquadopp',                 'Aquadopp Velocity Data';...
                   NaN,     '06',       NaN,            36,             true,                   'Aquadopp',                 'Aquadopp Diagnostics Header';...
                   NaN,     '80',       NaN,            42,             true,                   'Aquadopp',                 'Aquadopp Diagnostics Data';...
                   NaN,     '12',       NaN,            42,             true,                   'Vector',                   'Vector Velocity Data Header';...
                   NaN,     '10',       NaN,            24,             false,                  'Vector',                   'Vector Velocity Data';...
                   NaN,     '11',       NaN,            28,             true,                   'Vector',                   'Vector System Data';...
                   NaN,     '07',       NaN,            910,            true,                   'Vector',                   'Vector Probe Check Data';...
                   NaN,     '07',       NaN,            2010,           true,                   'Vectrino',                 'Vectrino Probe Check Data';...
                   NaN,     '71',       NaN,            72,             true,                   'Vector',                   'Vector IMU Data';...
                   NaN,     '21',       NaN,            NaN,            true,                   'Aquadopp Profiler',        'Aquadopp Profiler Velocity Data';...
                   NaN,     '31',       NaN,            60,             true,                   'Aquadopp Profiler',        'Aquadopp Profiler Wave Burst Data Header';...
                   NaN,     '30',       NaN,            24,             true,                   'Aquadopp Profiler',        'Aquadopp Profiler Wave Burst Data';...
                   NaN,     '2A',       NaN,            NaN,            true,                   'HR Aquadopp Profiler',     'High Resolution Aquadopp Profiler Data';...
                   NaN,     '20',       NaN,            NaN,            true,                   'AWAC',                     'AWAC Velocity Profile Data';...
                   NaN,     '31',       NaN,            60,             true,                   'AWAC',                     'AWAC Wave Data Header';...
                   NaN,     '42',       NaN,            NaN,            true,                   'AWAC',                     'AWAC Stage Data';...
                   NaN,     '30',       NaN,            24,             true,                   'AWAC',                     'AWAC Wave Data';...
                   NaN,     '36',       NaN,            24,             false,                  'AWAC',                     'AWAC Wave Data for SUV'...
                  };
    meta    = cell2table(metaT,...
                'VariableNames',    metaTVarN);
    meta{:,'Id'}        = uint8(hex2dec(meta{:,'IdHex'}));
    meta{:,'SizeWords'}	= meta{:,'SizeBytes'}./2;
    meta.Type           = categorical(meta.Type);

%     continentalIds  = 36;
%     continentalSize = NaN; % NaN means variable
% 
%     aquadoppVelocityIds  = [ 1;  6; 128];
%     aquadoppVelocitySize = [42; 36;  42];
% 
%     aquadoppProfilerIds  = [ 33; 48; 49;  42];
%     aquadoppProfilerSize = [NaN; 24; 60; NaN];
% 
%     awacIds  = [ 32; 54;  66];
%     awacSize = [NaN; 24; NaN];
% 
%     prologIds  = [96; 97;  98;  99; 101; 106];
%     prologSize = [80; 48; NaN; NaN; NaN; NaN]; % Wave fourier coefficient spectrum (id99) is actually not fixed length of 816!
% 
%     %
%     % Nortek Vector with IMU (ids 113) not handled yet
%     vectorIds = [18; 16; 17; 7; 113];
%     vectorSize = [42; NaN; 28; NaN; NaN];
% 
%     knownIds   = [genericIds;  continentalIds;  aquadoppVelocityIds;  aquadoppProfilerIds;  awacIds;  prologIds; vectorIds];
%     knownSizes = [genericSize; continentalSize; aquadoppVelocitySize; aquadoppProfilerSize; awacSize; prologSize; vectorSize];
% 
%     noSizeIds  = [16; 54; 81]; % a few sectors do not include their size in their data
%     noSizeSize = [24; 24; 22]; % yet for these sectors the size is known
end