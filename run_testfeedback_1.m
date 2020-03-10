function Output_testfb1 = run_testfeedback_1(parameter,test_fb_struct_1,image_path)

%% set up study output file
StudyOutputFileName = sprintf('%s_testfeedback1_%0d.txt',fullfile(parameter.sub_path,char(parameter.sub_nb)),parameter.nb_test_fb1_cycle);
fid                 = fopen(StudyOutputFileName,'w+t'); % open as writeable text

%% spin the rand # generator
% clck = round(clock);
% for i_rand = 1:clck(6)
%     rand;
% end
rng('shuffle'); %this is the new way that sets the initial seed using date/time

%% debugging mode? make sure this is off (0) for actual experiment runs!!!
DEBUG_ME = 0;
if DEBUG_ME == 1
    Screen('Preference','SkipSyncTests', 1); %required for Justin's office iMac until graphics incompatibility comes out
    %PsychDebugWindowConfiguration(0,0.5) %set background to semi-transparent to see command window
end

%% print out header information
header = sprintf([...
    '*********************************************\n' ... 
    '* Experiment: HeartSpace\n' ...
    '* Phase: TF 1\n' ...
    '* Script: %s\n' ...
    '* Date/Time: %s\n' ...
    '* Subject Number: %s\n' ...
    '* Debug: %d\n'...
    '*********************************************\n\n'], ...
    mfilename,datestr(now,0),char(parameter.sub_nb),...
    DEBUG_ME);

fprintf(fid,header);
fprintf(fid,'TrialNumber\t object\t word\t cond\t canRecall\t canRecall_rt\t rec_accuracy\t rec_rt\t foilA\t foilB\t foilC\t foilD\t foilE\n');

%% control parameter

screenNumber= max(Screen('Screens'));
gray   = [199 199 199]; %matched to gray background of images
AbortExp            = 0;

% set locations for objects
sizeFactor = parameter.sizeFactor; %scaling factor for object photos (1=full size = 640x480 including gray padding)
ObjectFrameDim_x      = sizeFactor*640;
ObjectFrameDim_y      = sizeFactor*480;

% text settings
TextFont            = 'Verdana';
TextSize            = 40;
RecallTextSize      = 20;
fbTextSize          = 40;

% key and color
blue    = [30 144 255];
green   = [34 139 34];
red     = [255 0 0];
yellow  = [255 255 0];
brown   = [139 69 19];

KbName('UnifyKeyNames')
OneKey          = '7'; %these keys are arranged to match the left 2 rows of the numpad
TwoKey          = '4';
ThreeKey        = '1';
FourKey         = '8';
FiveKey         = '5';
SixKey          = '2';
YesKey          = 'z';
NoKey           = 'x';
CancelExpKey    = 'escape';

% FixationStimuli
Crosshair = '+';

