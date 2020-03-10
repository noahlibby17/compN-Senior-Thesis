function [responses] = CompN_Item_FinalTest(window, name, species, texture, msg_x, msg_y, img_loc, textColor)

% Final Test for ind. item in CompN experiment
% Dependencies: 
% GetEchoStringVertRedraw.m
% EditDist.m

startTime = GetSecs; % start time
%mark = 0; % does this animal need to be presented again? 0 = yes, 1 = no
%track = 1; % keeps track of how many times this animal was presented. Start at 1 default based on way code below is structured

responses = struct(); % premake responses struct

% display image and have prompt for name
try
    
    display = [name(1), '_________''s ', species];
    
    % PRESENT image and prompt
    DrawFormattedText(window, display, msg_x, msg_y, textColor);
    Screen('DrawTexture', window, texture, [], img_loc);
    Screen('Flip', window);
    
    % CAPTURE participant response
    [response, RT]  = GetEchoStringVertRedraw(window, display, msg_x, msg_y, textColor, texture, img_loc, [], [], []); % allows for user input, redrawing the texture every time that the user types
    tmp_struct = struct('Name', name, 'First_Keypress_RT', num2str(double(RT)), ...
        'Point_of_stop', display, 'Response', response, 'Total_time_since_function_started', num2str(GetSecs-startTime)); % adds the name, their RT, point where display was stopped, and typed response to a field structure
    responses.(name) = tmp_struct;

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