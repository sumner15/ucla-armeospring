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
filename = celldir(['AROM' '*.csv']);

%choosing session by prompt
sessionID = 0;      
while sessionID <=0 || sessionID > size(filename,2)     %%nxm -> size(filename,2) gives m
    disp(['This subject has ' num2str(size(filename,2)) ' AROM sessions available.']);
    sessionID = input('type the session number you would like analyzed: ','s');
    sessionID = str2double(sessionID);
end

filename = filename{sessionID};  
disp(['Loading ' filename '...']); 
%data = importdata(filename);
delimiterIn = ';';
headerlinesIn = 12;
start = importdata(filename,delimiterIn,headerlinesIn);

e1 = size(start.data,1)+size(start.textdata,1)+1;         % e# is a row in the csv file that an event occurs
ShoulderFEinit = importdata(filename,delimiterIn,e1);  

e2 = size(ShoulderFEinit.data,1)+e1;
ShoulderFEpose = importdata(filename,delimiterIn,e2);

e3 = size(ShoulderFEpose.data,1)+e2;
ShoulderFEmeas = importdata(filename,delimiterIn,e3);

e4 = size(ShoulderFEmeas.data,1)+e3;
ShoulderAApose = importdata(filename,delimiterIn,e4);

e5 = size(ShoulderAApose.data,1)+e4;
ShoulderAAmeas = importdata(filename,delimiterIn,e5);

e6 = size(ShoulderAAmeas.data,1)+e5;
ShoulderRpose = importdata(filename,delimiterIn,e6);

e7 = size(ShoulderRpose.data,1)+e6;
ShoulderRmeas = importdata(filename,delimiterIn,e7);

e8 = size(ShoulderRmeas.data,1)+e7;
ElbowFEpose = importdata(filename,delimiterIn,e8);

e9 = size(ElbowFEpose.data,1)+e8;
ElbowFEmeas = importdata(filename,delimiterIn,e9);

e10 = size(ElbowFEmeas.data,1)+e9;
ElbowPSpose = importdata(filename,delimiterIn,e10);

e11 = size(ElbowPSpose.data,1)+e10;
ElbowPSmeas = importdata(filename,delimiterIn,e11);

e12 = size(ElbowPSmeas.data,1)+e11;
WristFEpose = importdata(filename,delimiterIn,e12);

e13 = size(WristFEpose.data,1)+e12;
WristFEmeas = importdata(filename,delimiterIn,e13);

data = [start.data;ShoulderFEinit.data;ShoulderFEpose.data;ShoulderFEmeas.data;ShoulderAApose.data;
    ShoulderAAmeas.data;ShoulderRpose.data;ShoulderRmeas.data;ElbowFEpose.data;
    ElbowFEmeas.data;ElbowPSpose.data;ElbowPSmeas.data;WristFEpose.data;WristFEmeas.data];

disp('done');

clear ShoulderFEinit ShoulderFEpose ShoulderFEmeas ShoulderAApose ShoulderAAmeas ShoulderRpose
clear ShoulderRmeas ElbowFEpose ElbowFEmeas ElbowPSpose ElbowPSmeas WristFEpose WristFEmeas


%% %%%%%%%% parsing subject data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
titles = start.textdata(11,:);
clear start
%timeStamp = data.textdata(2:length(data.textdata),1);
%timeStamp = cell2mat(timeStamp);        %converting timeStamp to double  
%dateStamp = zeros(length(timeStamp),6); %creating matlab date stamp array
%dateStamp(:,1) = 2014; dateStamp(:,2) = 01; dateStamp(:,3) = 01; 
%dateStamp(:,4) = str2num(timeStamp(:,1:2));      %hour   %%str2num converts char to double
%dateStamp(:,5) = str2num(timeStamp(:,4:5));      %minute
%dateStamp(:,6) = str2num(timeStamp(:,7:12));     %second
%trialTime = zeros(length(dateStamp),1); %computing elapsed time vector
%trialElap = trialTime;

sampleTime = data(:,1);
data(1,1) = 0;
for i = 2:length(data)
    data(i,1) = data(i-1,1)+(sampleTime(i,1)-sampleTime(i-1,1));
end         
clear i