try
    [window, windrect] = Screen('OpenWindow', screenNumber);                   % get screen. '2' for 2nd monitor, '0' for working screen
    AssertOpenGL;                                                           % check for opengl compatability
    Screen('Preference', 'Enable3DGraphics', 1);
    Screen('BlendFunction', window, GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);   % enables alpha blending
    priorityLevel = MaxPriority(window);                                    % set priority - also set after Screen init
    Priority(priorityLevel);
    
    % background
    black       = BlackIndex(window);
    white       = WhiteIndex(window);
    grey        = gray; %(black+white)/1.5;
    background  = gray; %grey;
    
    % cross pos
    [a,b]=WindowCenter(window);
    %a=a-7;
    %b=b-10;
    a_offyPos=a+1;
    a_offyNeg=a-1;
    b_offyPos=b+1;
    b_offyNeg=b-1;
    
    % Get size of screen
    [s_width, s_height]=Screen('WindowSize', screenNumber); %also found in windowRect below
    
    % picture and word positions
    x = s_width; y = s_height;
    shCenter = x/2; svCenter = y/2;
    
    positions_pict1 = [(((x/6)*1)-ObjectFrameDim_x/2), ((y/6)-ObjectFrameDim_y/2), (((x/6)*1)+ObjectFrameDim_x/2), ((y/6)+ObjectFrameDim_y/2)];
    positions_pict2 = [(((x/6)*1)-ObjectFrameDim_x/2), ((y/2)-ObjectFrameDim_y/2), (((x/6)*1)+ObjectFrameDim_x/2), ((y/2)+ObjectFrameDim_y/2)];
    positions_pict3 = [(((x/6)*1)-ObjectFrameDim_x/2), (((y/6)*5)-ObjectFrameDim_y/2), (((x/6)*1)+ObjectFrameDim_x/2), (((y/6)*5)+ObjectFrameDim_y/2)];
    positions_pict4 = [(((x/6)*5)-ObjectFrameDim_x/2), ((y/6)-ObjectFrameDim_y/2), (((x/6)*5)+ObjectFrameDim_x/2), ((y/6)+ObjectFrameDim_y/2)];
    positions_pict5 = [(((x/6)*5)-ObjectFrameDim_x/2), ((y/2)-ObjectFrameDim_y/2), (((x/6)*5)+ObjectFrameDim_x/2), ((y/2)+ObjectFrameDim_y/2)];
    positions_pict6 = [(((x/6)*5)-ObjectFrameDim_x/2), (((y/6)*5)-ObjectFrameDim_y/2), (((x/6)*5)+ObjectFrameDim_x/2), (((y/6)*5)+ObjectFrameDim_y/2)];
    
    %position_correct = [(shCenter-ObjectFrameDim_x/2), (((y/6)*4.6)-ObjectFrameDim_y/2), (shCenter+ObjectFrameDim_x/2), (((y/6)*4.6)+ObjectFrameDim_y/2)]; %for feedback, present at bottom
    
    fb_wrong = 'WRONG!';
    fb_wrongRect = Screen('TextBounds',window,fb_wrong);
    
    [VBTimestamp, timeStamp]=Screen('Flip', window);
    
    %     % set text size
    %     Screen('TextSize', window, 32);
    
    %% read in the stimuli and prepare object trial layouts
    % put up note while stimuli are loading
    Screen('FillRect', window, background);
    Screen('TextSize', window, TextSize);
    Screen('TextFont', window, TextFont);
    
    WaitNote        = 'loading stimuli ...';
    WaitNoteRect    = Screen('TextBounds',window,WaitNote);
    WaitNoteLoc     = CenterRect(WaitNoteRect,windrect);
    Screen('DrawText',window,WaitNote,WaitNoteLoc(1),WaitNoteLoc(4),black);
    Screen('Flip', window);
    
    % Progress Bar
    ProgBarWidth    = WaitNoteRect(3);
    ProgBarHeight   = 10;
    ProgBarRect     = CenterRect([0 0 ProgBarWidth ProgBarHeight],windrect);
    ProgBarRect     = [ProgBarRect(1) ProgBarRect(2)+75 ProgBarRect(3) ProgBarRect(4)+75];
    ProgInc         = ProgBarWidth/length(test_fb_struct_1);
    
    ObjectFrame     = CenterRect([0 0 ObjectFrameDim_x ObjectFrameDim_y],windrect);
    
    ObjPres=cell(length(test_fb_struct_1),3); % col(1) is target, columns 2-6 are foils
    
    for IndTrial = 1:length(ObjPres);
        
        tmp_path = fullfile(image_path,[test_fb_struct_1{IndTrial}.object_target,'.jpg']);
        Object1 = imread(tmp_path);
        tmp_path = fullfile(image_path,[test_fb_struct_1{IndTrial}.object_foil1,'.jpg']);
        Object2 = imread(tmp_path);
        tmp_path = fullfile(image_path,[test_fb_struct_1{IndTrial}.object_foil2,'.jpg']);
        Object3 = imread(tmp_path);
        tmp_path = fullfile(image_path,[test_fb_struct_1{IndTrial}.object_foil3,'.jpg']);
        Object4 = imread(tmp_path);
        tmp_path = fullfile(image_path,[test_fb_struct_1{IndTrial}.object_foil4,'.jpg']);
        Object5 = imread(tmp_path);
        tmp_path = fullfile(image_path,[test_fb_struct_1{IndTrial}.object_foil5,'.jpg']);
        Object6 = imread(tmp_path);
        
        ObjPres{IndTrial,1}  = Screen('MakeTexture', window, Object1);
        ObjPres{IndTrial,2}  = Screen('MakeTexture', window, Object2);
        ObjPres{IndTrial,3}  = Screen('MakeTexture', window, Object3);
        ObjPres{IndTrial,4}  = Screen('MakeTexture', window, Object4);
        ObjPres{IndTrial,5}  = Screen('MakeTexture', window, Object5);
        ObjPres{IndTrial,6}  = Screen('MakeTexture', window, Object6);
        
        ObjFeed{IndTrial}  = Screen('MakeTexture', window, addborder(Object1,10,[30 144 255],'outer')); %in blue
        
        % show the loading progress
        Screen('DrawText',window,WaitNote,WaitNoteLoc(1),WaitNoteLoc(4),black);
        Screen('FillRect', window, white, [ProgBarRect(1) ProgBarRect(2) ProgBarRect(1)+IndTrial*ProgInc ProgBarRect(4)]);
        Screen('FrameRect', window,black, ProgBarRect);
        Screen('Flip', window);
    end
    
    clear Object1 Object2 Object3 Object4 Object5 Object6
    
    commandwindow; %put the command window in focus (not editor)
    HideCursor;
    
    %%%%%%%%%%%%%%%%%%%%
    % START EXPERIMENT %
    %%%%%%%%%%%%%%%%%%%%
    
    % get subject ready to start
    start_ses_text = ['Are you ready to start?'];
    
    DrawFormattedText(window, start_ses_text, 'center', 'center', BlackIndex(window));
    
    % Update the display to show the instruction text:
    Screen('Flip', window);
    
    % Wait for mouse click:
    GetClicks(window);
    
    Screen('TextSize', window, TextSize);
    Screen('DrawText', window, Crosshair, a, b, white);
    Screen('DrawText', window, Crosshair, a_offyPos, b_offyNeg, white);
    Screen('DrawText', window, Crosshair, a_offyNeg, b_offyNeg, white);
    Screen('DrawText', window, Crosshair, a_offyNeg, b_offyPos, white);
    Screen('DrawText', window, Crosshair, a_offyPos, b_offyPos, white);
    Screen('DrawText', window, Crosshair, a, b, black); %black cross in center
    
    Screen('Flip', window);
    task_start = GetSecs;
    
    while GetSecs - task_start <= 2;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Enter the Trial Loop %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    for nTrial = 1:length(test_fb_struct_1)
        
        % draw word & wait for button response
        Screen('TextSize', window, TextSize);
        DrawFormattedText(window, test_fb_struct_1{nTrial}.word, 'center', 'center',black);
        
        Screen('Flip', window);
        StimStart = GetSecs;
        while (GetSecs-StimStart)<=parameter.testfb_initial_recall_duration;
            [keyIsDown,TimeSecs,AnswerkeyCode] = KbCheck;
            if keyIsDown && AnswerkeyCode(KbName(YesKey)) == 1
                initial_recall(nTrial) = 1;
                initial_rec_rt(nTrial) = TimeSecs - StimStart;
                break;
            elseif keyIsDown && AnswerkeyCode(KbName(NoKey)) == 1
                initial_recall(nTrial) = 0;
                initial_rec_rt(nTrial) = TimeSecs - StimStart;
                break;
            elseif keyIsDown && AnswerkeyCode(KbName(CancelExpKey))
                AbortExp = 1;
                break;
            else
                initial_recall(nTrial) = 0;
                initial_rec_rt(nTrial) = NaN;
            end
        end
        
        %initialize recognition accuracy/rt tracker
        rec(nTrial) = NaN; %for any trial type
        rec_rt(nTrial) = NaN; %for any trial type
        rec_think(nTrial) = NaN;
        rec_nothink(nTrial) = NaN;
        rec_bas(nTrial) = NaN;
        
        %present the forced-choice recognition task as follow-up if they
        %said they could recall the image
        if initial_recall(nTrial) == 1
            
            % draw word
            Screen('TextSize', window, TextSize);
            DrawFormattedText(window, test_fb_struct_1{nTrial}.word, 'center', 'center',black)
            
            % draw 6-forced choice picture, balanced
            idx_rand = randperm(6);
            Screen('DrawTexture',window,ObjPres{nTrial,idx_rand(1)},[],positions_pict1);
            Screen('DrawTexture',window,ObjPres{nTrial,idx_rand(2)},[],positions_pict2);
            Screen('DrawTexture',window,ObjPres{nTrial,idx_rand(3)},[],positions_pict3);
            Screen('DrawTexture',window,ObjPres{nTrial,idx_rand(4)},[],positions_pict4);
            Screen('DrawTexture',window,ObjPres{nTrial,idx_rand(5)},[],positions_pict5);
            Screen('DrawTexture',window,ObjPres{nTrial,idx_rand(6)},[],positions_pict6);
            
            % draw response options, shifted 60 pixels to make them visible
            Screen('DrawText', window, '7', positions_pict1(1)+60, positions_pict1(2)+60, black);
            Screen('DrawText', window, '4', positions_pict2(1)+60, positions_pict2(2)+60, black);
            Screen('DrawText', window, '1', positions_pict3(1)+60, positions_pict3(2)+60, black);
            Screen('DrawText', window, '8', positions_pict4(1)+60, positions_pict4(2)+60, black);
            Screen('DrawText', window, '5', positions_pict5(1)+60, positions_pict5(2)+60, black);
            Screen('DrawText', window, '2', positions_pict6(1)+60, positions_pict6(2)+60, black);
            
            Screen('Flip',window);
            flag=0;
            StimStart = GetSecs;
            while flag ~=1
                [keyIsDown,TimeSecs,AnswerkeyCode] = KbCheck;
                if (keyIsDown && AnswerkeyCode(KbName(OneKey)) == 1 && idx_rand(1) == 1) ;
                    rec(nTrial) = 1;flag=1;
                    rec_rt(nTrial) = TimeSecs - StimStart;
                elseif (keyIsDown && AnswerkeyCode(KbName(TwoKey)) == 1 && idx_rand(2) == 1);
                    rec(nTrial) = 1;flag=1;
                    rec_rt(nTrial) = TimeSecs - StimStart;
                elseif    (keyIsDown && AnswerkeyCode(KbName(ThreeKey)) == 1 && idx_rand(3) == 1);
                    rec(nTrial) = 1;flag=1;
                    rec_rt(nTrial) = TimeSecs - StimStart;
                elseif (keyIsDown && AnswerkeyCode(KbName(FourKey)) == 1 && idx_rand(4) ~= 1);
                    rec(nTrial) = 0; flag=1;
                    rec_rt(nTrial) = TimeSecs - StimStart;
                elseif (keyIsDown && AnswerkeyCode(KbName(FiveKey)) == 1 && idx_rand(5) ~= 1);
                    rec(nTrial) = 0; flag=1;
                    rec_rt(nTrial) = TimeSecs - StimStart;
                elseif(keyIsDown && AnswerkeyCode(KbName(SixKey)) == 1 && idx_rand(6) ~= 1);
                    rec(nTrial) = 0; flag=1;
                    rec_rt(nTrial) = TimeSecs - StimStart;
                elseif keyIsDown && AnswerkeyCode(KbName(CancelExpKey))
                    AbortExp = 1;
                    break;
                else
                    rec(nTrial) = 0;
                    rec_rt(nTrial) = NaN;
                end
                if (GetSecs-StimStart)>=parameter.testfb_rec_duration
                    flag=1;
                end
            end
            
            % inform participant made the incorrect recognition judgment
            if rec(nTrial) == 0;
                Screen('TextSize', window, fbTextSize);
                DrawFormattedText(window, fb_wrong, 'center', 'center', brown)
                Screen('Flip',window);
                StimStart = GetSecs;
                while (GetSecs-StimStart)<=0.5;
                end
                
            else
                rec(nTrial) = 0;
                rec_rt(nTrial) = NaN;
            end
        end
        
        % display feedback
        
        % draw picture (with black border)
        Screen('DrawTexture',window,ObjFeed{nTrial},[],[]); %present center, full-size (as in exposure, learning & priming)
        %Screen('DrawTexture',window,ObjFeed{nTrial},[],position_correct); present below (reduced size--same size as the 6 options)
        
        % draw word
        Screen('TextSize', window, TextSize);
        DrawFormattedText(window, test_fb_struct_1{nTrial}.word, 'center', (svCenter-svCenter/3),blue); %display above centered image (as in exposure, learning & priming)
        %DrawFormattedText(window, test_fb_struct_1{nTrial}.word, 'center', %'center', blue) %present at fixation
       
        Screen('Flip',window);
        
        StimStart = GetSecs;
        while (GetSecs-StimStart) <= parameter.fb_duration;
            [keyIsDown,TimeSecs,AnswerkeyCode] = KbCheck;
            if keyIsDown && AnswerkeyCode(KbName(CancelExpKey))
                AbortExp = 1;
                break;
            end
            
        end
        
        % display isi
        % draw cross
        Screen('TextSize', window, TextSize);
        Screen('DrawText', window, Crosshair, a, b, white);
        Screen('DrawText', window, Crosshair, a_offyPos, b_offyNeg, white);
        Screen('DrawText', window, Crosshair, a_offyNeg, b_offyNeg, white);
        Screen('DrawText', window, Crosshair, a_offyNeg, b_offyPos, white);
        Screen('DrawText', window, Crosshair, a_offyPos, b_offyPos, white);
        Screen('DrawText', window, Crosshair, a, b, black); %black cross in center
        
        Screen('Flip',window);
        
        StimStart = GetSecs;
        while (GetSecs-StimStart) <= parameter.test_fb_isi;
            [keyIsDown,TimeSecs,AnswerkeyCode] = KbCheck;
            if keyIsDown && AnswerkeyCode(KbName(CancelExpKey))
                AbortExp = 1;
                break;
            end
            
        end
        
        nTrialWriteout              = nTrial;
        ObjNameWriteout             = test_fb_struct_1{nTrial}.object_target;
        WordWriteout                = test_fb_struct_1{nTrial}.word;
        CondWriteout                = num2str(test_fb_struct_1{nTrial}.cond);
        RecallWriteout              = initial_recall(nTrial);
        RecallRT                    = initial_rec_rt(nTrial);
        RecWriteout                 = rec(nTrial);
        RecRT                       = rec_rt(nTrial);
        Foil_a                      = test_fb_struct_1{nTrial}.object_foil1; %note that position was randomized, this doesn't reflect position on screen
        Foil_b                      = test_fb_struct_1{nTrial}.object_foil2; %note that position was randomized, this doesn't reflect position on screen
        Foil_c                      = test_fb_struct_1{nTrial}.object_foil3; %note that position was randomized, this doesn't reflect position on screen
        Foil_d                      = test_fb_struct_1{nTrial}.object_foil4; %note that position was randomized, this doesn't reflect position on screen
        Foil_e                      = test_fb_struct_1{nTrial}.object_foil5; %note that position was randomized, this doesn't reflect position on screen
        
        fprintf(fid,'%1.0f\t %s\t %s\t %s\t %1.0f\t %5.4f\t %1.0f\t %5.4f\t %s\t %s\t %s\t %s\t %s\n ',...
            nTrialWriteout,ObjNameWriteout,WordWriteout,CondWriteout,RecallWriteout,RecallRT,RecWriteout,RecRT,Foil_a,Foil_b,Foil_c,Foil_d,Foil_e);
        
        if AbortExp; break; end
        
    end
    
    % compute score (only counting critical TNT pairs--ignores fillers)
    inc_think =0; inc_nothink = 0; inc_bas = 0;
    for i = 1:length(test_fb_struct_1);
        if test_fb_struct_1{i}.cond == 1
            inc_think = inc_think+1;
            rec_think(inc_think) = rec(i);
        elseif test_fb_struct_1{i}.cond == 2
            inc_nothink = inc_nothink+1;
            rec_nothink(inc_nothink) = rec(i);
        elseif test_fb_struct_1{i}.cond == 3
            inc_bas = inc_bas+1;
            rec_bas(inc_bas) = rec(i);
        end
    end
    
    Output_testfb1.rec_think_mean = mean(rec_think);
    Output_testfb1.rec_nothink_mean = mean(rec_nothink);
    Output_testfb1.rec_bas_mean = mean(rec_bas);
    total_mean = mean([mean(rec_think),mean(rec_nothink),mean(rec_bas)]);
    Output_testfb1.rec_total_mean = total_mean;
    
    if total_mean >= (43/48); %if ?89.5% of 48 (16items*3conditions) of *critical* items for this time point correct
        Output_testfb1.criterion = 1;
        perftext = [sprintf('%0d %% correct, WELL DONE!',round(total_mean*100))];
        DrawFormattedText(window, perftext, 'center', 'center', BlackIndex(window));
        Screen('Flip', window);
        StimStart = GetSecs;
        while (GetSecs-StimStart) <= 5;
            [keyIsDown,TimeSecs,AnswerkeyCode] = KbCheck;
            if keyIsDown && AnswerkeyCode(KbName(CancelExpKey))
                AbortExp = 1;
                break;
            end
            
        end
    else
        Output_testfb1.criterion = 0;
        
        perftext = [sprintf('%0d %% correct, please try again...',round(total_mean*100))];
        DrawFormattedText(window, perftext, 'center', 'center', BlackIndex(window));
        Screen('Flip', window);
        StimStart = GetSecs;
        while (GetSecs-StimStart) <= 5;
            [keyIsDown,TimeSecs,AnswerkeyCode] = KbCheck;
            if keyIsDown && AnswerkeyCode(KbName(CancelExpKey))
                AbortExp = 1;
                break;
            end
            
        end
    end
    
    endtext = ['Please relax and\n' ...
        'wait for further instructions'];
    
    DrawFormattedText(window, endtext, 'center', 'center', BlackIndex(window));
    
    % Update the display to show the instruction text:
    Screen('Flip', window);
    
    % Wait for mouse click:
    GetClicks(window);
    
    % Clear screen to background color (our 'gray' as set at the
    % beginning):
    Screen('Flip', window);
    
    Screen('CloseAll');
    ShowCursor;
    Priority(0);
    fclose('all');
    
catch % catch error
    Screen('CloseAll');
    ShowCursor;
    Priority(0);
    psychrethrow(psychlasterror);
    
end % try ... catch %


run_testfeedback_1.m

Open with





