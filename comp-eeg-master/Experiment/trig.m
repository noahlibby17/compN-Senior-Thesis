function trig(x)
% NOTE: IOPort('Write') can send char vectors or uint8. Char vectors get
% confusing when being read by Emotiv, as any num2str values are
% interpreted not as the actual number.

PortNumber = FindSerialPort('ttyUSB0');
[handle, errmsg] = IOPort('OpenSerialPort', PortNumber);

%data = num2str(x); % antiquated version from Zall's sproj script
data = uint8(x);

[nWritten, when, errmsg, prewritetime, postwritetime, lastchecktime]...
    = IOPort('Write', handle, data);
[nWritten, when, errmsg, prewritetime, postwritetime, lastchecktime]...
    = IOPort('Write', handle, data);


IOPort('Close', handle)
end