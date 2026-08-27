rootdir = "/Volumes/NO NAME/data_to_analyze/to_analyze";
filename = "20240219sb__ZT0to24_multiColumn.xlsx"
NumDays = 3; 

cd(rootdir)
output =  filename + "_edited.xlsx"

[sheet_name, sheet_index] = xlsfinfo(filename);

activity_sheet = find(sheet_index == "Activity Counts Per min");
[data_sheet2,headers_sheet2] = xlsread(filename,activity_sheet);
dead_flies = (isnan(data_sheet2));
dead_flies = find(any(dead_flies,2));
%dead_flies = find(isnan(data_sheet2(:,NumDays + 1))) 
dead_flies_days = dead_flies+1;

sleep_days_index = [2,9:8+(NumDays-1)];
other_index = [3:8];

for i = sleep_days_index
        data = readtable(filename, 'Sheet',sheet_index{i});
        rows_to_delete = dead_flies_days; 
        data(rows_to_delete,:) = [];
        writetable(data, output, 'Sheet', sheet_index{i});
end

for i = other_index
    data = readtable(filename, 'Sheet',sheet_index{i});
    rows_to_delete = dead_flies; 
    data(rows_to_delete,:) = [];
    writetable(data, output, 'Sheet', sheet_index{i});
end




