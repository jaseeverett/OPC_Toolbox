clear
close all

s=serial('/dev/ttyUSB1');

% To connect the serial port object to the serial port:
fopen(s)

% s.RecordDetail = 'verbose';
s.RecordName = 'MySerialFile.txt';
record(s,'on')
meas = fscanf(s,'ubit4')


% To query the device.
% fprintf(s, '*IDN?');
% idn = fscanf(s);

% To disconnect the serial port object from the serial port.
fclose(s);
