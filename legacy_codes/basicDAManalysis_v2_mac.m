function basicDAManalysis()
close all; clear all;
% Copy and paste your directory into the single quotation marks below.
rootdir = '/Users/camilog/Documents/Camilo/Sleep_codes_MAC/20250414';
plotAreaQuartiles = 0;
rawdir = [rootdir '/Raw Data'];
maxDays = 3  %   put here the number of days of the recording
backslashIndices = strfind(rootdir,'/');
if(backslashIndices(end)==numel(rootdir)),
    lastDirIndex = backslashIndices(end-1)+1;
else,
    lastDirIndex =backslashIndices(end)+1;
end;
expName = rootdir(lastDirIndex:end);
flyIDname = [expName '_channelList']
groupNames = {'pex16_control_male_naca';	'pex16_control_male';	'pex16_control_female_naca';	'pex16_control_female';	'R58H05_pex16_male_naca';	'R58H05_pex16_male';	'R58H05_pex16_female_naca';	'R58H05_pex16_female';	'R58H05_control_male_naca';	'R58H05_control_male';	'R58H05_control_female_naca';	'R58H05_control_female';	'chat_pex16_male';	'chat_pex16_female';	'chat_control_male';	'chat_control_female';	'pex16_control_male_chat';	'pex16_control_female_chat'};
%Should be as many rows of three column inputs as there are groupNames.
groupColors = rand(size(groupNames,1),3);

% DO NOT CHANGE ANYTHING BELOW THIS LINE.
%======================================================================
cd(rootdir);

% flyIDname = '161229_channelList trueGenotype';
% try,
[n,t,r] = xlsread([flyIDname '.xlsx']); %reads the channelList
% catch,
% end;
output = [flyIDname];

%Is it searching Pysolo file?
if(exist([output '.ps'],'file')),
    delete([output '.ps']);
end;

groupNameByChannel = r(:,2);  % in the channelList that is being read, now is calling (:,2), which are all rows in second column  that contain group names
if(~exist([output '.mat'],'file')||1),
    if(size(r,2)>=3),
        %C.G.Separates the data per days, output is a cell array, rows is each
        %group, it shows the activity values.
        %Inside each element of the cell Array it has an (n x m) array,
        %where n-rows is the number of days and m-columns are (1) a column which I am not sure what is doing
        %and (2) the activity counts per day
        allChannelDatByDay = processChannels(rawdir,groupNameByChannel,r(:,1),r(:,3));  %%%%%
    else,
        allChannelDatByDay = processChannels(rawdir,groupNameByChannel);
    end;
    cd(rootdir);
    save([output '.mat'],'allChannelDatByDay');
    display(['Have saved ' output '.mat']);
    % else,
    %     allChannelDatByDay = load([output '.mat']);
    %     allChannelDatByDay = allChannelDatByDay.allChannelDatByDay;
end;

