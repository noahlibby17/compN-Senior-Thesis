%function CompN_Test()

% Name: Senior Project Competition Learning Phase
% Author: Noah Libby
% Thanks to Justin Hulbert, Peter Scarfe, Zall Hirschstein, and Jacob Libby for code help and inspiration
% 
% Dependencies:
% *CompN_Test_RetrievalPractice.m
% *EditDist.m 
% *GetEchoStringVertRedraw.m


%

%% Figure out which computer we're using

computer = 'linux';

try
    if strcmp(computer, 'linux')
        WORKING_DIR = '/home/mdynamics/Desktop/noahSPROJ';
    elseif strcmp(computer, 'windows')
        WORKING_DIR = '';
    end 
catch
    WORKING_DIR = '/home/mdynamics/Desktop/noahSPROJ';
end

sca

cd(WORKING_DIR)

% Check we're in the right directory
assert(logical(exist('./stimuli','dir')),...
    sprintf('(*) "stimuli" directory does not exisit in: %s',pwd));

%% Set up Psychtoolbox
% Clear workspace
sca;
close all;
clearvars;

% Version Number
VERSION_NO = 1.0;

% Set the key code for the OS
KbName('UnifyKeyNames');
if ismac
    return_key = 40;
elseif isunix
    return_key = 37;
    escape_key = 10;
elseif ispc
    return_key = 13;
end;

% Default PTB settings
PsychDefaultSetup(2);

DEBUG_ME = 0;
if DEBUG_ME == 1
    PsychDebugWindowConfiguration(0,0.5) %set background to semi-transparent to see command window
end

% Reseed the random-number generator for each experiment run
rng('shuffle'); %this is the new way that sets the initial seed using date/time

Hz = 60; %the frame rate of the monitor to be used for the main phase; at 60Hz refresh (standard for LCD), that's 1/60Hz = ~16.67ms per frame; so 116.7ms is 7 frames | 133.3ms is 8 frames use this to establish the jitter time\

%% Collect subject information and prepare stim/output files

HideCursor;

prompt = {'Enter subject number:', 'CB', 'Are there trigs?'}; %description of fields
defaults = {'','1-2', '0-1'}; %you can put in default responses
answer = inputdlg(prompt, 'Subject Number',1.4,defaults); %opens dialogue
SUBJECT = answer{1,:}; %Extract Subject Number
CB = answer{2,:}; %Indicates the counterbalancing condition for sound play (1-18; see sound_cond_lookup below)
TRIGS = answer{3,:};%Are there trigs? 1 = yes, 0 = no
c = clock; %Current date and time as date vector. [year month day hour minute seconds]

% This erases any spaces in the inputs
SUBJECT = strrep(SUBJECT,' ','');
CB = strrep(CB,' ','');
TRIGS = strrep(TRIGS, ' ','');

% Prompts experimenter to double-check subject information - make experimenter
% enter data in TWICE and checks those against eachother
answer2 = inputdlg(prompt, 'Subject Number',1.4,defaults); %opens dialogue
SUBJECT2 = answer2{1,:}; %Extract Subject Number
CB2 = answer2{2,:}; %Indicates the counterbalancing condition for sound play (1-18; see sound_cond_lookup below)
TRIGS2 = answer2{3,:}; %Are there trigs?

% This erases any spaces in the inputs
SUBJECT2 = strrep(SUBJECT2,' ','');
CB2 = strrep(CB2,' ','');
TRIGS2 = strrep(TRIGS2,' ','');

% Creates arrays for both inputs
aarray = [SUBJECT, CB, TRIGS];
barray = [SUBJECT2, CB2, TRIGS2];

% Check if the arrays are equal
doublecheck = isequal(aarray,barray);
try
    assert(isequal(doublecheck,1),'Invalid participant information. Please enter again.');
catch
    % Error. Close screen, show cursor, rethrow error:
    ShowCursor;
    Screen('CloseAll');
    %clc; %clear command window
    fclose('all');
    Priority(0);
    psychrethrow(psychlasterror);
end

%% ensure that this is saving properly
baseName=[SUBJECT '_CB' CB '_' mfilename() '_' num2str(c(2)) '_' num2str(c(3))]; %makes unique output filename for this phase

%% Set timing constants
%% Set up stimulus file (load in one if it already exists)

stim_filename = ['results/subject_sets/CompN_Test_' SUBJECT '_stims.mat'];

if exist(stim_filename,'file') == 2
    % If stimulus set already exists for this subect, read it in.
    fprintf('(*) stim file exists!: %s\n(*) reading it in ...\n',stim_filename);
    load(stim_filename); % 'stimuli' variable
    
    ItemMatrix = stimuli.ItemMatrix;
    ItemMatrix_TwoMembers = stimuli.ItemMatrix_TwoMembers;
    ItemMatrix_SixMembers = stimuli.ItemMatrix_SixMembers;
    ItemMatrix_TwoMembers_Random = stimuli.ItemMatrix_TwoMembers_Random;
    ItemMatrix_SixMembers_Random = stimuli.ItemMatrix_SixMembers_Random;
    ItemMatrix_Full = stimuli.ItemMatrix_Full;
    ItemMatrix_Learn_Random = stimuli.ItemMatrix_Learn_Random;
    SHUFFLEPOOL = stimuli.SHUFFLEPOOL;
    
