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
%Screen('Preference', 'SkipSyncTests', 1);
x = s_width;
y = s_height;
Resized = 150;
positions_center    = [((x/2)-Resized), ((y/2)-Resized), ((x/2)+Resized), ((y/2)+Resized)];

source = '/home/mdynamics/Desktop/noahSPROJ/stimuli/animals/PIG/PIG1/PIG1.jpg';
image = imread(source);
image_texture = Screen('MakeTexture', window, image); % make image textures - make them color?


% give instructions to wait - symbol?
% present image
% send trigger
% log time
% wait two seconds
% give instructions to guess - symbol?
% run testing.m/CompN_RP.m script to present image/text and allow for typing guess

% ^^ the way that it will look in CompN_Train.m

track_1 = 1;
track_2 = 1;
mark_1 = 0;
mark_2 = 0;

CrossHair = '+';
ITI = 1;

stim_filename = 'results/subject_sets/CompN_test_stims.mat';

while (mark_1 == 0) || (mark_2 == 0) % while at least one is unlearned
    
    if mark_1 == 0   
        
        DrawFormattedText(window, CrossHair, 'center', 'center'); %fixation
        Screen('Flip', window);
        WaitSecs(1); 
        Screen('DrawTexture', window, image_texture, positions_center);
        Screen('Flip', window);
        trig(1);
        WaitSecs(2);
        trig(2);
   
        [mark_1, track_1, struct_output] = CompN_RetrievalPractice(window, 'Oliver', 'Otter', image_texture, positions_center(1), positions_center(4)+30, positions_center,  black, 0);
        % save struct_output to stim_filename
    end 
     
    if mark_2 == 0 
        
        DrawFormattedText(window, CrossHair, 'center', 'center'); %fixation 
        Screen('Flip', window);
        WaitSecs(1);
        
        [mark_2, track_2, struct_output] = CompN_RetrievalPractice(window, 'Ernie', 'Elephant', image_texture, positions_center(1), positions_center(4)+30, positions_center, black, 0);
        % save struct_output to stim_filename
        
    end    
    
    KbStrokeWait; % for testing purpose 
end 
KbStrokeWait
sca; % for testing purposes

disp(1);






  