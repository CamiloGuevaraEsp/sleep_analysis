%SleepTraces_meanSEM
%The main outputs of this code are: 
%expTrace, Gal4ctrlTrace,uasctrlTrace that contains the mean sleep minutes
%per day
%expArray, GalArray, uasArray that contains mean, sem and N per group per
%day, for easy drawing in graphpad. 

%By: Camilo Guevara
%Last Version: november 2nd 2023


clear all 
close all

% Write the groups, in the following order:
% exp
% uas control
% Gal4 control
tic

groups = {'R58_ATR_female','R58_female','R58_ATR_female'};
%groups = {'tsh_gtacr',  'gtacr_control','tsh_control'}
%groups = {'96_ATR_female', '96_ctrl_female', 'X'};
filename = "/Volumes/Camilo_1/Sleep_runs/20241122/20241122__ZT0to24_multiColumn.xlsx";
NumDays = 3; 
mult_day_plot = 'no'

% Add the name of the sheet for each dayu
days = cell(NumDays,1);

for i = 1:NumDays
    days{i} = "Day " + num2str(i) + " 30 min binned sleep" + num2str(i);
end
   
%The data range for your genotypes (just check if it goes past cell 1000,
%which is unlikely)
DataRangeGen = "A1:AX1000";
%The data range for your sleep data
DataRangeSleep = DataRangeGen;

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
    errorData = std(sleepData)/sqrt(size(sleepData,1));
    errorData = errorData';
    SleepByDays (:,i, j) = meanSleepData; 
    errorByDays (:,i,j) = errorData;
    sizesample(:,i,j) = size(sleepData,1);

    end
    meanSleep(:,j) = mean(SleepByDays(:,:,j),2);
    err = std(SleepByDays(:,:,j),0,2); 
    err = std(SleepByDays(:,:,j),0,2)/sqrt(length(SleepByDays(:,:,j)));
    semSleep(:,j) = err;
    errorbar(time, meanSleep(:,j),err, '-o', "MarkerSize",5,'Color',color_codes(j,:), 'LineWidth',2);
    hold on  
end

legend(groups, 'Location', 'southeast')
legend('boxoff');
%%


expTrace_or = SleepByDays(:,:,1);
expTrace = reshape(expTrace_or,[],1);
uasctrlTrace_or = SleepByDays(:,:,2);
uasctrlTrace = reshape(uasctrlTrace_or,[],1);
Gal4ctrlTrace_or = SleepByDays(:,:,3);
Gal4ctrlTrace = reshape(Gal4ctrlTrace_or,[],1);

expArray = zeros(length(meanSleep),NumDays *3); 
expArray(:,1:3:NumDays* 3) = expTrace_or; 
expArray(:,2:3:NumDays* 3) = errorByDays(:,:,1)
expArray(:,3:3:NumDays* 3) = repmat(sizesample(1,1,1),NumDays, 48)'; 
%expArray = reshape(expArray,[],3);


uasArray = zeros(length(meanSleep),NumDays *3); 
uasArray(:,1:3:NumDays* 3) = uasctrlTrace_or; 
uasArray(:,2:3:NumDays* 3) = errorByDays(:,:,2)
uasArray(:,3:3:NumDays* 3) = repmat(sizesample(1,1,2),NumDays, 48)';
%uasArray = reshape(uasArray,[],3);

 GalArray = zeros(length(meanSleep),NumDays *3); 
 GalArray(:,1:3:NumDays* 3) = SleepByDays(:,:,3); 
 GalArray(:,2:3:NumDays* 3) = errorByDays(:,:,3)
 GalArray(:,3:3:NumDays* 3) = repmat(sizesample(1,1,3),NumDays, 48)';



toc 

expGraph = cat(1,expArray(:,1:3), expArray(:,4:6));
GalGraph = cat(1,GalArray(:,1:3), GalArray(:,4:6));
uasGraph =  cat(1,uasArray(:,1:3), uasArray(:,4:6));
i = 2;
while i < NumDays
    i = i+1;
    expGraph = cat(1,expGraph,expArray(:,(i*3)-2:i*3)); 
    GalGraph = cat(1,GalGraph,GalArray(:,(i*3)-2:i*3));
    uasGraph = cat(1,uasGraph,uasArray(:,(i*3)-2:i*3));
end

figure2 = figure('WindowState','fullscreen');
axes1 = axes('Parent',figure2,...
'Position',[0.0262276785714285 0.25444340505145 0.963727678571428 0.421889616463985]);
hold(axes1,'on');

errorbar(1:length(expGraph),expGraph(:,1),expGraph(:,2), '-o', "MarkerSize",5,'Color', "blue", 'LineWidth',2);
hold on
errorbar(1:length(GalGraph),GalGraph(:,1),GalGraph(:,2),'-o', "MarkerSize",5, 'Color',"black", 'LineWidth',2);
errorbar(1:length(uasGraph),uasGraph(:,1),uasGraph(:,2),'-o', "MarkerSize",5, 'Color',[.7,.7,.7] ,'LineWidth',2);
%legend(groups, 'Location', 'southeast')
%legend('boxoff');

box(axes1,'on');
hold(axes1,'off');

legend(groups, 'Location', 'southeast')
legend('boxoff');



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