else
    
    % If stimulus file does not exist, make a new one
    created_time = datestr(now,0);
    
    %% Generate stimulus schedules
    
    % Word pool - GORILLA is used for the example 
    POOL = {'Crown', 'Doll', 'Igloo', 'Journal', 'Kite',...
        'Marble', 'Necklace', 'Robot', 'Sunglasses', 'Train'};
    
    %two syllable, six letters, uncommon < 50 freq. on 1997 SSA names
    %(double check that it's actually frequency on SSA website)
    
    % Put images and names for the other script in the other script
    %A_NAMES = {'Aldair', 'Ashten', 'Andrei', 'Arline', 'Austyn', 'Azlynn'}; %Antelope - GOOD
    %B_NAMES = {'Booker', 'Briant', 'Bailee', 'Bethel', 'Bintou', 'Blayke'}; %Bear - GOOD
     C_NAMES = {'Cormac', 'Curran', 'Caston', 'Chayla', 'Cyndel', 'Claira'}; %Crown - GOOD
     D_NAMES = {'Dorain', 'Dustan', 'Decker', 'Daylin', 'Dylann', 'Diedre'}; %Doll - GOOD
    %E_NAMES = {'Elbert', 'Eshawn', 'Easten', 'Ellyse', 'Erynne', 'Evette'}; %Elephant - GOOD
    %F_NAMES = {'Felton', 'Furkan', 'Frandy', 'Finley', 'Foster', 'Farren'}; %Fox - GOOD
    %G_NAMES = {'Gerrit', 'Gunter', 'Gilmar', 'Grisel', 'Goldie', 'Gaelyn'}; %Giraffe - GOOD  
    %H_NAMES = {'Hisham', 'Hunner', 'Hykeem', 'Hailee', 'Hollin', 'Hettie'}; %Horse - GOOD
     I_NAMES = {'Irvine', 'Issaac', 'Imraan', 'Ingris', 'Itzell', 'Ivorie'}; %Igloo - GOOD
     J_NAMES = {'Jabril', 'Jerell', 'Juwaan', 'Jissel', 'Jhayla', 'Jolena'}; %Journal - GOOD
     K_NAMES = {'Kellan', 'Kyland', 'Koltin', 'Khayla', 'Karsyn', 'Kirsti'}; %Kite - GOOD
    %L_NAMES = {'Landin', 'Lucien', 'Lorenz', 'Lilith', 'Lynsie', 'Leilah'}; %Lion - GOOD
     M_NAMES = {'Mychal', 'Murray', 'Monroe', 'Merrit', 'Mirsha', 'Maddux'}; %Marble - GOOD
     N_NAMES = {'Noland', 'Newell', 'Nuchem', 'Nycole', 'Nadyne', 'Nishat'}; %Necklace - GOOD
    %O_NAMES = {'Oakley', 'Osmond', 'Othman', 'Odette', 'Oonagh', 'Orchid'}; %Otter - GOOD
    %P_NAMES = {'Parish', 'Puneet', 'Phelan', 'Prisca', 'Porcha', 'Perrin'}; %Pig - GOOD
     R_NAMES = {'Randon', 'Rustin', 'Rizwan', 'Roslyn', 'Rhiley', 'Reegan'}; %Robot - GOOD
    S_NAMES = {'Shamus', 'Stevin', 'Salman', 'Sidnee', 'Skylyn', 'Sondra'}; %Sunglasses - GOOD
     T_NAMES = {'Trevis', 'Thayne', 'Tyrome', 'Torrey', 'Taylee', 'Tenzin'}; %Train - GOOD
    %Z_NAMES = {'Zuhayr', 'Zoltan', 'Zander', 'Zissel', 'Zeinab', 'Zhanee'}; %Zebra - GOOD
    
    % Shuffle the Item orders for condition assignment
    SHUFFLEPOOL = randperm(length(POOL));
    
    % Create the two groups of family size
    TwoMemberFam = POOL(SHUFFLEPOOL(1:length(POOL)/2));
    SixMemberFam = POOL(SHUFFLEPOOL(length(POOL)/2+1:end));
    
    % Concatenate into one matrix
    % Row 1 = TwoMemberFam; Row 2 = SixMemberFam
    ItemMatrix = vertcat(TwoMemberFam,SixMemberFam);
    ItemMatrix_Reshaped = reshape(ItemMatrix, [], 1);
    ItemMatrix_TwoMembers = cell(length(TwoMemberFam)*2, 6); % save data for two member photo locations and names
    ItemMatrix_SixMembers = cell(length(SixMemberFam)*6, 6); % save data for six member photo locations and names
    ItemMatrix_Full = cell(length(TwoMemberFam)*2 + length(SixMemberFam)*6, 6); % save data for ALL photo locations and names

    init_two = 1; % keep track of iterations for matcat
    init_six = 1; % keep track of iterations for matcat
    
    % Copy Item photos to relevant folders/get their names - iterate through each Item
    for elm = TwoMemberFam
        
        member = char(elm);
        
        % RANDOMLY select two numbers between one and six to determine
        % which pictures/names will be used for the two member family
        numarray = randperm(6,2);
        two_one_index = numarray(1);
        two_two_index = numarray(2);
        
        % Find the image files
        two_1_photo = ['/home/mdynamics/Desktop/noahSPROJ/stimuli/items/', member, '/', member, num2str(two_one_index), '/', member, num2str(two_one_index), '.jpg'];
        two_2_photo = ['/home/mdynamics/Desktop/noahSPROJ/stimuli/items/', member, '/', member, num2str(two_two_index), '/', member, num2str(two_two_index), '.jpg'];
        
        % Create a cell array of the images themselves
        Two_1_Read = imread(two_1_photo);
        Two_2_Read = imread(two_2_photo);
        %ImagesRead_TwoMembers = vertcat(ImagesRead_TwoMembers, [Two_1_Read, Two_2_Read]);
        
        % Randomize the names and create lookup matrix
        target_name_array = eval([member(1), '_NAMES']);
        name1 = char(target_name_array(two_one_index));
        name2 = char(target_name_array(two_two_index));
        Temp_Mat = {member, name1, two_1_photo, Two_1_Read, 0, 2; member, name2, two_2_photo, Two_2_Read, 0, 2}; % generates cell array for this loop
        indices = (init_two*2)-1; % gets rows to paste new data into
        ItemMatrix_TwoMembers(indices:indices+1, 1:6) = Temp_Mat; %copies temp matrix into full set matrix
        
        % Copy the files using those indices to the stimulus folder for
        % the current participant
        two_one_source = ['/home/mdynamics/Desktop/noahSPROJ/stimuli/items/', member, '/', member, num2str(two_one_index)];
        two_two_source = ['/home/mdynamics/Desktop/noahSPROJ/stimuli/items/', member, '/', member, num2str(two_two_index)];
        destination = ['/home/mdynamics/Desktop/noahSPROJ/results/subject_sets/', num2str(SUBJECT), '/stimuli/lowCOMP/', member, '/'];
        mkdir(destination);
        copyfile(two_one_source, destination);
        copyfile(two_two_source, destination);
        
        init_two = init_two + 1;
        disp(init_two); % vis. for debug
        
    end
    
    % Randomize images/names for high comp families
    for elm = SixMemberFam
        
        member = char(elm);
        
        % Randomize the order of the six member families
        numarray = randperm(6,6);
        six_one_index = numarray(1);
        six_two_index = numarray(2);
        six_three_index = numarray(3);
        six_four_index = numarray(4);
        six_five_index = numarray(5);
        six_six_index = numarray(6);
        
        % Find the image files
        six_1_photo = ['/home/mdynamics/Desktop/noahSPROJ/stimuli/items/', member, '/', member, num2str(six_one_index), '/', member, num2str(six_one_index), '.jpg'];
        six_2_photo = ['/home/mdynamics/Desktop/noahSPROJ/stimuli/items/', member, '/', member, num2str(six_two_index), '/', member, num2str(six_two_index), '.jpg'];
        six_3_photo = ['/home/mdynamics/Desktop/noahSPROJ/stimuli/items/', member, '/', member, num2str(six_three_index), '/', member, num2str(six_three_index), '.jpg'];
        six_4_photo = ['/home/mdynamics/Desktop/noahSPROJ/stimuli/items/', member, '/', member, num2str(six_four_index), '/', member, num2str(six_four_index), '.jpg'];
        six_5_photo = ['/home/mdynamics/Desktop/noahSPROJ/stimuli/items/', member, '/', member, num2str(six_five_index), '/', member, num2str(six_five_index), '.jpg'];
        six_6_photo = ['/home/mdynamics/Desktop/noahSPROJ/stimuli/items/', member, '/', member, num2str(six_six_index), '/', member, num2str(six_six_index), '.jpg'];
        
        % Create a cell array of the images themselves
        
        Six_1_Read = imread(six_1_photo);
        Six_2_Read = imread(six_2_photo);
        Six_3_Read = imread(six_3_photo);
        Six_4_Read = imread(six_4_photo);
        Six_5_Read = imread(six_5_photo);
        Six_6_Read = imread(six_6_photo);
        
        % Randomize the names and create lookup matrix
        target_name_array = eval([member(1), '_NAMES']);
        name1 = char(target_name_array(six_one_index));
        name2 = char(target_name_array(six_two_index));
        name3 = char(target_name_array(six_three_index));
        name5 = char(target_name_array(six_five_index));
        name4 = char(target_name_array(six_four_index));
        name6 = char(target_name_array(six_six_index));
        Temp_Mat = {member, name1, six_1_photo, Six_1_Read, 0, 6; member, name2, six_2_photo, Six_2_Read, 0, 6; member, name3, ...
            six_3_photo, Six_3_Read, 0, 6; member, name4, six_4_photo, Six_4_Read, 0, 6; member, name5, six_5_photo, Six_5_Read, 0, 6; member, ...
            name6, six_6_photo, Six_6_Read, 0, 6}; % generates cell array for this loop
        indices = (init_six * 6)-5; % gets rows to paste new data into
        ItemMatrix_SixMembers(indices:indices+5, 1:6) = Temp_Mat; %copies temp matrix into full set matrix
        
        % Copy the files using those indices to the stimulus folder for the current participant
        six_one_source = ['/home/mdynamics/Desktop/noahSPROJ/stimuli/items/', member, '/', member, num2str(six_one_index)];
        six_two_source = ['/home/mdynamics/Desktop/noahSPROJ/stimuli/items/', member, '/', member, num2str(six_two_index)];
        six_three_source = ['/home/mdynamics/Desktop/noahSPROJ/stimuli/items/', member, '/', member, num2str(six_three_index)];
        six_four_source = ['/home/mdynamics/Desktop/noahSPROJ/stimuli/items/', member, '/', member, num2str(six_four_index)];
        six_five_source = ['/home/mdynamics/Desktop/noahSPROJ/stimuli/items/', member, '/', member, num2str(six_five_index)];
        six_six_source = ['/home/mdynamics/Desktop/noahSPROJ/stimuli/items/', member, '/', member, num2str(six_six_index)];
        destination = ['/home/mdyanmics/Desktop/noahSPROJ/results/subject_sets/', num2str(SUBJECT), '/stimuli/highCOMP/', member, '/'];
        mkdir(destination);
        
        copyfile(six_one_source, destination);
        copyfile(six_two_source, destination);
        copyfile(six_three_source, destination);
        copyfile(six_four_source, destination);
        copyfile(six_five_source, destination);
        copyfile(six_six_source, destination);
        
        init_six = init_six + 1;
        disp(init_six);
        
    end
    
    ItemMatrix_Full(1:(length(TwoMemberFam)*2), 1:6) = ItemMatrix_TwoMembers;
    ItemMatrix_Full(((length(TwoMemberFam)*2+1):(length(TwoMemberFam)*2+length(SixMemberFam)*6)), 1:6) = ItemMatrix_SixMembers;
    
    %% Save stimulus schedule/results
    
    subject.SUBJECT = SUBJECT; % where do all of these write to?
    subject.CB = CB;
    
    task.DEBUG_ME = DEBUG_ME;
    task.VERSION_NO = VERSION_NO;
    %task.STUDY_DUR = STUDY_DUR;
    %task.ITI = ITI;
    %task.ISI = ISI;
    task.Hz = Hz;
    
    stimuli.filename = stim_filename;
    stimuli.created = created_time;
    stimuli.POOL = POOL;
    stimuli.SHUFFLEPOOL = SHUFFLEPOOL;
    stimuli.ItemMatrix = ItemMatrix;
    stimuli.ItemMatrix_TwoMembers = ItemMatrix_TwoMembers;
    stimuli.ItemMatrix_SixMembers = ItemMatrix_SixMembers;
    stimuli.ItemMatrix_TwoMembers_Random = ItemMatrix_TwoMembers(randperm(size(ItemMatrix_TwoMembers,1)),:);
    stimuli.ItemMatrix_SixMembers_Random = ItemMatrix_SixMembers(randperm(size(ItemMatrix_SixMembers,1)),:);
    stimuli.ItemMatrix_Full = ItemMatrix_Full;
    stimuli.ItemMatrix_Learn_Random = ItemMatrix_Reshaped(randperm(size(ItemMatrix_Reshaped, 1)), :);
    %stimuli.ItemMatrix_Test_Random = Defined Later On;
    %other stimuli.subStructures to be assigned later
        
    save(stim_filename,'subject','task','stimuli'); % response field will be added after CompN_RetrievalPractice.m is run
    
end %if not loading in preexisting stimulus file
%% Establish connection to Emotiv Pro software and Emotiv EPOC+ EEG headband

if TRIGS == 0
    disp('NO TRIGGERS BEING USED')
elseif TRIGS == 1
    disp('TRIGGERS IN USE')
    trig(0) %INITIALIZING THE TRIGGERS
end

%% Open screen window

% Get the screen numbers
screens = Screen('Screens');

% Draw to the external screen if avaliable
screenNumber = max(screens);

% Get size of screen
[s_width, s_height]=Screen('WindowSize', screenNumber); %also found in windowRect below

% Get value of color black & white, set other RGB color values for later:
black = BlackIndex(screenNumber);
white = WhiteIndex(screenNumber);
gray = white/2;
lightgray = [220, 220, 220];
green = [0, 255, 0];
red = [255, 0, 0];
blue = [30, 144, 255]; %now Dodger Blue b/c original is too dark [0, 0, 255];
yellow = [255, 255, 0];

[window, windowRect] = PsychImaging('OpenWindow', screenNumber, white);

% Set the blend function for the screen
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Get the size of the on screen window in pixels
% For help see: Screen WindowSize?
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Get the centre coordinate of the window in pixels
% For help see: help RectCenter
[xCenter, yCenter] = RectCenter(windowRect);

%%%UNCOMMENT WHEN ACTUALLY RUNNING
% Run the sync tests
Screen('Preference', 'SkipSyncTests', 1);

flipTime = Screen('GetFlipInterval',window); %for this particular phase (not necessarily the one used in the main TNT phase)
slack = flipTime/2; % start any time-critical flip early enough to allow the flip to take place (use a halfflip); can be used to present at an exact time after a previous stimulus onset [e.g., for 500ms after t_prime, use: "tprime_onset = Screen('Flip', window, tfixation_onset + 0.500 - slack)"]

% FixationStimuli and instructions
Crosshair = '+';
expInst_text = sprintf('%s\n%s\n%s\n%s\n%s\n%s\n%s', 'Imagine that you are a preschool teacher and today is show-and-tell day.', ...
    'Students were told to bring in a specific item that starts with the same letter as their name.',...
    'As their teacher, you need to remember which student brought in each item. For each letter group,', ...
    'you will first see all of the items and student''s names presented together, then you will', ...
    'see each student and their item individually, and then you will have to guess the name of the student',...
    'that brought in a given item when shown its picture. Press "enter" to continue.');
studyInst_text = 'Now study them individually. Press "enter" to continue.';
rp_overallinst = sprintf('%s\n%s', 'Now, recall the name of each student as the items appear on the screen, one at a time.',...
    'Press "enter" to continue the instructions.');
rp_inst = sprintf('%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s', 'As each image appears on the screen in this next phase, you will be given two seconds',...
    'to think about the name of the student who it belongs to. It is important that you remain very still during this time.',...
    'After the two seconds has elapsed, you will type the name of the student on the screen.',...
    'As soon as the text appears, you may start typing. If you are unsure about the name',...
    'of the student, the letters will be slowly revealed. As soon as you are ready to make',...
    'your guess of the name, press the "spacebar" to stop the reveal of the letters.',...
    'If you do not type the name before several letters are revealed, the whole word',...
    'will be uncovered and you will be given a chance to restudy the name/image pair.',...
    'Once you are finished typing, press "enter" to continue to the next item.');

%% Start the trial run

% Set timing intervals - set these earlier? and save to file? probably.
exposure_dur = 10; % duration that exposure phase is on the screen
stim_dur = 2; % time that stimulus is on screen in the learning phase
ITI = 1; % time between trials
ISI = 1; % time betweeen stimuli
EEG_wait = 2; % time to wait for EEG to record
RP_ITI = 1; % RP phase ITI
CrossHair = '+';

%%% SIMILAR TO THE PREVIOUS LEARNING PARADIGM, YOU WILL BE EXPOSED, STUDY,
%%% and RETRIEVAL PRACTICE ITEMS

% Run main experiment
try
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % EXPOSURE, STUDY, PRACTICE %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    start_text = 'Loading experiment...';
    DrawFormattedText(window, start_text, 'center', 'center', BlackIndex(window));
    Screen('Flip', window);

    % Make textures for all of the images
    for elm = 1:length(stimuli.ItemMatrix_Full(:,1))
        
        image_texture = Screen('MakeTexture', window, stimuli.ItemMatrix_Full{elm, 4}); % make image textures - make them color?
        stimuli.ItemMatrix_Full{elm, 5} = image_texture; % save textures to fifth column in full matrix to access later
        
        save(stim_filename, 'subject', 'task', 'stimuli');
    end
    
    % Randomize the now full matrix with references to the textures
    stimuli.ItemMatrix_Test_Random = stimuli.ItemMatrix_Full(randperm(size(ItemMatrix_Full,1)),:);
    % Save it to the stimuli struct in subj file
    save(stim_filename,'subject', 'task', 'stimuli');
    
    % Set reference locations for objects
    Resized = 150; % half of the length or height for a square image
    x = s_width;
    y = s_height;

    % Establish picture locations for two member families
    positions_pict1_two = [((x/4)-Resized), ((y/2)-Resized), ((x/4)+Resized), ((y/2)+Resized)];
    positions_pict2_two = [(((x/4)*3)-Resized), ((y/2)-Resized), (((x/4)*3)+Resized), ((y/2)+Resized)];
    
    % Establish picture locations for six member families
    positions_pict1_six = [((x/6)-Resized), ((y/4)-Resized), ((x/6)+Resized), ((y/4)+Resized)];
    positions_pict2_six = [(((x/6)*3)-Resized), ((y/4)-Resized), (((x/6)*3)+Resized), ((y/4)+Resized)];
    positions_pict3_six = [(((x/6)*5)-Resized), ((y/4)-Resized), (((x/6)*5)+Resized), ((y/4)+Resized)];
    positions_pict4_six = [((x/6)-Resized), (((y/4)*3)-Resized), ((x/6)+Resized), (((y/4)*3)+Resized)];
    positions_pict5_six = [(((x/6)*3)-Resized), (((y/4)*3)-Resized), (((x/6)*3)+Resized), (((y/4)*3)+Resized)];
    positions_pict6_six = [(((x/6)*5)-Resized), (((y/4)*3)-Resized), (((x/6)*5)+Resized), (((y/4)*3)+Resized)];
    % Establish picture locations for the center of the screen
    positions_center    = [((x/2)-Resized), ((y/2)-Resized), ((x/2)+Resized), ((y/2)+Resized)];
    
    %%% START SCREEN %%%
    
    start_text = 'Press "Enter" when you are ready to begin';
    DrawFormattedText(window, start_text, 'center', 'center', BlackIndex(window));
    Screen('Flip', window);
    
    % Wait for participant response
    while 0 < 1
        [keyIsDown,~,AnswerkeyCode] = KbCheck;
        if keyIsDown && isequal(KbName(AnswerkeyCode), KbName(return_key)) == 1
            break; 
        elseif keyIsDown && isequal(KbName(AnswerkeyCode), KbName(escape_key)) == 1
            ShowCursor;
            Screen('CloseAll');
            break;
        end
    end
    
    % Instruction screen for Exposure Phase
    DrawFormattedText(window, expInst_text, 'center', 'center', BlackIndex(window));
    WaitSecs(0.5); % short delay between text displays for visual appearance
    Screen('Flip', window);
    WaitSecs(ITI);
    
    % Wait for participant response to continue
    
    while 0 < 1
        [keyIsDown,~,AnswerkeyCode] = KbCheck;
        if keyIsDown && isequal(KbName(AnswerkeyCode), KbName(return_key)) == 1
            break;
        elseif keyIsDown && isequal(KbName(AnswerkeyCode), KbName(escape_key)) == 1
            ShowCursor;
            Screen('CloseAll');
            break;
        end
    end
    DrawFormattedText(window, CrossHair, 'center', 'center', black);
    Screen('Flip', window);
    WaitSecs(1);
    
    % clear out instructions
    Screen('Flip', window);
    
    allstart = GetSecs;
    
    % Iterate through all of the species, picking a target species on each iteration to present first
    for sp = 1:length(stimuli.ItemMatrix_Learn_Random(:, 1))
        
        task_start = GetSecs;
        
        %disp(sp); % for debugging
        species = char(stimuli.ItemMatrix_Learn_Random(sp, 1));
        disp(species); % for debugging
        
        % Get ready
        commandwindow; %put the command window in focus (not editor)
        HideCursor;
        
        % Initalize
        Item_count = 0;
        
        % check to see whether 'species' is a two/six member Item
        % assign picture locations for exposure phase, accordingly
        if ismember(stimuli.ItemMatrix(1, 1), species) == 1 || ismember(stimuli.ItemMatrix(1, 2), species) == 1 || ismember(stimuli.ItemMatrix(1, 3), species) == 1 || ismember(stimuli.ItemMatrix(1, 4), species) == 1 || ismember(stimuli.ItemMatrix(1, 5), species) == 1 % if species is a two member family
            
            %%%%%%%%%%%%%%%%%%
            % EXPOSURE PHASE %
            %%%%%%%%%%%%%%%%%%
            
            disp((GetSecs-task_start));
            disp(GetSecs-allstart);
            
            helper = ismember(stimuli.ItemMatrix_TwoMembers_Random(:,1), species); % returns validation matrix with ones and zeros
            tmp_exposure_matrix = stimuli.ItemMatrix_TwoMembers_Random(helper == 1, :); % creates randomized lookup matrix for this Item based on stim.am_l_r
            
            % Randomize the two member matrix with references to the textures
            stimuli.ItemMatrix_Learn_RandomWithin.(species) = tmp_exposure_matrix(randperm(size(tmp_exposure_matrix,1)),:);
            % Save it to the stimuli struct in subj file
            save(stim_filename, 'subject', 'task', 'stimuli');
                        
            % Prepare all of the Items
           
            % Item 1
            name1 = tmp_exposure_matrix{1, 2};
            species1 = tmp_exposure_matrix{1, 1};
            fullname1 = [char(name1), '''s ', char(species1)];
            disp(fullname1); % for debugging
            [tmp_row, ~] = find(ismember(stimuli.ItemMatrix_Full(:,2), name1));
            tmp_texture_1 = stimuli.ItemMatrix_Full{tmp_row, 5};
            Screen('DrawTexture', window, tmp_texture_1, [], positions_pict1_two);
            DrawFormattedText(window, fullname1, 'center', 'center', black, [], [], [], [], [], [positions_pict1_two(1), positions_pict1_two(4), positions_pict1_two(3), positions_pict1_two(4)+30]);
            
            % Item 2
            name2 = tmp_exposure_matrix{2, 2};
            species2 = tmp_exposure_matrix{2, 1};
            fullname2 = [char(name2), '''s ', char(species2)];
            disp(fullname2); % for debugging
            [tmp_row, ~] = find(ismember(stimuli.ItemMatrix_Full(:,2), name2));
            tmp_texture_2 = stimuli.ItemMatrix_Full{tmp_row, 5};
            Screen('DrawTexture',window,tmp_texture_2, [], positions_pict2_two);
            DrawFormattedText(window, fullname2, 'center', 'center', black, [], [], [], [], [], [positions_pict2_two(1), positions_pict2_two(4), positions_pict2_two(3), positions_pict2_two(4)+30]);
            
            disp('end time');
            disp(GetSecs-allstart);
            
            % Flip to the screen
            Screen('Flip', window);
            
            trig(11); % send start trigger
            WaitSecs(exposure_dur); % replace with trial interval - keeps the stimuli up on the screen before displaying text for study phase
            trig(12); % send end trigger
            
            %%%%%%%%%%%%%%%
            % STUDY PHASE %
            %%%%%%%%%%%%%%%
            
            % Instructions for this phase
            DrawFormattedText(window, studyInst_text, 'center', 'center', black);
            Screen('Flip', window);
            WaitSecs(.5); % erase when I UNCOMMENT below block
            
            % UNCOMMENT to make participant respond to move on
            % Wait for participant response
            
            while 0 < 1
                [keyIsDown,~,AnswerkeyCode] = KbCheck;
                if keyIsDown && isequal(KbName(AnswerkeyCode), KbName(return_key)) == 1
                    break;
                elseif keyIsDown && isequal(KbName(AnswerkeyCode), KbName(escape_key)) == 1
                    ShowCursor;
                    Screen('CloseAll');
                    break;
                end
            end
            DrawFormattedText(window, CrossHair, 'center', 'center', black);
            Screen('Flip', window);
            WaitSecs(ITI);
            
            % Using the 'species' variable generated by 'sp' count in the loop of Am_L_R, study each Item/name pair for x-many seconds
            % Item 1
            Screen('DrawTexture', window, tmp_texture_1, [], positions_center); % save for rp phase
            DrawFormattedText(window, fullname1, 'center', positions_center(4)+30, black); % save for rp phase
            Screen('Flip', window);
            
            trig(21); % send start trigger
            WaitSecs(stim_dur); % change to stimulus duration
            trig(22); % send stop trigger
            
            % Fixation point
            DrawFormattedText(window, Crosshair, 'center', 'center', black);
            Screen('Flip', window);
            WaitSecs(ISI);
            
            % Item 2
            Screen('DrawTexture', window, tmp_texture_2, [], positions_center);
            DrawFormattedText(window, fullname2, 'center', positions_center(4)+30, black);
            Screen('Flip', window);
            
            trig(21); % send start trigger
            WaitSecs(stim_dur); % change to stimulus duration
            trig(22); % send stop trigger
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % RETRIEVAL PRACTICE PHASE %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Initialize marks to signify whether or not the Item has
            % been learned
            track_1 = 0;
            track_2 = 0;
            mark_1 = 0;
            mark_2 = 0;
           
            CrossHair = '+';
            
            % Present instructions for RP phase
            DrawFormattedText(window, rp_inst, 'center', 'center');
            Screen('Flip', window);
            KbStrokeWait; % wait for key press to continue
            WaitSecs(0.01);
            
            while (mark_1 == 0) || (mark_2 == 0) % while at least one is unlearned
               
                if mark_1 == 0
                    DrawFormattedText(window, CrossHair, 'center', 'center', black);
                    Screen('Flip', window);
                    WaitSecs(ISI);
                    
                    % Present image and prompt text
                    %display = [name1(1), '_________ the ', species1];
                    %DrawFormattedText(window, display, positions_center(1), positions_center(4)+30, black);
                    Screen('DrawTexture', window, tmp_texture_1, [], positions_center);
                    Screen('Flip', window);
                    
                    trig(31); % send start trigger
                    WaitSecs(EEG_wait); % Wait two seconds

                    
                    trig(32); % send stop trigger
                    
                    [marked, tracked, struct_output] = CompN_Test_RetrievalPractice(window, name1, species1, tmp_texture_1, positions_center(1), positions_center(4)+30, positions_center, black, 2, mark_1, track_1);
                    mark_1 = marked;
                    track_1 = tracked;
                    iteration_name = [name1, num2str(track_1)];
                    responses.rp.(iteration_name) = struct_output;
                    save(stim_filename, 'subject', 'task', 'stimuli', 'responses'); % save this round of responses
                end
                
                if mark_2 == 0
                    DrawFormattedText(window, CrossHair, 'center', 'center', black);
                    Screen('Flip', window);
                    WaitSecs(ISI);
                    
                    % Present image and prompt text
                    %display = [name2(1), '_________ the ', species2];
                    %DrawFormattedText(window, display, positions_center(1), positions_center(4)+30, black);
                    Screen('DrawTexture', window, tmp_texture_2, [], positions_center);
                    Screen('Flip', window);
                    
                    trig(31); % send start trigger
                    WaitSecs(EEG_wait); % Wait two seconds
                    trig(32); % send stop trigger

                    [marked, tracked, struct_output] = CompN_Test_RetrievalPractice(window, name2, species2, tmp_texture_2, positions_center(1), positions_center(4)+30, positions_center, black, 2, mark_2, track_2);
                    mark_2 = marked;
                    track_2 = tracked;
                    iteration_name = [name2, num2str(track_2)];
                    responses.rp.(iteration_name) = struct_output;
                    save(stim_filename, 'subject', 'task', 'stimuli', 'responses');
                end
                 
                %KbStrokeWait; % for testing purpose
                %sca; % for testing purposes
            end
            
            % Count the Items that have been presented
            Item_count = Item_count + 1;
            
            % Checks to see if all Items have been presented
            if Item_count == length(stimuli.ItemMatrix_Learn_Random(:, 1))
                DrawFormattedText(window, 'End of Training Phase', 'center', 'center', black);
                Screen('Flip', window);
                WaitSecs(ITI); % time to wait between exposure phase and study phase
            else
                DrawFormattedText(window,'Loading next items...', 'center', 'center', black);
                Screen('Flip', window);
                WaitSecs(ITI); % for debugging purposes, change to ITI
            end
            
        end
        
        if ismember(stimuli.ItemMatrix(2, 1), species) == 1 || ismember(stimuli.ItemMatrix(2, 2), species) == 1 || ismember(stimuli.ItemMatrix(2, 3), species) == 1 || ismember(stimuli.ItemMatrix(2, 4), species) == 1 || ismember(stimuli.ItemMatrix(2, 5), species) == 1 % if species is a six member family
            
            %%%%%%%%%%%%%%%%%%
            % EXPOSURE PHASE %
            %%%%%%%%%%%%%%%%%%
            
            disp((GetSecs-task_start));
            disp(GetSecs-allstart);
            
            helper = ismember(stimuli.ItemMatrix_SixMembers_Random(:,1), species); % returns validation matrix with ones and zeros
            tmp_exposure_matrix = stimuli.ItemMatrix_SixMembers_Random(helper == 1, :); % creates randomized lookup matrix for this Item based on stim.am_l_r
            
            % Randomize the two member matrix with references to the textures
            stimuli.ItemMatrix_Learn_RandomWithin.(species) = tmp_exposure_matrix(randperm(size(tmp_exposure_matrix,1)),:);
            % Save it to the stimuli struct in subj file
            save(stim_filename, 'subject', 'task', 'stimuli');

            % Prepare all of the Items
            
            % Item 1
            name1 = tmp_exposure_matrix{1, 2};
            species1 = tmp_exposure_matrix{1, 1};
            fullname1 = [name1, '''s ', species1];
            [tmp_row, ~] = find(ismember(stimuli.ItemMatrix_Full(:,2), name1));
            tmp_texture_1 = stimuli.ItemMatrix_Full{tmp_row, 5};
            Screen('DrawTexture', window, tmp_texture_1, [], positions_pict1_six);
            DrawFormattedText(window, fullname1, 'center', 'center', black, [], [], [], [], [], [positions_pict1_six(1), positions_pict1_six(4), positions_pict1_six(3), positions_pict1_six(4)+30]);
            
            % Item 2
            name2 = tmp_exposure_matrix{2, 2};
            species2 = tmp_exposure_matrix{2, 1};
            fullname2 = [name2, '''s ', species2];
            [tmp_row, ~] = find(ismember(stimuli.ItemMatrix_Full(:,2), name2));
            tmp_texture_2 = stimuli.ItemMatrix_Full{tmp_row, 5};
            Screen('DrawTexture',window,tmp_texture_2, [], positions_pict2_six);
            DrawFormattedText(window, fullname2, 'center', 'center', black, [], [], [], [], [], [positions_pict2_six(1), positions_pict2_six(4), positions_pict2_six(3), positions_pict2_six(4)+30]);
            
            % Item 3
            name3 = tmp_exposure_matrix{3, 2};
            species3 = tmp_exposure_matrix{3, 1};
            fullname3 = [name3, '''s ', species3];
            [tmp_row, ~] = find(ismember(stimuli.ItemMatrix_Full(:,2), name3));
            tmp_texture_3 = stimuli.ItemMatrix_Full{tmp_row, 5};
            Screen('DrawTexture', window, tmp_texture_3, [], positions_pict3_six);
            DrawFormattedText(window, fullname3, 'center', 'center', black, [], [], [], [], [], [positions_pict3_six(1), positions_pict3_six(4), positions_pict3_six(3), positions_pict3_six(4)+30]);
            
            % Item 4
            name4 = tmp_exposure_matrix{4, 2};
            species4 = tmp_exposure_matrix{4, 1};
            fullname4 = [name4, '''s ', species4];
            [tmp_row, ~] = find(ismember(stimuli.ItemMatrix_Full(:,2), name4));
            tmp_texture_4 = stimuli.ItemMatrix_Full{tmp_row, 5};
            Screen('DrawTexture', window, tmp_texture_4, [], positions_pict4_six);
            DrawFormattedText(window, fullname4, 'center', 'center', black, [], [], [], [], [], [positions_pict4_six(1), positions_pict4_six(4), positions_pict4_six(3), positions_pict4_six(4)+30]);
            
            % Item 5
            name5 = tmp_exposure_matrix{5, 2};
            species5 = tmp_exposure_matrix{5, 1};
            fullname5 = [name5, '''s ', species5];
            [tmp_row, ~] = find(ismember(stimuli.ItemMatrix_Full(:,2), name5));
            tmp_texture_5 = stimuli.ItemMatrix_Full{tmp_row, 5};
            Screen('DrawTexture', window, tmp_texture_5, [], positions_pict5_six);
            DrawFormattedText(window, fullname5, 'center', 'center', black, [], [], [], [], [], [positions_pict5_six(1), positions_pict5_six(4), positions_pict5_six(3), positions_pict5_six(4)+30]);
            
            % Item 6
            name6 = tmp_exposure_matrix{6, 2};
            species6 = tmp_exposure_matrix{6, 1};
            fullname6 = [name6, '''s ', species6];
            [tmp_row, ~] = find(ismember(stimuli.ItemMatrix_Full(:,2), name6));
            tmp_texture_6 = stimuli.ItemMatrix_Full{tmp_row, 5};
            Screen('DrawTexture', window, tmp_texture_6, [], positions_pict6_six);
            DrawFormattedText(window, fullname6, 'center', 'center', black, [], [], [], [], [], [positions_pict6_six(1), positions_pict6_six(4), positions_pict6_six(3), positions_pict6_six(4)+30]);
            
            disp('end time');
            disp(GetSecs-allstart);
            
            % Flip to the screen
            Screen('Flip', window);
            
            trig(13); % send start trigger
            WaitSecs(exposure_dur); % keeps the Items on the screen for desired time
            trig(14); % send stop trigger
            
            %%%%%%%%%%%%%%%
            % STUDY PHASE %
            %%%%%%%%%%%%%%%
            
            % Instructions for this phase
            DrawFormattedText(window, studyInst_text, 'center', 'center', black);
            Screen('Flip', window);
            WaitSecs(0.5); % change to longer or wait for participant response to continue
            
            % Wait for participant response to continue
            while 0 < 1
                [keyIsDown,~,AnswerkeyCode] = KbCheck;
                if keyIsDown && isequal(KbName(AnswerkeyCode), KbName(return_key)) == 1
                    break;
                elseif keyIsDown && isequal(KbName(AnswerkeyCode), KbName(escape_key)) == 1
                    ShowCursor;
                    Screen('CloseAll');
                    break;
                end
            end
            DrawFormattedText(window, CrossHair, 'center', 'center', black);
            Screen('Flip', window);
            WaitSecs(ITI);
            
            % Item 1
            Screen('DrawTexture', window, tmp_texture_1, [], positions_center);
            DrawFormattedText(window, fullname1, 'center', positions_center(4)+30, black);
            Screen('Flip', window);
            
            trig(23); % send start trig
            WaitSecs(stim_dur);
            trig(24); % send stop trig
            
            DrawFormattedText(window, Crosshair, 'center', 'center', black);
            Screen('Flip', window);
            WaitSecs(ISI);
            
            
            % Item 2
            Screen('DrawTexture', window, tmp_texture_2, [], positions_center);
            DrawFormattedText(window, fullname2, 'center', positions_center(4)+30, black);
            Screen('Flip', window);
            
            trig(23); % send start trig
            WaitSecs(stim_dur);
            trig(24); % send stop trig
            
            DrawFormattedText(window, Crosshair, 'center', 'center', black);
            Screen('Flip', window);
            WaitSecs(ISI); % change to ISI
            
            
            % Item 3
            Screen('DrawTexture', window, tmp_texture_3, [], positions_center);
            DrawFormattedText(window, fullname3, 'center', positions_center(4)+30, black);
            Screen('Flip', window);
            
            trig(23); % send start trig
            WaitSecs(stim_dur);
            trig(24); % send stop trig
            
            DrawFormattedText(window, Crosshair, 'center', 'center', black);
            Screen('Flip', window);
            WaitSecs(ISI);
            
            
            % Item 4
            Screen('DrawTexture', window, tmp_texture_4, [], positions_center);
            DrawFormattedText(window, fullname4, 'center', positions_center(4)+30, black);
            Screen('Flip', window);
            
            trig(23); % send start trig
            WaitSecs(stim_dur); % change to stimulus duration
            trig(24); % send stop trig
            
            DrawFormattedText(window, Crosshair, 'center', 'center', black);
            Screen('Flip', window);
            WaitSecs(ISI); % change to ISI
            
            
            % Item 5
            Screen('DrawTexture', window, tmp_texture_5, [], positions_center);
            DrawFormattedText(window, fullname5, 'center', positions_center(4)+30, black);
            Screen('Flip', window);
            
            trig(23); % send start trig
            WaitSecs(stim_dur); % change to stimulus duration
            trig(24); % send stop trig
            
            DrawFormattedText(window, Crosshair, 'center', 'center', black);
            Screen('Flip', window);
            WaitSecs(ISI); % change to ISI
            
            
            % Item 6
            Screen('DrawTexture', window, tmp_texture_6, [], positions_center);
            DrawFormattedText(window, fullname6, 'center', positions_center(4)+30, black);
            Screen('Flip', window);
            
            trig(23); % send start trig
            WaitSecs(stim_dur); % change to stimulus duration
            trig(24); % send stop trig
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % RETRIEVAL PRACTICE PHASE %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Initialize tracks/marks to keep track of times presented and 
            % signify whether or not the Item has been learned
            track_1 = 0; track_2 = 0; track_3 = 0;
            track_4 = 0; track_5 = 0; track_6 = 0;
            mark_1  = 0; mark_2  = 0; mark_3  = 0;
            mark_4  = 0; mark_5  = 0; mark_6  = 0;
            
            %rp_order = randperm(6,6);
            
            % Present instructions for RP phase
            DrawFormattedText(window, rp_inst, 'center', 'center');
            Screen('Flip', window);
            KbStrokeWait; % wait for key press to continue
            WaitSecs(0.01);
            
            while (mark_1 == 0) || (mark_2 == 0) || (mark_3 == 0) || (mark_4 == 0) || (mark_5 == 0) || (mark_6 == 0) % while at least one is unlearned
               
                if mark_1 == 0
                    DrawFormattedText(window, CrossHair, 'center', 'center', black);
                    Screen('Flip', window);
                    WaitSecs(1);
                    
                    % Present image and prompt text
                    %display = [name1(1), '_________ the ', species1];
                    %DrawFormattedText(window, display, positions_center(1), positions_center(4)+30, black);
                    Screen('DrawTexture', window, tmp_texture_1, [], positions_center);
                    Screen('Flip', window);
                    
                    trig(33); % send start trig
                    WaitSecs(EEG_wait); % Wait two seconds to record EEG
                    trig(34); % send stop trig
                    
                    [marked, tracked, struct_output] = CompN_Test_RetrievalPractice(window, name1, species1, tmp_texture_1, positions_center(1), positions_center(4)+30, positions_center, black, 6, mark_1, track_1);
                    mark_1 = marked;
                    track_1 = tracked;
                    iteration_name = [name1, num2str(track_1)];
                    responses.rp.(iteration_name) = struct_output;
                    save(stim_filename, 'subject', 'task', 'stimuli', 'responses'); % save this round of responses
                end
                
                
                
                if mark_2 == 0
                    DrawFormattedText(window, CrossHair, 'center', 'center', black);
                    Screen('Flip', window);
                    WaitSecs(1);
                    
                    % Present image and prompt text
                    %display = [name2(1), '_________ the ', species2];
                    %DrawFormattedText(window, display, positions_center(1), positions_center(4)+30, black);
                    Screen('DrawTexture', window, tmp_texture_2, [], positions_center);
                    Screen('Flip', window);
                    
                    trig(33); % send start trig
                    WaitSecs(EEG_wait); % Wait two seconds to record EEG
                    trig(34); % send stop trig
                    
                    [marked, tracked, struct_output] = CompN_Test_RetrievalPractice(window, name2, species2, tmp_texture_2, positions_center(1), positions_center(4)+30, positions_center, black, 6, mark_2, track_2);
                    mark_2 = marked;
                    track_2 = tracked;
                    iteration_name = [name2, num2str(track_2)];
                    responses.rp.(iteration_name) = struct_output;
                    save(stim_filename, 'subject', 'task', 'stimuli', 'responses');
                end
                
                if mark_3 == 0
                    DrawFormattedText(window, CrossHair, 'center', 'center', black);
                    Screen('Flip', window);
                    WaitSecs(1);
                    
                    % Present image and prompt text
                    %display = [name3(1), '_________ the ', species3];
                    %DrawFormattedText(window, display, positions_center(1), positions_center(4)+30, black);
                    Screen('DrawTexture', window, tmp_texture_3, [], positions_center);
                    Screen('Flip', window);
                    
                    trig(33); % send start trig
                    WaitSecs(EEG_wait); % Wait two seconds to record EEG
                    trig(34); % send stop trig
                    
                    [marked, tracked, struct_output] = CompN_Test_RetrievalPractice(window, name3, species3, tmp_texture_3, positions_center(1), positions_center(4)+30, positions_center, black, 6, mark_3, track_3);
                    mark_3 = marked;
                    track_3 = tracked;
                    iteration_name = [name3, num2str(track_3)];
                    responses.rp.(iteration_name) = struct_output;
                    save(stim_filename, 'subject', 'task', 'stimuli', 'responses');  
                end
                 
                if mark_4 == 0
                    DrawFormattedText(window, CrossHair, 'center', 'center', black);
                    Screen('Flip', window);
                    WaitSecs(1);
                    
                    % Present image and prompt text
                    %display = [name4(1), '_________ the ', species4];
                    %DrawFormattedText(window, display, positions_center(1), positions_center(4)+30, black);
                    Screen('DrawTexture', window, tmp_texture_4, [], positions_center);
                    Screen('Flip', window);
                    
                    trig(33); % send start trig
                    WaitSecs(EEG_wait); % Wait two seconds to record EEG
                    trig(34); % send stop trig
                    
                    [marked, tracked, struct_output] = CompN_Test_RetrievalPractice(window, name4, species4, tmp_texture_4, positions_center(1), positions_center(4)+30, positions_center, black, 6, mark_4, track_4);
                    mark_4 = marked;
                    track_4 = tracked;
                    iteration_name = [name4, num2str(track_4)];
                    responses.rp.(iteration_name) = struct_output;
                    save(stim_filename, 'subject', 'task', 'stimuli', 'responses');   
                end
                
                if mark_5 == 0
                    DrawFormattedText(window, CrossHair, 'center', 'center', black);
                    Screen('Flip', window);
                    WaitSecs(1);
                    
                    % Present image and prompt text
                    %display = [name5(1), '_________ the ', species5];
                    %DrawFormattedText(window, display, positions_center(1), positions_center(4)+30, black);
                    Screen('DrawTexture', window, tmp_texture_5, [], positions_center);
                    Screen('Flip', window);
                    
                    trig(33); % send start trig
                    WaitSecs(EEG_wait); % Wait two seconds to record EEG
                    trig(34); % send stop trig
                    
                    [marked, tracked, struct_output] = CompN_Test_RetrievalPractice(window, name5, species5, tmp_texture_5, positions_center(1), positions_center(4)+30, positions_center, black, 6, mark_5, track_5);
                    mark_5 = marked;
                    track_5 = tracked;
                    iteration_name = [name5, num2str(track_5)];
                    responses.rp.(iteration_name) = struct_output;
                    save(stim_filename, 'subject', 'task', 'stimuli', 'responses');   
                end
                
                if mark_6 == 0
                    DrawFormattedText(window, CrossHair, 'center', 'center', black);
                    Screen('Flip', window);
                    WaitSecs(1);
                    
                    % Present image and prompt text
                    %display = [name6(1), '_________ the ', species6];
                    %DrawFormattedText(window, display, positions_center(1), positions_center(4)+30, black);
                    Screen('DrawTexture', window, tmp_texture_6, [], positions_center);
                    Screen('Flip', window);
                    
                    trig(33); % send start trig
                    WaitSecs(EEG_wait); % Wait two seconds to record EEG
                    trig(34); % send stop trig
                    
                    [marked, tracked, struct_output] = CompN_Test_RetrievalPractice(window, name6, species6, tmp_texture_6, positions_center(1), positions_center(4)+30, positions_center, black, 6, mark_6, track_6);
                    mark_6 = marked;
                    track_6 = tracked;
                    iteration_name = [name6, num2str(track_6)];
                    responses.rp.(iteration_name) = struct_output;
                    save(stim_filename, 'subject', 'task', 'stimuli', 'responses');
                    
                end
            end
                  
            % Counts the Items that have been presented
            Item_count = Item_count + 1;
                        
            % Checks to see if all Items have been presented
            if Item_count == length(stimuli.ItemMatrix_Learn_Random(:, 1))
                DrawFormattedText(window, 'End of Training Phase. Press "enter" to continue.', 'center', 'center', black);
                Screen('Flip', window);
                KbStrokeWait;
            else    
                DrawFormattedText(window,'Loading next items...', 'center', 'center', black);
                Screen('Flip', window);
                WaitSecs(ITI); % for debugging purposes, change to ITI
            end
            
        end % ends the if conditionals to determine 2 or 6 member families
        
    end % ends the loop for exposure/learning/retrieval-practice phases
    
    DrawFormattedText(window, 'End of Training Phase.', 'center', 'center', black);
    Screen('Flip', window);
    KbStrokeWait;
    sca;
    
catch
    % Error. Close screen, show cursor, rethrow error:
    ShowCursor;
    Screen('CloseAll');
    %clc; %clear command window
    fclose('all');
    Priority(0);
    psychrethrow(psychlasterror);
end
%