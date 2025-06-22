84% of storage used … If you run out of space, you can't save to Drive or use Gmail. Get 30 GB of storage for ₹59.00 ₹0 for 1 month.
% Define serial port object
s = serialport("COM5", 9600);

% Set the serial port properties
configureTerminator(s, "LF");
flush(s); % Clear the serial port buffer

% Create an array to store the data
ecgData = [];

% Set the duration for data collection in seconds
duration = 20; % Collect data for 30 seconds
startTime = datetime('now');

% Collect data for the specified duration
while seconds(datetime('now') - startTime) < duration
    if s.NumBytesAvailable > 0
        data = readline(s);
        % Debug print to check received data
        disp(['Received data: ', data]);

        % Check if data starts with the expected prefix 'ECG:'
        if startsWith(data, 'ECG:')
            % Extract ECG value from the data
            ecgValue = str2double(extractAfter(data, 'ECG:'));
            % Get the current time in seconds since the start
            elapsedTime = seconds(datetime('now') - startTime);
            % Append the data to the array
            ecgData = [ecgData; elapsedTime, ecgValue];
        else
            disp('Data format error: Prefix not found.');
        end
    end
end

% Close the serial port
clear s;

% Save data to a .mat file for later use
save('ecgData.mat', 'ecgData');

% Verify that the data has been saved correctly
if isfile('ecgData.mat')
    disp('ECG data saved successfully.');
    loadedData = load('ecgData.mat');
    ecgData = loadedData.ecgData;
    disp(['Number of samples collected: ', num2str(size(ecgData, 1))]);
else
    disp('Failed to save ECG data.');
end

% Check if data is empty before processing
if isempty(ecgData)
    disp('No ECG data to process.');
else
    % Assume sampling rate is known
    Fs = 250; % Example sampling rate in Hz

    % Convert sample indices to time
    time = ecgData(:, 1);
    ecgDataValues = ecgData(:, 2);

    % Ensure time and ecgDataValues are of the same length
    if length(time) ~= length(ecgDataValues)
        error('Mismatch in time and ECG data length.');
    end

    % Find R-peaks where amplitude is greater than 380
    threshold = 357;
    rPeakIndices = ecgDataValues > threshold;
    
    % Initialize variables for R-peak detection with minimum time gap
    minTimeGap = 0.5; % Minimum time gap in seconds (500 ms)
    validRPeakIndices = [];
    lastRPeakTime = -inf;

    % Loop through detected R-peaks to apply minimum time gap filter
    for i = 1:length(time)
        if rPeakIndices(i)
            if (time(i) - lastRPeakTime) >= minTimeGap
                validRPeakIndices = [validRPeakIndices; i];
                lastRPeakTime = time(i);
            end
        end
    end

    % Plot raw ECG signal and R-peaks on the same figure
    figure;

    % Plot raw ECG signal
    subplot(2,1,1); % First subplot for raw ECG signal
    plot(time, ecgDataValues);
    title('Raw ECG Signal');
    xlabel('Time (s)');
    ylabel('Amplitude');

    % Plot raw ECG signal and R-peaks
    subplot(2,1,2); % Second subplot for raw ECG signal and R-peaks
    plot(time, ecgDataValues, 'b'); % Plot raw ECG signal in blue
    hold on;
    plot(time(validRPeakIndices), ecgDataValues(validRPeakIndices), 'ro'); % Plot R-peaks as red circles
    hold off;
    title('Raw ECG Signal with R-peaks (Amplitude > 380)');
    xlabel('Time (s)');
    ylabel('Amplitude');

    % Calculate RR intervals
    rPeakTimes = time(validRPeakIndices);
    RR_intervals = diff(rPeakTimes); % RR intervals in seconds

    % Calculate heart rate
    heart_rate = 60 ./ RR_intervals; % Heart rate in beats per minute (bpm)

    % Calculate average RR interval
    avg_RR_interval = mean(RR_intervals);

    % Calculate number of R-peaks per minute
    num_R_peaks_per_minute = length(rPeakTimes) * (60 / duration);

    % Create a table with R-peaks and heart rate
    combinedTable = table(rPeakTimes, ecgDataValues(validRPeakIndices), ...
        'VariableNames', {'Time_s', 'ECG_Amplitude'});

    % Append heart rate values to the table (shifted to match the R-peaks)
    if length(heart_rate) > 0
        % Create a column for heart rate, aligned with the R-peaks
        heartRateColumn = NaN(length(rPeakTimes), 1);
        heartRateColumn(2:end) = heart_rate; % Align heart rate values
        combinedTable.Heart_Rate_bpm = heartRateColumn;
    end

    % Prompt user for their name using a menu
    prompt = {'Enter your username:'};
    dlgTitle = 'Input';
    numLines = 1;
    defaultAnswer = {''};
    userInput = inputdlg(prompt, dlgTitle, numLines, defaultAnswer);
    username = userInput{1}; % Get the username from the input dialog

    % Create file path with username in C:\ecg folder
    folderPath = 'C:\ecg'; % Folder path on C drive
    if ~exist(folderPath, 'dir')
        mkdir(folderPath); % Create folder if it does not exist
    end
    baseFileName = sprintf('%s_ecg.xlsx', username);
    filePath = fullfile(folderPath, baseFileName); % Initial file path

    % Add a number suffix if file already exists
    count = 1;
    while isfile(filePath)
        filePath = fullfile(folderPath, sprintf('%s_%d_ecg.xlsx', username, count));
        count = count + 1;
    end

    % Write combined data to Excel file
    writetable(combinedTable, filePath, 'Sheet', 'ECG Data', 'WriteRowNames', true);

    % Display results in command window
    disp(['Number of R-peaks per minute: ', num2str(num_R_peaks_per_minute)]);
    disp(['Average RR interval: ', num2str(avg_RR_interval)]);
    disp(['Heart rate (bpm): ', num2str(mean(heart_rate))]); % Print average heart rate
end
