function [ COM_PORT ] = FindPort()
%FINDPORT Detects Arduino COM Port
%   Uses ExtractPort.vbs to find the COM port the Arduino board is
%   connected to

devices = winqueryreg('name', 'HKEY_LOCAL_MACHINE', 'HARDWARE\DEVICEMAP\SERIALCOMM'); 
if (isempty(devices)) 
        com{1} = 'NONE'; 
else 
        com = cell(1, length(devices)); 
        for (ii = 1:length(devices)) 
                com{ii} = winqueryreg('HKEY_LOCAL_MACHINE', 'HARDWARE\DEVICEMAP\SERIALCOMM', devices{ii}); 
        end 
end 

booleanIndex = strcmp('\Device\USBSER000', devices);
ind = find(booleanIndex);

COM_PORT = com{ind};

end

