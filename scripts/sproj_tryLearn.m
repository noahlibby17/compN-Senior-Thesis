%% Set up Psychtoolbox
% Clear workspace
sca;
close all;
clearvars;

% Default PTB settings
PsychDefaultSetup(2);

DEBUG_ME = 1;
if DEBUG_ME == 1
    PsychDebugWindowConfiguration(0,0.5) %set background to semi-transparent to see command window
end

% Reseed the random-number generator for each experiment run
rng('shuffle'); %this is the new way that sets the initial seed using date/time

% Get screen number and max screen
screens = Screen('Screens');
screenNumber = max(screens);

% Get size of screen
[s_width, s_height]=Screen('WindowSize', screenNumber); %also found in windowRect below

% Define colors
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white/2;

% Open an on screen window with a white background color:
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);

% Set blend function for alpha blending
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% Get the center coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Set default text stuff later calls to DrawFormattedText(window, text, 'center', 'center');
Screen('TextFont', window, 'Helvetica'); %default font
Screen('TextSize', window, 44); %default font size
Screen('TextStyle', window, 1); %default font style
Screen('TextColor', window, white); %default font color
Screen('Preference', 'TextAlphaBlending', 0); %default font transparency

flipTime = Screen('GetFlipInterval',window);
slack = flipTime/2; % start any time-critical flip early enough to allow the flip to take place (use a halfflip)
Hz = 60; 
%% Open screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);

% Set the blend function for the screen
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Get the size of the on screen window in pixels
% For help see: Screen WindowSize?
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Get the centre coordinate of the window in pixels
% For help see: help RectCenter
[xCenter, yCenter] = RectCenter(windowRect);

% Draw text in the middle of the screen in Courier in white
Screen('TextSize', window, 80);
Screen('TextFont', window, 'Courier');
DrawFormattedText(window, 'SAMPLE TEXT HERE', 'center', 'center', white);

% Flip to the screen
Screen('Flip', window);

% Wait for keystroke to eliminate
KbStrokeWait;
