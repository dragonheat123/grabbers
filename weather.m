clear all;

filename = 'C:\Users\lorky\Desktop\weathergrabber\changi2016.txt';
delimiter = ',';
startRow = 2;

formatSpec = '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

textscan(fileID, '%[^\n\r]', startRow-1, 'WhiteSpace', '', 'ReturnOnError', false);
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = dataArray{col};
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[2,3,4,5,6,8,13]
    % Converts strings in the input cell array to numbers. Replaced non-numeric
    % strings with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1);
        % Create a regular expression to detect and remove non-numeric prefixes and
        % suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData{row}, regexstr, 'names');
            numbers = result.numbers;
            
            % Detected commas in non-thousand locations.
            invalidThousandsSeparator = false;
            if any(numbers==',');
                thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(numbers, thousandsRegExp, 'once'));
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % Convert numeric strings to numbers.
            if ~invalidThousandsSeparator;
                numbers = textscan(strrep(numbers, ',', ''), '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch me
        end
    end
end

dateFormats = {'hh:mm a', 'dd-MMM-yyyy HH:mm:ss'};
dateFormatIndex = 1;
blankDates = cell(1,size(raw,2));
anyBlankDates = false(size(raw,1),1);
invalidDates = cell(1,size(raw,2));
anyInvalidDates = false(size(raw,1),1);
for col=[1,14]% Convert the contents of columns with dates to MATLAB datetimes using date format string.
    try
        dates{col} = datetime(dataArray{col}, 'Format', dateFormats{col==[1,14]}, 'InputFormat', dateFormats{col==[1,14]}); %#ok<SAGROW>
    catch
        try
            % Handle dates surrounded by quotes
            dataArray{col} = cellfun(@(x) x(2:end-1), dataArray{col}, 'UniformOutput', false);
            dates{col} = datetime(dataArray{col}, 'Format', dateFormats{col==[1,14]}, 'InputFormat', dateFormats{col==[1,14]}); %%#ok<SAGROW>
        catch
            dates{col} = repmat(datetime([NaN NaN NaN]), size(dataArray{col})); %#ok<SAGROW>
        end
    end
    
    dateFormatIndex = dateFormatIndex + 1;
    blankDates{col} = cellfun(@isempty, dataArray{col});
    anyBlankDates = blankDates{col} | anyBlankDates;
    invalidDates{col} = isnan(dates{col}.Hour) - blankDates{col};
    anyInvalidDates = invalidDates{col} | anyInvalidDates;
end
dates = dates(:,[1,14]);
blankDates = blankDates(:,[1,14]);
invalidDates = invalidDates(:,[1,14]);

rawNumericColumns = raw(:, [2,3,4,5,6,8,13]);
rawCellColumns = raw(:, [7,9,10,11,12]);


%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns); % Find non-numeric cells
rawNumericColumns(R) = {NaN}; % Replace non-numeric cells

%% Create output variable
changi2016 = table;
changi2016.TimeSGT = dates{:, 1};
changi2016.TemperatureC = cell2mat(rawNumericColumns(:, 1));
changi2016.DewPointC = cell2mat(rawNumericColumns(:, 2));
changi2016.Humidity = cell2mat(rawNumericColumns(:, 3));
changi2016.SeaLevelPressurehPa = cell2mat(rawNumericColumns(:, 4));
changi2016.VisibilityKm = cell2mat(rawNumericColumns(:, 5));
changi2016.WindDirection = rawCellColumns(:, 1);
changi2016.WindSpeedKmh = cell2mat(rawNumericColumns(:, 6));
changi2016.GustSpeedKmh = rawCellColumns(:, 2);
changi2016.Precipitationmm = rawCellColumns(:, 3);
changi2016.Events = rawCellColumns(:, 4);
changi2016.Conditions = rawCellColumns(:, 5);
changi2016.WindDirDegrees = cell2mat(rawNumericColumns(:, 7));
changi2016.DateUTC = dates{:, 2};


%% Clear temporary variables
clearvars filename delimiter startRow formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me dateFormats dateFormatIndex dates blankDates anyBlankDates invalidDates anyInvalidDates rawNumericColumns rawCellColumns R;