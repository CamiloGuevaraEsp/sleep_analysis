function multiExpDAManalysis()
close all;
tic;
try,
    addpath('/Users/camilog/Documents/Camilo/Sleep_codes_MAC/20250414'); %...,folderNameN)
catch,
end;
primedir = '/Users/camilog/Documents/Camilo/Sleep_codes_MAC/20250414';;
xl2read = '20250414_mat2read.xlsx';
zt_binsize = 24    ; %If 12, will lo  ok at day, night separately.
% zt_binsize = 12; %If  12, will look at day, night separately.
%Change zt_binsize to 24 if you want to look at full day.
maxDays = 3; %ABSOLUTELY CAN NOT HAVE MAXDAYS BE GREATER THAN THE NUMBER OF ACTUAL DAYS IN THE EXPERIMENT.
%DO NOT EDIT ANYTHING BELOW THIS LINE.
%=====================================
days2avg = [1 2];
subp_cols = ceil(sqrt(maxDays));
subp_rows = ceil(maxDays/subp_cols);
durationMinuteBins = 10:10:600;
ztBinBounds = [0:zt_binsize:24];
numZTbins = numel(ztBinBounds)-1;

for(zti = 1:numZTbins),
    if(numel(ztBinBounds)==1),
        output = strrep(xl2read,'mat2read.xlsx',['_24hrs_multiColumnByFly.xlsx']);
    else,
        output = strrep(xl2read,'mat2read.xlsx',['_ZT' num2str(ztBinBounds(zti)) 'to' num2str(ztBinBounds(zti+1)) '_multiColumn.xlsx']);
    end;
    prevRow = 2;
    cd(primedir);
    if(exist([output],'file'));
        delete([output]);
    end;
    
    [num,txt,raw] = xlsread(xl2read);
    
    numGroups = size(raw,2)-2;
    %First two columns are dedicated to describing rootdir and matname.
    %Subsequent columns describe the experimental groups. The first one is
    %always the control group.
    % groupColors = [0 0 0; 0 1 0; 0 0 1]; %0 0 1; 1 0 0];
    
    actPerMin_CtrlVsExp = cell(maxDays,2);
    totalSleep_CtrlVsExp = cell(maxDays,2);
    latency_CtrlVsExp = cell(maxDays,2);
    longestSleepBout_CtrlVsExp = cell(maxDays,2);
    numSleepBout_CtrlVsExp = cell(maxDays,2);
    meanSleepBout_CtrlVsExp = cell(maxDays,2);
    for(gi = 1:numGroups),
        for(di = 1:maxDays),
            activityPerMinutePerGroup = [];
            sleepPerMinutePerGroup = [];
            %             sleepPerBinPerGroup = [];
            minsAwakePerGroup = [];
            sleepBinaryPerGroup = [];
            
            expNumPerGroup = {};
            for(ri = 1:size(raw,1)),
                
                groupName2Match = raw{ri,gi+2};
                rootdir = raw{ri,1};
                matname = raw{ri,2};
                %                 try,
                if(~isnan(rootdir)),
                    cd(rootdir);
                    try,
                    M = load(matname);
                    catch,
                        M = load([matname '.mat']);
                    end;
                    groupDatForExp = M.allDatByGroup;
                    %The first column of groupDatForExp contains information
                    %regarding the
                    for(gii=1:size(groupDatForExp,1)),
                        if(strcmp(groupDatForExp{gii,1},groupName2Match)),
                            gi2match=gii;
                        else,
                            display(['gii=' num2str(gii) ', ' groupDatForExp{gii,1} ': did not match ' groupName2Match]);
                        end;
                    end;
                    
                    %Now we know which group we want to pull out.
                    display(rootdir);
                    display(groupName2Match);
                    if(exist('gi2match','var')),
                        if(gi2match<=size(groupDatForExp,1)),
                            thisGroupDat = groupDatForExp{gi2match,2};
                            %Data for this group and this experiment is stored in a cell
                            %mat, where each row represents a day. There are three columns:
                            %             thisGroupActivity{di,1} = activityCounts30min_bin;
                            %             thisGroupActivity{di,2} = sleep30min_bin;
                            %             thisGroupActivity{di,3} = minsAwake;
                            if(di<=size(thisGroupDat,1)),
                                activityCounts30min_bin = thisGroupDat{di,1};
                                sleep30min_bin = thisGroupDat{di,2};
                                minsAwake = thisGroupDat{di,3};
                                sleepBinary = thisGroupDat{di,4};
                                %Have now added a sleepPerBinPerGroup matrix.
                                %This is essentially the same as
                                %activityPerMinutePerGroup, only reshaped to
                                %fit into the redefined ZT bins:
                                
                                if(~isempty(sleepBinary)),
                                    sleepBinary_thisZT = sleepBinary(:,(ztBinBounds(zti)*60+1):(ztBinBounds(zti+1)*60));
                                    minsAwake = ones(size(sleepBinary_thisZT,1),1)*size(sleepBinary_thisZT,2) - nansum_CTH(sleepBinary_thisZT,2);
                                else,
                                    sleepBinary_thisZT = [];
                                end;
                                if(isempty(activityPerMinutePerGroup) && ~isempty(sleepBinary_thisZT)),
                                    activityPerMinutePerGroup = activityCounts30min_bin(:,(ztBinBounds(zti)*2+1):(ztBinBounds(zti+1)*2));
                                    sleepPerMinutePerGroup = sleep30min_bin;
                                    %                                     minsAwakePerGroup = minsAwake;
                                    sleepBinaryPerGroup = sleepBinary_thisZT;
                                    minsAwakePerGroup = minsAwake; %size(sleepBinary_thisZT,2) - nansum_CTH(sleepBinary_thisZT);
                                    expNumPerGroup = ones(size(minsAwake))*ri;
                                    %                                 sleepPerBinPerGroup = sleep_ztbin;
                                elseif(~isempty(sleepBinary_thisZT)),
                                    try,
                                        activityPerMinutePerGroup = [activityPerMinutePerGroup;
                                            activityCounts30min_bin(:,(ztBinBounds(zti)*2+1):(ztBinBounds(zti+1)*2))];
                                    catch,
                                        display('Why?');
                                    end;
                                    sleepPerMinutePerGroup = [sleepPerMinutePerGroup;
                                        sleep30min_bin];
                                    minsAwakePerGroup = [minsAwakePerGroup;
                                        minsAwake];
                                    if(~isempty(sleepBinary)),
                                        sleepBinaryPerGroup = [sleepBinaryPerGroup; sleepBinary(:,(ztBinBounds(zti)*60+1):(ztBinBounds(zti+1)*60))];
                                    end;
                                    expNumPerGroup = [expNumPerGroup; ones(size(minsAwake))*ri];
                                end;
                            end;
                        else,
                            display(['gi2match=' num2str(gi2match) ', was not less than size(groupDatForExp,1) =' num2str(size(groupDatForExp,1))]);
                        end;
                    end;
                    display(['Finished reading rootdir = ' rootdir]);
                else,
                    display(['Could not find rootdir information in row ' num2str(ri)]);
                end;
                display(['Have finished reading ' matname]);
            end; %Finished iterating through all the experiments.
            
            
            totalSleep = nansum_CTH(sleepBinaryPerGroup,2);
            totalActivity = nansum_CTH(activityPerMinutePerGroup,2)./minsAwakePerGroup; %nansum_CTH(minsAwakePerGroup,2); %./totalsForGroup{di,3};
            activityDebugParams = [nansum_CTH(activityPerMinutePerGroup,2) minsAwakePerGroup];
            
            cd(primedir);
            try,
            writematrix(sleepPerMinutePerGroup,output,'Sheet',['Day ' num2str(di) ' 30 min binned sleep' num2str(di)],'Range',['C' num2str(prevRow+1)]);
            catch,
                display('Input array is empty.');
            end;
            
            
            columnCharForDay = char(66+di); %di = day number, 66 = char B.
            if(prevRow==2)
                writecell({'Genotype','Exp Row#','Day 1'},output,'Sheet','Sleep (mins)','Range',['A1:C1']);
                writecell({'Genotype','Exp Row#','Day 1'},output,'Sheet','Activity Counts Per min','Range',['A1:C1']);
                writecell({'Genotype','Exp Row#','Day 1'},output,'Sheet','Mean sleep bout w ends (mins)','Range',['A1:C1']);
                writecell({'Genotype','Exp Row#','Day 1'},output,'Sheet','Num sleep bouts','Range',['A1:C1']);
                writecell({'Genotype','Exp Row#','Day 1'},output,'Sheet','Longest sleep bout (min)','Range',['A1:C1']);
                writecell({'Genotype','Exp Row#','Day 1'},output,'Sheet','Time to first sleep bout (min)','Range',['A1:C1']);
                %             end;
            end;
            writematrix(totalSleep,output,'Sheet','Sleep (mins)','Range',[columnCharForDay num2str(prevRow)]);
            
            writematrix(totalActivity,output,'Sheet','Activity Counts Per min','Range',[columnCharForDay num2str(prevRow)]);
            %%
             labels2write = cell(size(totalSleep,1),1);
             labels2write(1:end,1) = {groupName2Match};
            
            sheetName = sprintf('Day %d 30 min binned sleep%d', di, di);
            header    = {'Genotype','Exp Row#', sprintf('Day %d', di)};
            
            % Write header for this day’s sheet (only once, before any data rows)
            if prevRow==2  % or some other flag to do it only the first time you hit this sheet
                writecell(header, output, ...
                          'Sheet', sheetName, ...
                          'Range', 'A1');
            end
            
            % Now write each group’s data under that header
            writecell(labels2write,  output, ...
                      'Sheet', sheetName, ...
                      'Range', ['A' num2str(prevRow+1)]);
            writematrix(expNumPerGroup, output, ...
                        'Sheet', sheetName, ...
                        'Range', ['B' num2str(prevRow+1)]);
            writematrix(sleepPerMinutePerGroup, output, ...
                        'Sheet', sheetName, ...
                        'Range', ['C' num2str(prevRow+1)]);
            
            if(di==1),
                %labels2write = cell(size(totalSleep,1),1);
                %labels2write(1:end,1) = {groupName2Match};
                
                writecell(labels2write,output,'Sheet','Activity Counts Per min','Range',['A' num2str(prevRow)]);
                writematrix(expNumPerGroup,output,'Sheet','Activity Counts Per min','Range',['B' num2str(prevRow)]);
                
                
                %First, start by writing the 30 min bin profile
                %writecell(labels2write,output,'Sheet',['Day ' num2str(di) ' 30 min binned sleep' num2str(di)],'Range',['A' num2str(prevRow+1)]);
                %writematrix(expNumPerGroup,output,'Sheet',['Day ' num2str(di) ' 30 min binned sleep' num2str(di)],'Range',['B' num2str(prevRow+1)]);
                if(gi==1),
                writematrix(0.5:0.5:24,output,'Sheet',['Day ' num2str(di) ' 30 min binned sleep' num2str(di)],'Range',['C' num2str(prevRow)]);
                end;
                
                writecell(labels2write,output,'Sheet','Sleep (mins)','Range',['A' num2str(prevRow)]);
                writematrix(expNumPerGroup,output,'Sheet','Sleep (mins)','Range',['B' num2str(prevRow)]);
            end;
            %             xlswrite(output,activityDebugParams,'Activity Counts Per min',['E' num2str(prevRow)]);
            
            latency_dayGroup = NaN(size(sleepBinaryPerGroup,1),1);
            longestSleep_dayGroup = NaN(size(sleepBinaryPerGroup,1),1);
            meanSleep_dayGroup = NaN(size(sleepBinaryPerGroup,1),1);
            numSleep_dayGroup = NaN(size(sleepBinaryPerGroup,1),1);
            longestSleep_dayGroup = NaN(size(sleepBinaryPerGroup,1),1);
            for(xi = 1:size(sleepBinaryPerGroup,1)),
                thisFlyBinary = sleepBinaryPerGroup(xi,:);
                display(sum(thisFlyBinary));
                [durationHist, allDurations,~,numBouts,allDurationsWithEnds] = durationHistogram(thisFlyBinary, durationMinuteBins);
                %While we're iterating through all the files, may as well grab
                %the other sleep data we need:
                
                if(numel(allDurations)==0),
                    longestSleep_dayGroup(xi) = 0; %max(allDurations);
                    meanSleep_dayGroup(xi) = 0; %mean(allDurations);
                    numSleep_dayGroup(xi) = 0; %numel(allDurations);
                    latency_dayGroup(xi) = 0;
                    longestSleep_dayGroup(xi) = 0;
                else,
                    try,
                        latency_dayGroup(xi) = find(thisFlyBinary==1,1);
                    catch,
                        display('what?');
                    end;
                    longestSleep_dayGroup(xi) = max(allDurations);
                    meanSleep_dayGroup(xi) = mean(allDurationsWithEnds);
                    numSleep_dayGroup(xi) = numel(allDurationsWithEnds);
                end;
            end;
            
            writematrix(meanSleep_dayGroup,output,'Sheet','Mean sleep bout w ends (mins)','Range',[columnCharForDay num2str(prevRow)]);
            if(di==1),
                writecell(labels2write,output,'Sheet','Mean sleep bout w ends (mins)','Range',['A' num2str(prevRow)]);
                writematrix(expNumPerGroup,output,'Sheet','Mean sleep bout w ends (mins)','Range',['B' num2str(prevRow)]);
            end;
            
            writematrix(numSleep_dayGroup,output,'Sheet','Num sleep bouts','Range',[columnCharForDay num2str(prevRow)]);
            if(di==1),
                writecell(labels2write,output,'Sheet','Num sleep bouts','Range',['A' num2str(prevRow)]);
                writematrix(expNumPerGroup,output,'Sheet','Num sleep bouts','Range',['B' num2str(prevRow)]);
            end;
            
            writematrix(longestSleep_dayGroup,output,'Sheet','Longest sleep bout (min)','Range',[columnCharForDay num2str(prevRow)]);
            if(di==1),
                writecell(labels2write,output,'Sheet','Longest sleep bout (min)','Range',['A' num2str(prevRow)]);
                writematrix(expNumPerGroup,output,'Sheet','Longest sleep bout (min)','Range',['B' num2str(prevRow)]);
            end;
            
            writematrix(latency_dayGroup,output,'Sheet','Time to first sleep bout (min)','Range',[columnCharForDay num2str(prevRow)]);
            if(di==1),
                writecell(labels2write,output,'Sheet','Time to first sleep bout (min)','Range',['A' num2str(prevRow)]);
                writematrix(expNumPerGroup, output,'Sheet','Time to first sleep bout (min)','Range',['B' num2str(prevRow)]);
            end;
            
            display(['Have written information about day ' num2str(di) ' for ' groupName2Match ' to ' columnCharForDay num2str(prevRow) ...
                ', included ' num2str(numel(meanSleep_dayGroup)) ' samples']);
        end;%Close the "day" for loop.
        
        prevRow = prevRow+size(labels2write,1);
    end;  %Close the "group" for loop.
    %Note that this loop is the one where we created the new Excel
    %spreadsheet.
end; %Close for ZTtimebins

toc