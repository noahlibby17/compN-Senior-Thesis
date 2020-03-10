function [mark, track, responses] = CompN_RetrievalPractice(window, name, species, texture, msg_x, msg_y, img_loc, textColor, comp_type, mark, track)

% Retrieval practice for ind. item in CompN experiment
% Dependencies: 
% GetEchoStringVertRedraw.m
% EditDist.m
%
% comp_type: 1 = high competition, 0 = low competition

if (nargin < 12) || (isempty(mark)) || (isempty(track))
    mark = 0;
    track = 1;
elseif nargin < 11
    error('Not enough input arguments for CompN_RetrievalPractice');
end

startTime = GetSecs; % start time
%mark = 0; % does this animal need to be presented again? 0 = yes, 1 = no
%track = 1; % keeps track of how many times this animal was presented. Start at 1 default based on way code below is structured

responses = struct(); % premake responses struct

% loop slow reveal of name - press 'spacebar' to pause the loop and type guess for name
try
        
    for letter = 1:length(name)
        
        display = [name(1:letter), '_________ the ', species]; % change this to update the underscores? % change to make more general for other animals
        
        DrawFormattedText(window, display, msg_x, msg_y, textColor);
        Screen('DrawTexture', window, texture, [], img_loc);
        Screen('Flip', window);
        
        time = GetSecs;
        
        breakflag = 0;
        while GetSecs-time<1; % wait 1 second for a key press to signify participant is ready to respond
            [keyIsDown] = KbCheck;
            if keyIsDown == 1
                WaitSecs(0.01); % so that it doesn't trigger the next function
                iteration_name = [name, num2str(track)]; % to set up field structure for this iteration of the animal
                DrawFormattedText(window, display, msg_x, msg_y, textColor);
                Screen('DrawTexture', window, texture, [], img_loc);
                Screen('Flip', window);
                
                % CAPTURE participant response
                [response, RT]  = GetEchoStringVertRedraw(window, display, msg_x, msg_y, textColor, texture, img_loc, [], [], []); % allows for user input, redrawing the texture every time that the user types
                tmp_struct = struct('Name', name, 'First_Keypress_RT', num2str(double(RT)), ...
                    'Point_of_stop', display, 'Response', response, 'Total_time_since_function_started', num2str(GetSecs-startTime)); % adds the name, their RT, point where display was stopped, and typed response to a field structure
                responses.(iteration_name) = tmp_struct;
                
                % CHECK to see if the response is close enough to be considered correct. MARK this as 'learned' if this is true
                check = EditDist(char(response), upper(name)); % checking function
                if check <= 1
                    mark = 1; % they guessed correctly, don't repeat this
                else
                    mark = 0; % they guessed incorrectly, repeat this animal
                    track = track + 1; % keep track of times been presented
                end
                
                breakflag = 1; % allows for breaking out of nested loop
                break % break out of loop if they respond
            end
        end
        % if no response, move on to next letter
        
        if breakflag == 1
            break % breaks out of nested loop
        end
        
        if comp_type == 6 % high competition animals
            if letter == 3 % if half of the word has been presented, they fail the trial and have to repeat
                % SHOW THE WHOLE WORD %
                Screen('DrawTexture', window, texture, [], img_loc);
                Screen('DrawText', window, [name, ' the ', species], msg_x, msg_y, textColor);
                Screen('Flip', window);
                WaitSecs(5);
                mark = 0; % keep it the same, repeat animal
                break % REPEAT THIS  ANIMAL - keep track of the marks and change the mark if they get it. Keep track of how many marks per animal with TRACK
            end
        
        elseif comp_type == 2 % low competition animals
            if letter == 2 % if one quarter of the word has been presented, they fail the trial and have to repeat
                % SHOW THE WHOLE WORD %
                Screen('DrawTexture', window, texture, [], img_loc);
                Screen('DrawText', window, [name, ' the ', species], msg_x, msg_y, textColor);
                Screen('Flip', window);
                WaitSecs(5);
                mark = 0; % keep it the same, repeat animal
                break % REPEAT THIS  ANIMAL - keep track of the marks and change the mark if they get it. Keep track of how many marks per animal with TRACK
            end
        end
    end
    
catch
    % Error. Close screen, show cursor, rethrow error:
    sca
    ShowCursor;
    Screen('CloseAll');
    %clc; %clear command window
    fclose('all');
    Priority(0)
    psychrethrow(psychlasterror);
end

%KbStrokeWait; % delete when actually running multiple at once