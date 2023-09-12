clear all 
close all

% Write the groups, in the following order:
% exp
% uas control
% Gal4 control
tic
groups = {'R58H05_gnpat_female'; 'gnpat_control_female'; 'R58H05_control_female'};
filename = "/Users/camilog/Downloads/20230911a__ZT0to24_multiColumn.xlsx";
NumDays = 3; 
% Add the name of the sheet for each day

days = {"Day 1 30 min binned sleep1";
    "Day 2 30 min binned sleep2";
    "Day 3 30 min binned sleep3"
};

%The data range for your genotypes
DataRangeGen = "A1:AX356";
%The data range for your sleep data
DataRangeSleep = "A2:AX356";

%----DO NOT CHANGE ANYTHING BELOW

opts = spreadsheetImportOptions("NumVariables", 50);

% Specify sheet and range
opts.Sheet = "Day 1 30 min binned sleep1";
opts.DataRange = DataRangeGen;
% Specify column names and types
opts.VariableNames = ["VarName1"];
opts.VariableTypes = ["categorical"]
% Specify variable properties
opts = setvaropts(opts, "VarName1", "EmptyFieldRule", "auto");


genotype = readtable(filename, opts, "UseExcel", false);
time = 0.5:0.5:24;


color_codes =  [[0.3922    0.8314    0.0745]; [0.5020    0.5020    0.5020]; [ 0     0     0]];
for j = 1 : length(groups);

    for i = 1: NumDays

    data = returnGenotype(days{i}, filename, DataRangeSleep); 
    groupidx = find(genotype.VarName1 == groups(j));
    sleepData = data(groupidx, 2:end); 
    meanSleepData = mean(sleepData);
    meanSleepData = meanSleepData';
    SleepByDays (:,i, j) = meanSleepData; 
    end
    meanSleep(:,j) = mean(SleepByDays(:,:,j),2);
    err = std(SleepByDays(:,:,j),0,2); 
    err = std(SleepByDays(:,:,j),0,2)/sqrt(length(SleepByDays(:,:,j)));
    errorbar(time, meanSleep(:,j),err, '-o', "MarkerSize",5,'Color',color_codes(j,:), 'LineWidth',2);
    % e.Marker = 'O';
    % e.MarkerSize = 10; 
    hold on
    
    
end
legend(groups, 'Location', 'southeast')
legend('boxoff');

exp = SleepByDays(:,:,1);
uasctrl = SleepByDays(:,:,2);
Gal4ctrl = SleepByDays(:,:,3);

toc 

function data = returnGenotype (day, filename, datarange)

opts = spreadsheetImportOptions("NumVariables", 50);

% Specify sheet and range
opts.Sheet = day;
opts.DataRange = datarange;

% Specify column names and types
opts.VariableNames = ["Var1", "VarName2", "VarName3", "VarName4", "VarName5", "VarName6", "VarName7", "VarName8", "VarName9", "VarName10", "VarName11", "VarName12", "VarName13", "VarName14", "VarName15", "VarName16", "VarName17", "VarName18", "VarName19", "VarName20", "VarName21", "VarName22", "VarName23", "VarName24", "VarName25", "VarName26", "VarName27", "VarName28", "VarName29", "VarName30", "VarName31", "VarName32", "VarName33", "VarName34", "VarName35", "VarName36", "VarName37", "VarName38", "VarName39", "VarName40", "VarName41", "VarName42", "VarName43", "VarName44", "VarName45", "VarName46", "VarName47", "VarName48", "VarName49", "VarName50"];
opts.SelectedVariableNames = ["VarName2", "VarName3", "VarName4", "VarName5", "VarName6", "VarName7", "VarName8", "VarName9", "VarName10", "VarName11", "VarName12", "VarName13", "VarName14", "VarName15", "VarName16", "VarName17", "VarName18", "VarName19", "VarName20", "VarName21", "VarName22", "VarName23", "VarName24", "VarName25", "VarName26", "VarName27", "VarName28", "VarName29", "VarName30", "VarName31", "VarName32", "VarName33", "VarName34", "VarName35", "VarName36", "VarName37", "VarName38", "VarName39", "VarName40", "VarName41", "VarName42", "VarName43", "VarName44", "VarName45", "VarName46", "VarName47", "VarName48", "VarName49", "VarName50"];
opts.VariableTypes = ["char", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% Specify variable properties
opts = setvaropts(opts, "Var1", "WhitespaceRule", "preserve");
opts = setvaropts(opts, "Var1", "EmptyFieldRule", "auto");

% Import the data
numbers = readtable(filename, opts, "UseExcel", false);

data = table2array(numbers);

end 