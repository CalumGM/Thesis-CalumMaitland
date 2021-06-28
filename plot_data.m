line = zeros(1, 10);
fileID = serial('COM7','BaudRate',57600);
fopen(fileID);
readPacket = false;
time = 0;
timestep = 1/512;

figure(1);
xlabel("Time (ms)")
ylabel("Amplitude (mV)")
title("Raw EEG Plot")
hold on
while true
    firstChar = readByte(fileID);
    if (firstChar == 170)
        secondChar = readByte(fileID);
        if (secondChar == 170)
            readPacket = true;
            % after AA AA is read in sequence
            payloadSize = readByte(fileID);
            eight_zero = readByte(fileID);
            zero_two = readByte(fileID);
            high = readByte(fileID); 
            low = readByte(fileID);
            checksum = readByte(fileID);
        end
    end
    if (readPacket)
        break;
    end    
end


fclose(fileID);
disp('Data Recieved')
fprintf('%i %i %i %i %i %i %i %i\n', firstChar, secondChar, payloadSize, eight_zero, zero_two, high, low, checksum);

generatedChecksum = 255 - (eight_zero + zero_two + high + low);
if (checksum == generatedChecksum)
    fprintf("Checksum passed: %i = %i\n", generatedChecksum, checksum)
else 
    fprintf("Checksum failed: %i != %i\n", generatedChecksum, checksum)
end


raw = (high*256)+low;
if (raw >= 32768)
    raw = raw - 65536; % 2's compliment
end
fprintf('Raw Value: %i\n', raw)


function [myByte] = readByte(fileID)
    myByte = fread(fileID, 1, 'uint8');
end
