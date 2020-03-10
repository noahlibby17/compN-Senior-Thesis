%% Old script practice for CompN_RetrievalPractice



% Requires GetEchoStringVertRedraw.m and EditDist.m




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
Screen('DrawTexture', window, image_texture, [], positions_center);
 
% Set the key code for the OS
KbName('UnifyKeyNames');
space_key = KbName('space');

DrawFormattedText(window, 'Press the Space Bar to pause the name reveal and make your guess', 'center', positions_center(4)+30, black);
Screen('Flip', window);
WaitSecs(1);

DrawFormattedText(window, 'O_____ the Otter' , 'center', 'center', black);  
Screen('Flip', window);

enter = ' '; 

name = 'OLIVER';

startTime = GetSecs;

%response_log = cellstr(['name', 'display', 'response']); % to be filled with target names, point of press, & responses 
mark_1 = 0; % does this animal need to be presented again? 0 = yes, 1 = no
track_1 = 1; % keeps track of how many times this animal was presented
% loop slow reveal of name - press 'spacebar' to pause the loop
 
try
for letter = 1:length(name)
 
    display = [name(1:letter), '_________',' the Otter']; % change this to update the underscores? % change to make more general for other animals
    
    Screen('DrawText', window, display, positions_center(1), positions_center(4)+30, black);
    Screen('DrawTexture', window, image_texture, [], positions_center);
    Screen('Flip', window);
     
    time = GetSecs;
    breakflag = 0;
    while GetSecs-time<1; % wait 1 second for a key press to signify participant is ready to respond
        [keyIsDown] = KbCheck;
        if keyIsDown == 1
            WaitSecs(0.01); % so that it doesn't trigger the next function
            iteration_name = [name, num2str(track_1)]; % to set up field structure for this iteration of the animal
            DrawFormattedText(window, display, positions_center(1), positions_center(4)+30, black);
            Screen('DrawTexture', window, image_texture, [], positions_center);
            Screen('Flip', window);
            
            % CAPTURE participant response
            [response, RT]  = GetEchoStringVertRedraw(window, display, positions_center(1), positions_center(4)+30, black , blue, image_texture, positions_center, [], [], []); % allows for user input, redrawing the texture every time that the user types
            responses.(iteration_name) = char(name, num2str(double(RT)), display, response, ['Total time: ', num2str(GetSecs-time)]); % adds the name, their RT, point where display was stopped, and typed response to a field structure
            save('participant_filename','responses'); % change to participant filename
               
            % CHECK to see if the response is close enough to be considered correct. MARK this as 'learned' if this is true
            check = EditDist(response, upper('Elephant')); % change 'elephant' to var name 
            if check <= 1
                mark_1 = 1; % they guessed correctly, don't repeat this
            else
                mark_1 = 0; % they guessed incorrectly, repeat this animal
                track_1 = track_1 + 1; % increase by 1 if need to repeat
            end 
            breakflag = 1; % allows for breaking out of nested loop
            break % break out of loop if they  respond in any oliver
        end
    end 
    % if no response, move on to next letter
    
    if breakflag == 1 
        break % breaks out of nested loop
    end 
 
    if letter > (length(name))/2 % if more than half of the word has been presented, they fail the trial and have to repeat
        % SHOW THE WHOLE WORD %
        Screen('DrawTexture', window, image_texture, [], positions_center);
        DrawFormattedText(window, [name, ' the ', 'otter'], 'center', positions_center(4)+30, black);
        Screen('Flip', window);
        mark_1 = 0; % keep it the same
        break % REPEAT THIS  ANIMAL - keep track of the marks and change the mark if they get it. Keep track of how many marks per animal
    end
    
end
catch  
      
    sca
    
    % Error. Close screen, show cursor, rethrow error:
    ShowCursor;
    Screen('CloseAll');
    %clc; %clear command window
    fclose('all');
    Priority(0)
    psychrethrow(psychlasterror);
end

%%% save response log to file struct



KbStrokeWait;
sca;