allDatByGroup = cell(numel(groupNames),2);
%C.G Looping through groups
for(gi = 1:numel(groupNames)),
    allDatByGroup{gi,1} = groupNames{gi};
    display(groupNames{gi});
    thisGroupActivity = cell(maxDays,5); %col1 = activity, col2 = sleep.
    %C.G Looping through the channels withing the same group
    for(ci = 1:size(groupNameByChannel,1)),
        if(strcmp(groupNames{gi},groupNameByChannel{ci})),
            thisChannelDatByDay = allChannelDatByDay{ci};
            if(~isempty(thisChannelDatByDay)),
                figure(1);
                %C.G Looping through the days
                for(di = 1:size(thisChannelDatByDay,1)),
                    %C.G Looping trough the days (number of rows), getting the
                    %second column (activity column)
                    activityCountsForDay = thisChannelDatByDay{di,2};
                    display(di);
                    try,
                        %C.G.Here sums the activity data in 30 min bins.
                        % If you want to change the bin (example 60 mins):
                        %activityCounts30min_bin = sum(reshape(activityCountsForDay,60,24),1);
                        activityCounts30min_bin = sum(reshape(activityCountsForDay,30,48),1);
                    catch,
                        display(numel(activityCountsForDay));
                    end;
                    subplot(maxDays,2,(di-1)*2+1);
                    %C.G.Define X-axis as time, in 30 min increments, 0 0.5
                    %1.5....23.5 
                    timepts = ([1:numel(activityCounts30min_bin)]-1)/2;
                    try,
                        plot(timepts,activityCounts30min_bin,'Color',groupColors(gi,:));
                    catch,
                        display('pausing.');
                    end;
                    xlim([0 24]);    %%%%%%the hours of the day. If I change this to the number of days it might plot subsequet days...
                    %I could potentially play with it to make plots for >1
                    %days 

                    %C.G.Here it is finding the indices where the fly is
                    %inactive
                    isStopped = activityCountsForDay==0;
                    %C.G.Here it is bounding the inactivity periods
                    stoppedStarts = find(diff(isStopped)==1)+1;
                    stoppedEnds = find(diff(isStopped)==-1);

                    %C.G. I don't get 100% what the code is trying to do here
                    %What is the problem of inactive fly at the beginning
                    %or at the end of the recording? 
                    if(isStopped(1)),
                        stoppedStarts = [1; stoppedStarts];
                    end;
                    if(isStopped(end)),
                        stoppedEnds = [stoppedEnds; numel(isStopped)];
                    end;
                    
                    stopLengths = (stoppedEnds-stoppedStarts)+1;
                    %C.G. As it is 1 min bin, it will find those periods with 5
                    %min inactivity, play with it if you want to test
                    %different sleep definitions
                    trueSleepStopBoutIndices = find(stopLengths>=5);
                    isSleep = zeros(size(activityCountsForDay));
                    for(si = 1:numel(trueSleepStopBoutIndices))
                        %C.G.Indexing to find where in the 1min binned data are
                        %true sleep episodes
                        isSleep(stoppedStarts(trueSleepStopBoutIndices(si)):stoppedEnds(trueSleepStopBoutIndices(si))) = 1;
                    end;
                    minsAwake = 1440-sum(isSleep);
                    display(numel(isSleep));
                    try,
                        %Now create and array where sleep is measured every
                        %30 mins
                        sleep30min_bin = sum(reshape(isSleep,30,48),1);
                    catch,
                        pause;
                    end;
                    subplot(maxDays,2,di*2);
                    plot(timepts,sleep30min_bin,'Color',groupColors(gi,:));
                    xlim([0 24]); ylim([0 30]);
                    
                    %Want to save the information for this day into the
                    %relevant cell of the thisGroupActivity array.
                    thisDayGroupActivity = thisGroupActivity{di,1};
                    if(isempty(thisDayGroupActivity)),
                        thisGroupActivity{di,1} = activityCounts30min_bin;
                        thisGroupActivity{di,2} = sleep30min_bin;
                        thisGroupActivity{di,3} = minsAwake;
                        thisGroupActivity{di,4} = isSleep';
                        %                         thisGroupActivity{di,5} = isSleep';
                    %When would not be empty? 
                    else,
                        thisDayGroupActivity = [thisGroupActivity{di,1}; activityCounts30min_bin];
                        thisDaySleepActivity = [thisGroupActivity{di,2}; sleep30min_bin];
                        thisDayMinsAwake = [thisGroupActivity{di,3}; minsAwake];
                        thisDaySleepBinary = [thisGroupActivity{di,4}; isSleep'];
                        
                        thisGroupActivity{di,1} = thisDayGroupActivity;
                        thisGroupActivity{di,2} = thisDaySleepActivity;
                        thisGroupActivity{di,3} = thisDayMinsAwake;
                        thisGroupActivity{di,4} = thisDaySleepBinary;
                    end;
                end;
                
                subplot(maxDays,2,1); ylabel(['Activity/30 min bins']);
                title([expName ' M' num2str(r{ci,3}) ' Ch' num2str(r{ci,1}) ': ' groupNameByChannel{ci}]);
                subplot(maxDays,2,2); ylabel(['Sleep (mins)']);
                
                orient(figure(1),'landscape');
                print(figure(1),'-dpsc2',[output '.ps'],'-append');
                close(figure(1));
                
            end;
        else,
            display(['gi=' num2str(gi) ' did not match ' groupNames{gi}]);
        end;
    end;
    allDatByGroup{gi,2} = thisGroupActivity;
    
    totalsForGroup = cell(maxDays,2);
    %This part looks like an unfinished block of code...
%     for(di = 1:size(thisGroupActivity,1)),
%         figure(2);
%         activityDat = thisGroupActivity{di,1};
%         sleepDat = thisGroupActivity{di,2};
%         %         display(size(sum(activityDat,2)));
%         display(size(thisGroupActivity{di,3}));
%         if(max(size(thisGroupActivity{di,3}>0))),
%             totalsForGroup{di,1} = sum(activityDat,2)./thisGroupActivity{di,3};
%             totalsForGroup{di,2} = sum(sleepDat,2);
%             
%             %         meanAct = mean(activityDat);
%             %         stdAct = std(activityDat);
%             %         meanSleep = mean(sleepDat);
%             %         stdSleep = std(sleepDat);
%             %         stdArea = [meanAct-stdAct; 2*stdAct];
%             %             meanAct = median(activityDat);
%             %             stdAct = std(activityDat);
%             %             meanSleep = median(sleepDat);
%             %             stdSleep = std(sleepDat);
%             %             if(plotAreaQuartiles==1),
%             %             stdArea = [quantile(activityDat,0.25); quantile(activityDat,0.75)-quantile(activityDat,0.25)];
%             %             end;
%             %
%             %             %         try,
%             %             subplot(maxDays,2,(di-1)*2+1);
%             %             %         try,
%             %             if(numel(stdArea)>2 && plotAreaQuartiles),
%             %                 display(numel(stdArea));
%             %             hArea = area(timepts,stdArea');
%             %             set(hArea(1),'Visible','off');
%             %             set(hArea(2),'FaceColor',groupColors(gi,:),'EdgeColor','none'); hold on;
%             %             alpha(0.2);
%             %             end;
%             %             plot(timepts,meanAct,'Color',groupColors(gi,:)); hold on;
%             %             ylim([0 150]); xlim([0 24]);
%             %             if(plotAreaQuartiles==1),
%             %             stdArea = [quantile(sleepDat,0.25); quantile(sleepDat,0.75)-quantile(sleepDat,0.25)];
%             %             end;
%             %             subplot(maxDays,2,2*di);
%             %             if(numel(stdArea)>2 && plotAreaQuartiles),
%             %             hArea = area(timepts,stdArea');
%             %             set(hArea(1),'Visible','off');
%             %             set(hArea(2),'FaceColor',groupColors(gi,:),'EdgeColor','none'); hold on;
%             %             alpha(0.2);
%             %             end;
%             %             plot(timepts,meanSleep,'Color',groupColors(gi,:)); hold on;
%             %             ylim([0 30]); xlim([0 24]);
%             %
%             %             figure(3);
%             %             subplot(2,2,1);
%             %             totalActivity = totalsForGroup{di,1}; %./totalsForGroup{di,3};
%             %             plot(ones(size(totalActivity))*di+0.15*(gi-1),totalActivity,'o','LineStyle','none','Color',groupColors(gi,:),'MarkerSize',3); hold on;
%             % %             ylim([0 100]);
%             % %                         ylim([0 10]);
%             % ylim([0 10]);
%             %                         xlim([0 maxDays+1]);
%             %
%             %             subplot(2,2,2);
%             %             totalSleep = totalsForGroup{di,2};
%             %             plot(ones(size(totalSleep))*di+0.15*(gi-1),totalSleep,'o','LineStyle','none','Color',groupColors(gi,:),'MarkerSize',3); hold on;
%             %             ylim([0 1440]); xlim([0 maxDays+1]);
%             %
%             %             subplot(2,2,3);
%             %             if(plotAreaQuartiles),
%             %             plotMedianQuartiles(totalActivity,di+0.15*(gi-1),0.1,0.1,groupColors(gi,:));
%             %             end;
%             % %             ylim([0 10]);
%             % ylim([0 10]);
%             %             xlim([0 maxDays+1]);
%             %
%             % % ylim([0 100]);
%             %
%             %             subplot(2,2,4);
%             %             if(plotAreaQuartiles),
%             %             plotMedianQuartiles(totalSleep,di+0.15*(gi-1),0.1,0.1,groupColors(gi,:));
%             %             end;
%             %             ylim([0 1440]); xlim([0 maxDays+1]);
%         end;
%     end;
end;

cd(rootdir);
save([output '.mat'],'allChannelDatByDay','allDatByGroup');
display(['Have saved ' output '.mat']);
% end;
% figure(2);
% subplot(maxDays,2,1); ylabel(['Activity/30 min bins']);
% subplot(maxDays,2,2); ylabel(['Sleep (mins)']);
%
% figure(3);
% subplot(2,2,1); ylabel(['Activity/Waking min']);
% title([output]);
% subplot(2,2,2); ylabel(['Sleep/Day (mins)']);
% subplot(2,2,3); xlabel(['Day']);
% subplot(2,2,4); xlabel(['Day']);
%
% for(fignum = 2:3),
%     orient(figure(fignum),'landscape');
%     print(figure(fignum),'-dpsc2',[output '.ps'],'-append');
%     close(figure(fignum));
% end;

% ps2pdf('psfile', [output '.ps'], 'pdffile', [output '.pdf'], ...
%     'gspapersize', 'letter',...
%     'verbose', 1, ...
%     'gscommand', 'C:\Program Files\gs\gs9.21\bin\gswin64.exe');
%=======================================================


function allChannelDatByDay = processChannels(rawFolder,groupNameByChannel,varargin)
cd(rawFolder);
allChannelDatByDay = cell(size(groupNameByChannel));
if(nargin>2),
    channelList = varargin{1};
    monitorDat = varargin{2};
end;
%Iterate for each channel
for(csubi = 1:size(groupNameByChannel,1)),
    %Convert channel number into a double
    ci = double(channelList{csubi});
    %     if(strmatch(groupNameByChannel{ci},groupName2Match)),
    if(exist('monitorDat','var')),
        %Convert monitor number into a double
        mnum = double(monitorDat{csubi});
        %Will write channel Name format as it is stored in Raw Data (For
        %example, XXXXXM027C01.txt)
        channelNameFormat = sprintf('*M%03dC%02d.txt',mnum,ci);
    else,
        channelNameFormat = sprintf('*C%02d.txt',ci);
    end;
    allFiles = dir(channelNameFormat); %Contains all the files relevant to the monitor and channel name in question. Should theoretically be equal to the number of days.
    channelDatByDay = cell(size(allFiles,1),2);
    datenumList = NaN(size(channelDatByDay,1),1);
    if(size(allFiles,1)>1),
        for(fi = 1:size(allFiles,1)),
            filename = allFiles(fi).name
            fID = fopen(filename);
            lineFileDate = fgets(fID);
            dateString = lineFileDate(15:end);
            dateVec = datevec(dateString);
            
            numSamplePts = str2double(fgets(fID));
            if(numSamplePts<=1440),
                %number of minutes in 24 hours
                numSamplePts = 1440;
            end;
            line3 = fgets(fID); %Lines 3 and 4 are discarded.
            line4 = fgets(fID);
            
            allSamplePts_vec = NaN(numSamplePts,1);
            timeptsZT_datevec = zeros(numSamplePts,6);
            timeptsZT_datevec(:,1) = dateVec(1); %dateVec contains the date of the channel file (first line of the channel data.
            timeptsZT_datevec(:,2) = dateVec(2);
            timeptsZT_datevec(:,3) = dateVec(3);
            timeptsZT_datenum = zeros(numSamplePts,1);
            
            for(ti = 1:numSamplePts),
                samplesPerMin = str2double(fgets(fID));
                allSamplePts_vec(ti) = samplesPerMin;
                %Saving the minutes
                minute_time = mod(ti,60); %This is in ZT time, not absolute time, since DAMFileScan has already converted things into ZT0.
                %Saving the hours
                hr_time = round(ti/60);
                timeptsZT_datevec(ti,4:5) = [hr_time minute_time];
                %Just to make sure, want to convert the time into datenum so that I can sort later.
                timeptsZT_datenum(ti) = datenum(timeptsZT_datevec(ti,:));
            end;
            % What is sort exactly? 
            [sortedTimes, sortedIndices] = sort(timeptsZT_datenum);
            timeptsZT_sortedDatenum = sortedTimes;
            allSamplePts_sortedVec = allSamplePts_vec(sortedIndices);
            channelDatByDay{fi,1} = timeptsZT_sortedDatenum;
            channelDatByDay{fi,2} = allSamplePts_sortedVec;
            datenumList(fi) = timeptsZT_sortedDatenum(1);
            fclose(fID);
            %         end; %Have saved all of the samplePts in the file/day in question in the relevant slot in channelDatByDay{fi,1};
        end; %Have read all files that match the string format for the channel number in question.
        
        [sortedTimes,sortedIndices] = sort(datenumList,'ascend');
        channelDatByDay_unsorted = channelDatByDay;
        for(si = 1:numel(sortedIndices)),
            channelDatByDay{si,1} = channelDatByDay_unsorted{sortedIndices(si),1};
            channelDatByDay{si,2} = channelDatByDay_unsorted{sortedIndices(si),2};
        end;
    else,
        %DamFiles were saved in a multi-day format.
        %         try,
        if(size(allFiles,1)==1),
            filename = allFiles(1).name;
            display(['Loading ' filename]);
            fID = fopen(filename);
        else,
            ME = MException('MyComponent:noSuchVariable', ...
                'Could not find files of the format %s',channelNameFormat);
            %         'Variable %s not found',str);
            throw(ME)
        end;
        %         catch,
        %             display(['Could not find files of the format ' channelNameFormat]);
        %             pause;
        % %         end;
        %
        %         end;
        lineFileDate = fgets(fID);
        spaceIndices = strfind(lineFileDate,' ');
        consecutiveSpaceSubIndices = diff(spaceIndices);
        dateStartIndex = find(consecutiveSpaceSubIndices>1,1,'first');
        dateString = lineFileDate(spaceIndices(consecutiveSpaceSubIndices(dateStartIndex)):end);
%         dateString = lineFileDate(15:end);
        dateVec = datevec(dateString);
        
        numSamplePts = str2double(fgets(fID));
        line3 = fgets(fID); %Lines 3 and 4 are discarded.
        line4 = fgets(fID);
        
        allSamplePts_vec = NaN(numSamplePts,1);
        timeptsZT_datevec = zeros(numSamplePts,6);
        timeptsZT_datevec(:,1) = dateVec(1); %dateVec contains the date of the channel file (first line of the channel data).
        timeptsZT_datevec(:,2) = dateVec(2);
        timeptsZT_datevec(:,3) = dateVec(3);
        timeptsZT_datenum = zeros(numSamplePts,1);
        fi = 1;
        for(ti = 1:numSamplePts),
            samplesPerMin = str2double(fgets(fID));
            allSamplePts_vec(ti) = samplesPerMin;
            minute_time = mod(ti,60); %This is in ZT time, not absolute time, since DAMFileScan has already converted things into ZT0.
            hr_time = round(ti/60);
            timeptsZT_datevec(ti,4:5) = [hr_time minute_time];
            %Just to make sure, want to convert the time into datenum so that I can sort later.
            timeptsZT_datenum(ti) = datenum(timeptsZT_datevec(ti,:))+fi-1;
            %             end;
            if(mod(ti,1440)==0),
                [sortedTimes, sortedIndices] = sort(timeptsZT_datenum(ti-1440+1:ti));
                allSamplePts_vecThisDay = allSamplePts_vec(ti-1440+1:ti);
                timeptsZT_sortedDatenum = sortedTimes;
                %                 allSamplePts_sortedVec = allSamplePts_vecThisDay(sortedIndices);
                channelDatByDay{fi,1} = timeptsZT_sortedDatenum;
                channelDatByDay{fi,2} = allSamplePts_vecThisDay; %allSamplePts_sortedVec;
                datenumList(fi) = timeptsZT_sortedDatenum(1);
                fi = fi+1;
                %                 timeptsZT_datenum = timeptsZT_datenum+1;
            end;
        end;
        fclose(fID);
        %         end;
        %         %Don't need to sort since DamFileScan already took care of that
        %         for us.
        %         [sortedTimes,sortedIndices] = sort(datenumList,'ascend');
        %         channelDatByDay_unsorted = channelDatByDay;
        %         for(si = 1:numel(sortedIndices)),
        %             channelDatByDay{si,1} = channelDatByDay_unsorted{sortedIndices(si),1};
        %             channelDatByDay{si,2} = channelDatByDay_unsorted{sortedIndices(si),2};
        %         end;
    end;
    allChannelDatByDay{csubi} = channelDatByDay; %number of rows in this cell array match up with the number of channels.
end;