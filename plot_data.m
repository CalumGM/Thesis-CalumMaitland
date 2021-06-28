line = zeros(1, 10);
fileID = serial('COM6','BaudRate',57600);
fopen(fileID);
readPacket = false;
i = 0;
rawValues = zeros(1, 1000);
time = zeros(1, 1000);
figure(1);
xlabel("Time (ms)")
ylabel("Amplitude (mV)") % different Y axis
xlim([0 1000]);
% ylim([-32768 32768]);
title("Raw EEG Plot")
hold all;
for j = 1:1000
    firstChar = readByte(fileID);
    if (firstChar == 170)
        secondChar = readByte(fileID);
        if (secondChar == 170)
            % after AA AA is read in sequence
            payloadSize = readByte(fileID);
            eight_zero = readByte(fileID);
            zero_two = readByte(fileID);
            high = readByte(fileID); 
            low = readByte(fileID);
            checksum = readByte(fileID);
            
            % disp('Data Recieved')
            % fprintf('%i %i %i %i %i %i %i %i\n', firstChar, secondChar, payloadSize, eight_zero, zero_two, high, low, checksum);
            
            generatedChecksum = 255 - (eight_zero + zero_two + high + low);
            passed = (checksum == generatedChecksum);
            raw = calculateRawValue(high, low);
            
            % fprintf('Raw Value: %i\n', raw)
            if (passed)
                i = i+1;
                rawValues(i) = raw;
                time(i) = i;
                plot(i, raw, 'r-o')
                drawnow;
            end
        end
    end  
end
disp("closing file")
fclose(fileID);


function [raw] = calculateRawValue(high, low)
    raw = (high*256)+low;
    if (raw >= 32768)
        raw = raw - 65536; % 2's compliment
    end
end

%{
function [passed] = validateData(generatedChecksum, checksum)
    if (checksum == generatedChecksum)
        fprintf("Checksum passed: %i = %i\n", generatedChecksum, checksum)
    else 
        fprintf("Checksum failed: %i != %i\n", generatedChecksum, checksum)
    end
    passed = (checksum == generatedChecksum);
end
%}



function [myByte] = readByte(fileID)
    myByte = fread(fileID, 1, 'uint8');
end
