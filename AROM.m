%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  This script analyzes the output of the ArmeoSpring %%%
%%%  AROM test, and plots results as needed             %%%
%%%                                                     %%%
%%%  Author: Sumner Norman                              %%%
%%%  Last Updated: Jun 06 2014                          %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all; homePath = cd; 


%% %%%%%%%% loading subject data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath(homePath);
disp('--------------------AROM Analysis--------------------');

%choosing subject ID by prompt
subjectID = input('type the subject ID in the form AAA: ','s');
cd(['data/' subjectID]);
filename = celldir(['ARom' '*.csv']);

%choosing session by prompt
sessionID = 0;      
while sessionID <=0 || sessionID > size(filename,2)
    disp(['This subject has ' num2str(size(filename,2)) ' AROM sessions available.']);
    sessionID = input('type the session number you would like analyzed: ','s');
    sessionID = str2double(sessionID);
end

filename = filename{sessionID};  
disp(['Loading ' filename '...']); 
data = importdata(filename);
disp('done');

%% %%%%%%%% parsing subject data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
titles = data.textdata(1,:);
timeStamp = data.textdata(2:length(data.textdata),1);
timeStamp = cell2mat(timeStamp);        %converting timeStamp to double
dateStamp = zeros(length(timeStamp),6); %creating matlab date stamp array
dateStamp(:,1) = 2014; dateStamp(:,2) = 01; dateStamp(:,3) = 01; 
dateStamp(:,4) = str2num(timeStamp(:,1:2));      %hour
dateStamp(:,5) = str2num(timeStamp(:,4:5));      %minute
dateStamp(:,6) = str2num(timeStamp(:,7:12));     %second
trialTime = zeros(length(dateStamp),1); %computing elapsed time vector
trialElap = trialTime;
for i = 2:length(trialTime)
    trialTime(i) = etime(dateStamp(i,:),dateStamp(i-1,:))+trialTime(i-1);        
    trialElap(i) = trialTime(i)-trialTime(i-1);
end
data = [trialTime data.data];
clear dateStamp timeStamp trialTime i

%% %%%%%%%%% parsing sub-trials  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
trials = 6; trialData = cell(1,trials);         %creating vars
newTrialInd = ones(1,trials);                   %indexing new trials
newTrialInd(1,2:trials) = find(trialElap>0.05);

for i = 1:trials-1                              %filling data into cells    
    trialData{i} = data(newTrialInd(i):newTrialInd(i+1)-1,:);    
end
trialData{trials} = data(newTrialInd(trials):length(data),:);
clear i 

%% %%%%%%%%% plotting data reult %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
trialNames = {'Shoulder up/dn','Shoulder in/out','Shoulder rotation',...
    'Elbow rotation','Pro/Supination','Flex/Extension'};

Joint_Positions = figure(1);    %plotting joint positions for each trial
for i = 1:trials
    subplot(2,3,i); 
    plot(trialData{i}(:,1),trialData{i}(:,5:12));
    title(trialNames(i),'FontSize',16); 
    xlabel('Trial Time (sec)','FontSize',12); 
    ylabel('Joint Positions','FontSize',12);    
end
%sizing to screen (fullscreen view)
scrsz = get(0,'ScreenSize'); set(Joint_Positions,'Position',scrsz)
legend(titles(5:12),'Location','Best')

clear i Joint_Positions scrsz

%% %%%%%%%%% calculating displacements %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%calculating min and max angles and max displacement
maxAngles = NaN(6,8); minAngles = NaN(6,8);
for trial = 1:6
    maxAngles(trial,:) = max(trialData{trial}(:,5:12));
    minAngles(trial,:) = min(trialData{trial}(:,5:12));    
end
maxDisps = maxAngles - minAngles;
 
% creating printable version for command window
cellMaxDisps = zeros(size(maxDisps)+1);
cellMaxDisps(2:end,2:end) = maxDisps;
cellMaxDisps = num2cell(cellMaxDisps);
for trial = 1:6
    cellMaxDisps{trial+1,1} = trialNames{1,trial}; end
for joint = 5:12
    cellMaxDisps{1,joint-3} = titles{1,joint}; end
open('cellMaxDisps');

clear trial joint
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd(homePath)

