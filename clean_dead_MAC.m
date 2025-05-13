clear all
rootdir      = "/Users/camilog/Documents/Camilo/Sleep_codes_MAC/20250414";
filename     = "20250414__ZT0to24_multiColumn.xlsx";
NumDays = 3; 

cd(rootdir)
output       = filename + "_edited.xlsx";


activity_sheet = readtable(filename,'Sheet','Activity Counts Per min');


data_sheet2 = activity_sheet{:,vartype('numeric')};
dead_flies = (isnan(data_sheet2));
dead_flies = find(any(dead_flies,2));
dead_flies_days = dead_flies+1;

sleep_days_index = [1,8:7+(NumDays-1)];
other_index = [2:7];

sheetNames = getExcelSheetNames(filename);

for i = sleep_days_index
        data = readtable(filename, 'Sheet',i);
        rows_to_delete = dead_flies_days; 
        data(rows_to_delete,:) = [];
        writetable(data, output, 'Sheet', char(sheetNames{i}));
end

for i = other_index
    data = readtable(filename, 'Sheet',i);
    rows_to_delete = dead_flies; 
    data(rows_to_delete,:) = [];
    writetable(data, output, 'Sheet', char(sheetNames{i}));
end


function sheetNames = getExcelSheetNames(filename)
%GETEXCELSHEETNAMES Extracts sheet names from a .xlsx file (cross-platform)
%   sheetNames = getExcelSheetNames('myfile.xlsx')

    % Ensure the file exists
    if ~isfile(filename)
        error('File not found: %s', filename);
    end

    % Create a temporary directory to unzip into
    tempDir = tempname;
    mkdir(tempDir);

    % Unzip the Excel file (it's just a ZIP archive)
    unzip(filename, tempDir);

    % Path to the workbook metadata
    workbookXML = fullfile(tempDir, 'xl', 'workbook.xml');
    if ~isfile(workbookXML)
        error('workbook.xml not found in %s. File may not be a valid .xlsx', filename);
    end

    % Read and parse the XML
    doc = xmlread(workbookXML);
    sheetList = doc.getElementsByTagName('sheet');
    sheetNames = cell(sheetList.getLength, 1);

    for k = 0:sheetList.getLength-1
        sheetNode = sheetList.item(k);
        nameAttr = sheetNode.getAttribute('name');
        sheetNames{k+1} = char(nameAttr);
    end

    % Clean up
    rmdir(tempDir, 's');
end