%% %%%%%%%%% parsing sub-trials  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PoseRow = [e2-12,e4-12,e6-12,e8-12,e10-12,e12-12];
MeasRow = [e3-12,e5-12,e7-12,e9-12,e11-12,e13-12];
clear e1 e2 e3 e4 e5 e6 e7 e8 e9 e10 e11 e12 e13
trials = 6; 
trialData = cell(1,trials);         %creating vars
%newTrialInd = ones(1,trials);                   %indexing new trials %%creating array of all 1s
%newTrialInd(1,2:trials) = find(trialElap>.99);  %%returning indices of trialElap that's greater than .99s. So in CIW 1, newTrialInd=[1,1409,2799,4595,5978,7378]
                                             
for i = 1:trials                                 %filling data into cells    
    if i<6
        trialData{i} = data(MeasRow(i):(PoseRow(i+1)-1),:);    
    else
        trialData{i} = data(MeasRow(i):end,:);
    end 
end                                                %data is split into the 6 trials, trialData[1:6]
clear i 

%% %%%%%%%%% plotting data reult %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
trialNames = {'Shoulder flex/extension','Shoulder ab/adduction','Shoulder rotation',...
    'Elbow flexion/extension','Forearm pro/supination','Wrist flex/extension'};

Joint_Positions = figure(1);    %plotting joint positions for each trial
suptitle(strcat(subjectID,' AROM Joint Displacement Across Trials'));
for i = 1:trials
    subplot(2,3,i); 
    plot(trialData{i}(:,1),trialData{i}(:,17:22),'LineWidth',2);    
    title(trialNames(i),'FontSize',16); 
    xlabel('Trial Time (sec)','FontSize',15); 
    ylabel('Joint Positions','FontSize',15);    
end
%sizing to screen (fullscreen view)
scrsz = get(0,'ScreenSize'); set(Joint_Positions,'Position',scrsz)
%legend(titles(5:12),'Location','Best')
legend('Shoulder ab/adduction','Shoulder flex/extension','Shoulder rotation','Elbow flexion/extension','Forearm pro/supination','Wrist flex/extension')
%[~, hobj, ~, ~] = legend({'Shoulder ab/adduction','Shoulder flex/extension','Shoulder rotation','Elbow flexion/extension','Forearm pro/supination','Wrist flex/extension');
%hl = findobj(hobj,'type','line');
%set(hl,'LineWidth',2);
%ht = findobj(hobj,'type','text');
%set(ht,'FontSize',12);

clear i Joint_Positions hobj

%% %%%%%%%%% calculating displacements %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%calculating min and max angles and max displacement
maxAngles = NaN(6,6); minAngles = NaN(6,6);
for trial = 1:6
    maxAngles(trial,:) = max(trialData{trial}(:,17:22));
    minAngles(trial,:) = min(trialData{trial}(:,17:22));    
end
maxDisps = maxAngles - minAngles;
 
% creating printable version for command window
cellMaxDisps = zeros(size(maxDisps)+1);
cellMaxDisps(2:end,2:end) = maxDisps;
cellMaxDisps = num2cell(cellMaxDisps);
for trial = 1:6
    cellMaxDisps{trial+1,1} = trialNames{1,trial}; end
for joint = 17:22
    cellMaxDisps{1,joint-3} = titles{1,joint}; end
open('cellMaxDisps');

% plotting maximum displacements by trial
Max_Disps = figure(2);
set(Max_Disps,'Position',scrsz)
plot(maxDisps,'x','LineWidth',7);
title(strcat(subjectID,' Maximum Displacement'))
ylabel('Maximum Displacement','FontSize',15); set(gca,'XTickLabel',trialNames,'FontSize',15)
%legend(titles(5:12),'Location','Best');
legend('Shoulder ab/adduction','Shoulder flex/extension','Shoulder rotation','Elbow flexion/extension','Forearm pro/supination','Wrist flex/extension')
% [~, hobj, ~, ~] = legend({'Inner Shoulder','Outer Shoulder','Upper Shoulder','Elbow','Forearm','Pro-/Supination','Flex-/Extension','Grip'},'Fontsize',12,'Location','Best');
% hl = findobj(hobj,'type','line');
% set(hl,'LineWidth',7);
% ht = findobj(hobj,'type','text');
% set(ht,'FontSize',12);

for i = 1:numel(maxDisps)
   text(i-6*(ceil(i/6)-1)+0.1, maxDisps(i),num2str(maxDisps(i)));
end
xlim([0.5 6.5])

clear i trial joint Max_Disps scrsz
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd(homePath)

