%function CompN_Test_Test()

% Name: Senior Project Competition Learning Phase
% Author: Noah Libby
% Thanks to Justin Hulbert, Peter Scarfe, Zall Hirschstein, and Jacob Libby for code help and inspiration
% 
% Dependencies:
% *CompN_Test_RetrievalPractice.m
% *EditDist.m 
% *GetEchoStringVertRedraw.m
% *CompN_Item_FinalTest.m

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

    ItemMatrix_Test_Random = stimuli.ItemMatrix_Test_Random;
    
else
    disp('Odd issue. File not found!');
    
end %if not loading in preexisting stimulus file
%% Establish connection to Emotiv Pro software and Emotiv EPOC+ EEG headband

if TRIGS == 0
    disp('NO TRIGGERS BEING USED')
elseif TRIGS == 1
    disp('TRIGGERS IN USE')
    %trig(0) %INITIALIZING THE TRIGGERS
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

% Run the sync tests
Screen('Preference', 'SkipSyncTests', 0);

flipTime = Screen('GetFlipInterval',window); %for this particular phase (not necessarily the one used in the main TNT phase)
slack = flipTime/2; % start any time-critical flip early enough to allow the flip to take place (use a halfflip); can be used to present at an exact time after a previous stimulus onset [e.g., for 500ms after t_prime, use: "tprime_onset = Screen('Flip', window, tfixation_onset + 0.500 - slack)"]

% Set reference locations for objects
Resized = 150; % half of the length or height for a square image
x = s_width;
y = s_height;
positions_center    = [((x/2)-Resized), ((y/2)-Resized), ((x/2)+Resized), ((y/2)+Resized)];

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
    
    %%%%%%%%%%%%%%%%%%%%
    % FINAL TEST PHASE %
    %%%%%%%%%%%%%%%%%%%%
    
    final_test_inst = sprintf('%s\n%s\n%s\n%s\n%s\n%s', 'It is the end of show-and-tell day and the students need to go home with', ...
    'the item they brought to school. Think back to when you first learn which item belonged to which student.', ...
    'You will be presented with an image of an item and will be given two seconds to think about the name of the ', ...
    'student who brought it. During that time, you must remain very still.', ...
    'Once the text appears on the screen, type the name of the student.', ...
    'Are you ready? Press "enter" to continue.');
    DrawFormattedText(window, final_test_inst, 'center', 'center', black);
    Screen('Flip', window); 
    WaitSecs(0.01);
    KbStrokeWait;
    
    for sp = 1:length(ItemMatrix_Test_Random(:,1))

        name = stimuli.ItemMatrix_Test_Random{sp, 2};
        species = stimuli.ItemMatrix_Test_Random{sp, 1};
        texture = Screen('MakeTexture', window, stimuli.ItemMatrix_Test_Random{sp, 4});
        
        %display = [name(1), '_________ the ', species];
        
        % Present image and prompt text
        %DrawFormattedText(window, display, positions_center(1), positions_center(4)+30, black);
        Screen('DrawTexture', window, texture, [], positions_center);
        Screen('Flip', window);
        
        
        % Send start trig
        if stimuli.ItemMatrix_Test_Random{sp,6} == 2
            trig(41); % send low_comp start trig
            WaitSecs(EEG_wait);
            trig(42); % send low_comp stop trig
        elseif stimuli.ItemMatrix_Test_Random{sp,6} == 6
            trig(43); % send high_comp start trig
            WaitSecs(EEG_wait);
            trig(44); % send high_comp stop trig
        end
        
        [struct_output] = CompN_Item_FinalTest(window, name, species, texture, positions_center(1), positions_center(4)+30, positions_center, black);
        responses.test.(name) = struct_output;
        save(stim_filename, 'responses');
        
    end
    
    DrawFormattedText(window, 'End of phase.', 'center', 'center');
    Screen('Flip', window);
    
    % Wait for keystroke to eliminate
    KbStrokeWait;
    % Clear screen
    sca
    
        % give on-screen and written instructions for the
            % exposure/study/practice subphases
            % explain different symbols
                % fixation point
                % symbol to indicate to wait to respond until two seconds has elapsed
                % symbol that comes up/goes away when two seconds has elapsed
        % explain different symbols that will be used to indicate when the  
        % present all of the pictures and names together for the Item
            % if it's a two/six person family, display the images differently/evenly-spaced on the screen
        % present each picture and name individually
        % present a fixation point between pictures
        % randomize the order of the presentation
        % present the Item image and the first (and second?) letter
            % SEND trigger code at start of presentation to Emotiv
            % wait two seconds to record EEG
            % SEND trigger code at end of presentation
            % after two seconds, allow the participant to type
            % SEND trigger code at first key press
            % SEND trigger codes at each key press?
            % SEND trigger code once participant presses enter to indicate they have finalized their guess
            % record the amount of time it takes them to type response
        % create a response matrix to record responses and times    
            % HOW MANY times to repeat each so that they're balanced across low and high competition
            % IF guess is correct
                % mark in response matrix
            % ELSEIF guess is incorrect
                % mark in response matrix
        % once they've gotten them all correct once (or whatever metric I choose), move to next species
        
        % randomize order of all Item names
            % 
        % present each Item like above and do the test
    

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