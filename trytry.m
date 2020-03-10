function [= CompN_RP = 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RETRIEVAL PRACTICE PHASE %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%


try
    
    
    
     % Animal 1
            fullname1 = ['_________', ' the ', char(tmp_exposure_matrix(1, 1))];
            Screen('DrawTexture', window, tmp_texture_1, [], positions_center); % save for rp phase
            DrawFormattedText(window, fullname1, 'center', positions_center(4)+30, black); % save for rp phase
            Screen('Flip', window);
            WaitSecs(stim_dur); % change to stimulus duration
            
            % Fixation point
            DrawFormattedText(window, Crosshair, 'center', 'center', black);
            Screen('Flip', window);
            WaitSecs(ISI);
            
            % Animal 2
            fullname2 = ['_________', ' the ', char(tmp_exposure_matrix(2, 1))];
            Screen('DrawTexture', window, tmp_texture_2, [], positions_center);
            DrawFormattedText(window, fullname2, 'center', positions_center(4)+30, black);
            Screen('Flip', window);
            WaitSecs(stim_dur); % change to stimulus duration
            
            
            
            
            
            
            
            
            
            %helper = ismember(stimuli.AnimalMatrix_TwoMembers_Random(:,1), species); % returns validation matrix with ones and zeros
            %tmp_rp_matrix = stimuli.AnimalMatrix_TwoMembers_Random(helper == 1, :); % creates randomized lookup matrix for this animal based on stim.am_l_r
                        
            % Randomize the two member matrix with references to the textures
            %stimuli.AnimalMatrix_RP_Random.(species) = tmp_rp_matrix(randperm(size(tmp_rp_matrix,1)),:);
            % Save it to the stimuli struct in subj file
            %save(stim_filename,'stimuli');
            
            % Draw the instructions for the RP phase
            %DrawFormattedText(window, rp_inst, 'center', 'center', black);
            
            % Animal 1 retrieval practice
            %name = tmp_rp_matrix(1, 2);
            %fullname1 = ['__________', ' the ', char(tmp_rp_matrix(1,1))];
            %[tmp_row, ~] = find(ismember(stimuli.AnimalMatrix_Full(:,2), name));
            %tmp_texture_1 = stimuli.AnimalMatrix_Full{tmp_row, 5};
            %Screen('DrawTexture', window, tmp_texture_1, [], positions_center);
            %DrawFormattedText(window, fullname1, 'center', positions_center(4)+30, black); % save for rp phase
            %
            %WaitSecs(EEG_wait);
            
            % CODE FOR TYPING IN RESPONSE AND ALGORITHM TO SEE IF ITS GOOD
            % ENOUGH
            
            %[response, RT] = GetEchoStringVert(window, which_animal, x, y, black);
            % make sure to save the response and the RT in some way -
            % probably using fprintf but I need to find a way so that it
            % won't overwrite the previous ones. I need a formatting for
            % this.
            
            %disp(response);            
            %compare = EditDist(response, name);
            %disp(compare);
            
    
    
    
    
    
    
    
    
catch
    % Error. Close screen, show cursor, rethrow error:
    ShowCursor;
    Screen('CloseAll');
    %clc; %clear command window
    fclose('all');
    Priority(0);
    psychrethrow(psychlasterror);
end
