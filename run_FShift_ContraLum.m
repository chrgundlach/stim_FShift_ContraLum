function [] = run_FShift_ContraLum(sub,flag_training, flag_isolum, flag_block)
% run_FShift_ContraLum(sub,flag_training, flag_isolum, flag_block)
%   runs experiment FShift_ContraLum
%       sub:            participant number
%       flag_training:  1 = do training
%       flag_isolum:    1 = do isoluminance adjustment
%       flag_block:     1 = start with block 1
%           e.g. run_FShift_ContraLum(1,1, 0, 1)
% 
% use standard shifting paradigm use isoluminant colors and colors with additional luminance offset/contrast
% 
%
% to do
%   - specify start colors p.isol.override
%   - do we settle for 2 colors or do we per subject select two out of three colors?
%   - randomization across trials within one block


% Christopher Gundlach, Maria Dotzer, Norman Forschack  Leipzig, 2026, 2024,2023,2021, 2020

if nargin < 4
    help run_FShift_PerIrr
    return
end

%% parameters
% sub = 1; flag_training = 1; flag_block = 1; flag_isolum = 1;
% design
p.sub                   = sub;                  % subject number
p.flag_block            = flag_block;           % block number to start
p.flag_training         = flag_training;        % do training

p.ITI                   = [1000 1000];          % inter trial interval in ms
p.targ_respwin          = [200 1000];           % time window for responses in ms

% screen
p.scr_num               = 1;                    % screen number
p.scr_res               = [1920 1080];          % resolution
p.scr_refrate           = 480;                  % refresh rate in Hz (e.g. 85)
p.scr_color             = [0.074 0.074 0.074 1; ...
                           0.0918 0.0918 0.0918 1];% default: opted for 50 cd/m² [0.083 0.083 0.083]

p.scr_imgmultipl        = 4;

% some isoluminace parameters
p.isol.TrlAdj           = 5;                    % number of trials used for isoluminance adjustment
p.isol.TrlAdj           = 2;                    % number of trials used for isoluminance adjustment
p.isol.MaxStd           = 10;                   % standard deviation tolerated
p.isol.run              = false;                % isoluminance run?
% p.isol.override         = [0.0980 0.0392 0 1; 0 0.0596 0.1490 1;0 0.0745 0 1]; % these are the ones used for p.isol.bckgr = p.scr_color(1:3);
p.isol.override         = [0.0980 0.0392 0 1; 0 0.0596 0.1490 1]; % these are the ones used for p.isol.bckgr = p.scr_color(1:3);
p.isol.override         = [0.1199 0.0506 0.0029 1.0000; 0.0165 0.0982 0.2183 1.0000]; % these are the ones used for p.isol.bckgr = p.scr_color(1:3);

% p.isol.bckgr            = p.scr_color(1:3)+0.2;          % isoluminant to background or different color?
p.isol.bckgr            = p.scr_color;          % isoluminant to background or different color?


% stimplan
p.stim.condition        = [1 2 3 4 5 6 7 8 9 10];    
                        % [Iso1 Iso2; Iso1 Iso2] [Iso1 Iso2; Iso1 Iso2] attended 1 attended 2
                        % [+8%1 +8%2; +8%1 +8%2] [+8%1 +8%2; +8%1 +8%2] attended 1 attended 2
                        % [+16%1 +16%2; +16%1 +16%2] [+16%1 +16%2; +16%1 +16%2] attended 1 attended 2
                        % [+24%1 +24%2; +24%1 +24%2] [+24%1 +24%2; +24%1 +24%2] attended 1 attended 2
                        % [IsoH1 IsoH2; IsoH1 IsoH2] [IsoH1 IsoH2; IsoH1 IsoH2] attended 1 attended 2
p.stim.con_col2attend   = repmat([1 2],1,5);
p.stim.con_lumlevel     = [1 1 2 2 3 3 4 4 5 5]; % which luminance conditions
p.stim.con_iso          = [1 1 0 0 0 0 0 0 1 1]; % which conditions present isoluminant colors
p.stim.con_RDKcenter    = repmat([1 2],10,1) + [0 0 4 4 8 8 12 12 16 16]'; % defines which RDK are shown in center [always RDK1 and RDK2]
p.stim.con_RDKperi      = repmat([3 4],10,1) + [0 0 4 4 8 8 12 12 16 16]';
p.stim.con_RDK2attend   = repmat([1 2],1,5)+ [0 0 4 4 8 8 12 12 16 16];    % defines which RDK to attend in which condition
p.stim.con_bckground    = [ones(1,8) 2 2];
p.stim.con_lumoffset    = [0 0 8 8 16 16 24 24 0 0];
% p.stim.con_lumoffset    = [0 0 80 80 100 100 150 150 0 0]; % test
p.stim.con_block        = [1 1 2 2 3 3 4 4 5 5];
p.stim.eventnum_e       = [0 0 0 0 1 2];        % ratio of eventnumbers for experiment
p.stim.eventnum_t       = [0 1 2];        % ratio of eventnumbers for training
p.stim.con_repeats      = [15];             % trial number/repeats for each eventnum and condition
p.stim.con_repeats_t    = [2];              % trial number/repeats for each eventnum and condition
p.stim.trialnum_t       = 20;               % trial number in training
p.stim.time_postcue     = 2;                % post.cue time in s
p.stim.time_precue      = [1.5 2];          % precue time in s; [upper lower] for randomization
p.stim.event.type       = 2;                % types of events (1 = targets only, 2 = targets + distrators)
p.stim.event.length     = 0.3;              % lengt of events in s
p.stim.event.min_onset  = 0.2;              % min post-cue time before event onset in s
p.stim.event.min_offset = 0;                % min offset from target end to end of trial in s
p.stim.event.min_dist   = 0.8;              % min time between events in s
p.stim.blocknum         = 20;               % number of blocks
p.stim.ITI              = [1 1];            % ITI range in seconds
p.stim.frames_postcue   = p.stim.time_postcue*p.scr_refrate;


% introduce RDK structure
RDK.RDK(1).size         = [154 308];                    % width and height of RDK in pixel; only even values [38 = 9.6°]
RDK.RDK(1).centershift  = [0 0];                        % position of RDK center; x and y deviation from center in pixel
RDK.RDK(1).col          = [1 0.4 0 1; p.scr_color(1,1:3) 0];% "on" and "off" color
RDK.RDK(1).freq         = 0;                            % flicker frequency, frequency of a full "on"-"off"-cycle
RDK.RDK(1).mov_freq     = 120;                          % Defines how frequently the dot position is updated; 0 will adjust the update-frequency to your flicker frequency (i.e. dot position will be updated with every "on"-and every "off"-frame); 120 will update the position for every frame for 120Hz or for every 1. quadrant for 480Hz 
RDK.RDK(1).num          = 85;                           % number of dots % 85
RDK.RDK(1).mov_speed    = 1;                            % movement speed in pixel
RDK.RDK(1).mov_dir      = [0 1; 0 -1; -1 0; 1 0];       % movement direction  [0 1; 0 -1; -1 0; 1 0] = up, down, left, right
RDK.RDK(1).dot_size     = 10;                           % size of dots
RDK.RDK(1).shape        = 1;                            % 1 = square RDK; 0 = ellipse/circle RDK;

RDK.RDK(2).size         = [154 308];                    % width and height of RDK in pixel; only even values [38 = 9.6°]
RDK.RDK(2).centershift  = [0 0];                        % position of RDK center; x and y deviation from center in pixel
RDK.RDK(2).col          = [0 0.4 1 1; p.scr_color(1,1:3) 0];% "on" and "off" color
RDK.RDK(2).freq         = 0;                            % flicker frequency, frequency of a full "on"-"off"-cycle
RDK.RDK(2).mov_freq     = 120;                          % Defines how frequently the dot position is updated; 0 will adjust the update-frequency to your flicker frequency (i.e. dot position will be updated with every "on"-and every "off"-frame); 120 will update the position for every frame for 120Hz or for every 1. quadrant for 480Hz 
RDK.RDK(2).num          = 85;                           % number of dots % 85
RDK.RDK(2).mov_speed    = 1;                            % movement speed in pixel
RDK.RDK(2).mov_dir      = [0 1; 0 -1; -1 0; 1 0];       % movement direction  [0 1; 0 -1; -1 0; 1 0] = up, down, left, right
RDK.RDK(2).dot_size     = 10;                           % size of dots
RDK.RDK(2).shape        = 1;                            % 1 = square RDK; 0 = ellipse/circle RDK;

RDK.RDK(3:4) = RDK.RDK(1:2);

p.stim.pos_shift        = [-255 0; 255 0];              % position shift in pixel for stimuli in periphery [255 = 7.8°] either left or right
p.stim.freqs            = {[20 23];[14 17]};         % frequencies of {[center1 center2];[peri1 peri2]}
% p.stim.colors           = ...                           % "on" and "off" color
%     {[1 0.4 0 1; p.scr_color(1:3) 1];...
%     [0 0.4 1 1; p.scr_color(1:3) 1];...
%     [0 1 0 1; p.scr_color(1:3) 1]; ...
%     [1 0 1 1; p.scr_color(1:3) 1]};

p.stim.colors           = ...                           % "on" and "off" color
    {[1 0.4 0 1; p.scr_color(1:3) 0];...
    [0 0.4 1 1; p.scr_color(1:3) 0]};
    % plot_colorwheel([1 0.4 0; 0 0.4 1; 0 1 0; 1 0 1],'ColorSpace','propixxrgb','LAB_L',50,'NumSegments',60,'AlphaColWheel',1,'LumBackground',100)
p.stim.color_names      = {'redish';'blue'};
 
RDK.event.type          = 'globalmotion';       % event type global motion
RDK.event.duration      = p.stim.event.length;  % time of coherent motion
RDK.event.coherence     = .4;                   % percentage of coherently moving dots 0.4 [changed from 0.4 to 0.3 to 0.4]
RDK.event.direction     = RDK.RDK(1).mov_dir;   % movement directions for events

% fixation cross
p.crs.color             = [0.4 0.4 0.4 1];      % color of fixation cross
p.crs.size              = 12;                   % size of fixation
p.crs.width             = 2;                    % width of fixation cross
p.crs.cutout            = 0;                    % 1 = no dots close to fixation cross

% trigger
p.trig.rec_start        = 253;                  % trigger to start recording
p.trig.rec_stop         = 254;                  % trigger to stop recording
p.trig.tr_start         = 77;                   % trial start; main experiment
p.trig.tr_stop          = 88;                   % trial end; main experiment
p.trig.tr_con_colatt    = (p.stim.con_col2attend-1)*100; % which central RDK color attended?
p.trig.tr_con_lum       = p.stim.con_lumlevel*10;    % which luminance condition
p.trig.tr_num_eve       = [0 1 2];              % which luminance condition
p.trig.button           = 2;                    % button press (higher value as it is coded by pins 8 to 16)
p.trig.event_type       = [241 242];              % target, distractor

% possible condition triggers:
% {[10 11 12]; [110 111 112]; [20 21 22]; [120 121 122]; [30 31 32]; [130 131 132];
% [40 41 42]; [140 141 142]; [50 51 52]; [150 151 152]}

% logfiles
p.log.path              = '/home/stimulation120/matlab/user/christopher/stim_FShift_ContraLum/logfiles/';
p.log.exp_name          = 'SSVEP_FShift_ContraLum';
p.log.add               = '_a';


%% check for logfile being present
filecheck=dir(sprintf('%sVP%02.0f_timing*',p.log.path,p.sub));
if ~isempty(filecheck)
    reply = input(sprintf('\nVP%02.0f existiert bereits. Datei überschreiben? [j/n]... ',p.sub),'s');
    if strcmp(reply,'j')
        p.filename = sprintf('VP%02.0f_timing',p.sub);
    else
        [temp name_ind]=max(cellfun(@(x) numel(x), {filecheck.name}));
        p.filename = sprintf('%s%s',filecheck(name_ind).name(1:end-4),p.log.add);
    end
else
    p.filename = sprintf('VP%02.0f_timing',p.sub);
end

t.isol = {};
% routine to check for older isoluminance adjustments
for i_file = 1:numel(filecheck)
    t.in = load(fullfile(filecheck(i_file).folder,filecheck(i_file).name));
    t.datenum{i_file} = filecheck(i_file).datenum;
    t.isol{i_file} = t.in.p.isol;
    
end



%% Screen init
ps.input = struct('ScrNum',p.scr_num,'RefRate',p.scr_refrate,'PRPXres',p.scr_res,'BckGrCol',p.isol.bckgr(1,:) ,'PRPXmode',2);
[~, ps.screensize, ps.xCenter, ps.yCenter, ps.window, ps.framerate, ps.RespDev, ps.keymap] = PTExpInit_GLSL(ps.input,1);
% % testing at home
% ps.input = struct('ScrNum',2,'RefRate',60,'PRPXres',p.scr_res,'BckGrCol',p.scr_color(1,:),'PRPXmode',0);
% [~, ps.screensize, ps.xCenter, ps.yCenter, ps.window, ps.framerate, ps.RespDev, ps.keymap] = PTExpInit_GLSL_adj(ps.input,0);

% some initial calculations
% fixation cross
ps.center = [ps.xCenter ps.yCenter];
p.crs.half = p.crs.size/2;
p.crs.bars = [-p.crs.half p.crs.half 0 0; 0 0 -p.crs.half p.crs.half];

% shift into 4 quadrants (running with 480 Hz)
ps.shift = [-ps.xCenter/2, -ps.yCenter/2; ps.xCenter/2, -ps.yCenter/2;... % shifts to four quadrants: upper left, upper right, lower left, lower right
    -ps.xCenter/2, ps.yCenter/2; ps.xCenter/2, ps.yCenter/2];

p.crs.lines = [];
for i_quad=1:p.scr_imgmultipl
    p.crs.lines = cat(2, p.crs.lines, [p.crs.bars(1,:)+ps.shift(i_quad,1); p.crs.bars(2,:)+ps.shift(i_quad,2)]); %array with start and end points for the fixation cross lines, for all four quadrants
end

%% keyboard and ports setup ???
KbName('UnifyKeyNames')
Buttons = [KbName('ESCAPE') KbName('Q') KbName('SPACE') KbName('j') KbName('n') KbName('1!') KbName('2@') KbName('3#') KbName('m')];
RestrictKeysForKbCheck(Buttons);
key.keymap=false(1,256);
key.keymap(Buttons) = true;
key.keymap_ind = find(key.keymap);
[key.ESC, key.SECRET, key.SPACE, key.YES, key.NO] = deal(...
    Buttons(1),Buttons(2),Buttons(3),Buttons(4),Buttons(5));

%% start experiment
% initialize randomization of stimulation frequencies and RDK colors
% inititalize RDKs [RDK1 and RDK2 task relevant at center;  RDK3 RDK4 not and in periphery]
rng(1,'v4')
% quasi randomize position
t.pos = [];
for i_rep = 1:100
    t.pos = cat(1,t.pos,p.stim.pos_shift(randsample(1:2,2),:));
end
% random position shift in periphery
[RDK.RDK(3:4).centershift] = deal(t.pos(p.sub,:));

% rand('state',p.sub)
rng(p.sub,'v4')

% randomize frequencies
t.val = num2cell(p.stim.freqs{1}(randperm(2)));
[RDK.RDK(1:2).freq] = t.val{:};
t.val = num2cell(p.stim.freqs{2}(randperm(2)));
[RDK.RDK(3:4).freq] = t.val{:};

% assign color values
% use isol override
p.isol.init_cols = p.isol.override;
for i_rdk= 1:4
    RDK.RDK(i_rdk).col(1,:) = p.isol.init_cols(abs(mod(i_rdk,2)-2),:);
end
RDK.RDK = repmat(RDK.RDK,1,5);

p.isol.R=[0.665 0.321]; p.isol.G=[0.172 0.726]; p.isol.B=[0.163 0.039]; %propix phosphors, don't change
p.isol.WP=[0.3127 0.3290 1-0.3127-0.3290]; %D65
t.cols_lab = repmat( ... % what are the CIE LAB colors?
    xyz2lab(rgb2xyz_custom([RDK.RDK(1).col(1,1:3); RDK.RDK(2).col(1,1:3)],p.isol.R,p.isol.G,p.isol.B,p.isol.WP)), ...
    numel(p.stim.condition),1);
t.cols_bckgr_rgb = p.scr_color(reshape(repmat(p.stim.con_bckground,2,1),1,[]),1:3); % background RGBs
t.cols_bckgr_lab = xyz2lab(rgb2xyz_custom(t.cols_bckgr_rgb,p.isol.R,p.isol.G,p.isol.B,p.isol.WP)); % background LAB
t.cols_new_lum =  t.cols_bckgr_lab(:,1) .* (1+reshape(repmat(p.stim.con_lumoffset,2,1),1,[])/100)'; %new luminance values
t.cols_new_lab = [t.cols_new_lum t.cols_lab(:,2:end)];
t.cols_new_rgb = xyz2rgb_custom(lab2xyz(t.cols_new_lab),p.isol.R,p.isol.G,p.isol.B,p.isol.WP); % final RGB values
% write everything into RDK
for i_rdk=1:numel(RDK.RDK)
    RDK.RDK(i_rdk).col(1,1:3) = t.cols_new_rgb(i_rdk,:); % rdk 
    RDK.RDK(i_rdk).col(2,1:3) = t.cols_bckgr_rgb(i_rdk,:); % background
end

% initialize blank variables
timing = []; button_presses = []; resp = []; randmat = [];

%% initial training
if p.flag_training
    fprintf(1,'\nTraing starten mit q')
    inp.prompt_check = 0;
    while inp.prompt_check == 0             % loop to check for correct input
        [key.keyisdown,key.secs,key.keycode] = KbCheck;
        if key.keycode(key.SECRET)==1
            flag_trainend = 0; inp.prompt_check = 1;
        end
        Screen('Flip', ps.window, 0);
    end
    
    
    i_bl = 1;
    flag_trainend = 0;
    while flag_trainend == 0 % do training until ended
        %rand('state',p.sub*i_bl) % determine randstate
        rng(p.sub*i_bl,'v4')
        randmat.training{i_bl} = rand_FShift_ContraLum(p, RDK,  1);
        [timing.training{i_bl},button_presses.training{i_bl},resp.training{i_bl}] = ...
            pres_FShift_ContraLum(p, ps, key, RDK, randmat.training{i_bl}, i_bl,1);
        save(sprintf('%s%s',p.log.path,p.filename),'timing','button_presses','resp','randmat','p', 'RDK')
        pres_feedback(resp.training{i_bl},p,ps, key,RDK)
               
        % loop for training to be repeated
        fprintf(1,'\nTraing wiederholen? (j/n)')
        inp.prompt_check = 0;
        while inp.prompt_check == 0             % loop to check for correct input
            [key.keyisdown,key.secs,key.keycode] = KbCheck; 
            if key.keycode(key.YES)==1
                i_bl = i_bl + 1; flag_trainend = 0; inp.prompt_check = 1;
            elseif key.keycode(key.NO)==1
                flag_trainend = 1; inp.prompt_check = 1;
            end
            Screen('Flip', ps.window, 0);
        end  
        
    end
end

%% then isoluminance adjustment
% do the heterochromatic flicker photometry
ttt=WaitSecs(0.7);
if flag_isolum == 1
%     
%     PsychDefaultSetup(2);
%     Datapixx('Open');
%     Datapixx('SetPropixxDlpSequenceProgram', 0);
%     Datapixx('RegWrRd');
        
    % % start isoluminance script only RGB output (no alpha)
    % [Col2Use] = PRPX_IsolCol_480_adj(...
    %     [p.isol.bckgr(1:3); p.isol.init_cols(:,1:3)],...
    %     p.isol.TrlAdj,...
    %     p.isol.MaxStd,...
    %     cellfun(@(x) x(1), {RDK.RDK.centershift})',...
    %     RDK.RDK(1).size);
    % start isoluminance for first background
    [Col2Use] = PRPX_IsolCol_480_Lab_wDots(...
        [p.isol.bckgr(1, 1:3); p.isol.init_cols(:,1:3)],...
        p.isol.TrlAdj,...
        p.isol.MaxStd,...
        0,...
        RDK.RDK(1).size.*2,...
        RDK.RDK(2)); % do iso adjustments with an RDK stimulus

     % start isoluminance for second background
    [Col2Use2] = PRPX_IsolCol_480_Lab_wDots(...
        [p.isol.bckgr(2, 1:3); p.isol.init_cols(:,1:3)],...
        p.isol.TrlAdj,...
        p.isol.MaxStd,...
        0,...
        RDK.RDK(1).size.*2,...
        RDK.RDK(2)); % do iso adjustments with an RDK stimulus
    
    % assign values to RDKs; compute colors according to luminance contrast levels
    t.cols_lab = repmat( ... % what are the CIE LAB colors?
        xyz2lab(rgb2xyz_custom(Col2Use(2:end,:),p.isol.R,p.isol.G,p.isol.B,p.isol.WP)), ...
        numel(p.stim.condition),1);
    t.cols_new_lum =  t.cols_lab(:,1) .* (1+reshape(repmat(p.stim.con_lumoffset,2,1),1,[])/100)'; %new luminance values
    t.cols_new_lab = [t.cols_new_lum t.cols_lab(:,2:end)];
    t.cols_new_rgb = xyz2rgb_custom(lab2xyz(t.cols_new_lab),p.isol.R,p.isol.G,p.isol.B,p.isol.WP); % final RGB values
    % write everything into RDK
    for i_rdk=1:numel(RDK.RDK)
        RDK.RDK(i_rdk).col(1,1:3) = t.cols_new_rgb(i_rdk,:); % rdk
    end
    % use different value for the last 4 RDKs (they have different background)
    for i_rdk= (1:4)+16
        RDK.RDK(i_rdk).col(1,1:3) = Col2Use2(1+abs(mod(i_rdk,2)-2),:);
    end
    % index function execution
    p.isol.run = sprintf('originally run: %s',datestr(now));
    p.isol.coladj = [Col2Use(2:end,:) ones(size(Col2Use,1)-1,1)];
    p.isol.RDKadj = RDK.RDK;
    save(sprintf('%s%s',p.log.path,p.filename),'timing','button_presses','resp','randmat','p', 'RDK')
    
    fprintf('\nadjusted colors:\n')
    for i_col = 1:size(p.isol.coladj,1)
        fprintf('RDK%1.0f [%1.4f %1.4f %1.4f %1.4f]\n', i_col,p.isol.coladj(i_col,:))
    end
    
    
else
    % select colors differently
    fprintf(1,'\nKeine Isoluminanzeinstellung. Wie soll verfahren werden?')
    % specify options
    % option1: use default values
    isol.opt(1).available = true;
    t.cols = cell2mat({RDK.RDK(:).col}');
    isol.opt(1).colors = t.cols(1:2:end,:);
    % isol.opt(1).text = sprintf('default: %s',sprintf('[%1.2f %1.2f %1.2f] ',isol.opt(1).colors(:,1:3)'));
    isol.opt(1).text = sprintf('default RDK colors: %s',sprintf('[%1.2f %1.2f %1.2f] ',isol.opt(1).colors(1:2,1:3)'));
    % option2: use isoluminance values of previously saved dataset
    if ~isempty(t.isol) % file loaded 
        [t.t t.idx] = max(cell2mat(t.datenum));
        if any(strcmp(fieldnames(t.isol{t.idx}),'coladj')) % and adjusted colors exist?s
            isol.opt(2).available = true;
            % isol.opt(2).colors = t.isol{t.idx}.coladj(1:end,:);
            t.cols = cell2mat({t.isol{t.idx}.RDKadj(:).col}');
            isol.opt(2).colors = t.cols(1:2:end,:);
            % isol.opt(2).text = sprintf('aus gespeicherter Datei: %s',sprintf('[%1.2f %1.2f %1.2f] ',isol.opt(2).colors(:,1:3)'));
            isol.opt(2).text = sprintf('aus gespeicherter Datei alte Iso: %s',sprintf('[%1.2f %1.2f %1.2f] ',isol.opt(2).colors(1:2,1:3)'));
        else
            isol.opt(2).available = false;
            isol.opt(2).colors = [];
            isol.opt(2).text = [];
        end
    else
        isol.opt(2).available = false;
        isol.opt(2).colors = [];
        isol.opt(2).text = [];
    end
    % % option3: use manual override
    % if ~isempty(p.isol.override)
    %     isol.opt(3).available = true;
    %     isol.opt(3).colors = p.isol.override;
    %     isol.opt(3).text = sprintf('manuell definiert in p.isol override: %s',sprintf('[%1.2f %1.2f %1.2f] ',isol.opt(3).colors(:,1:3)'));
    % else
    %     isol.opt(3).available = false;
    %     isol.opt(3).colors = [];
    %     isol.opt(3).text = [];
    % end
    % check for buttons
    IsoButtons = Buttons(6:8);
    isol.prompt.idx = find([isol.opt(:).available]);
    t.prompt = [];
    for i_prompt = 1:numel(isol.prompt.idx)
        t.prompt = [t.prompt sprintf('\n(%1.0f) %s',i_prompt,isol.opt(isol.prompt.idx(i_prompt)).text)];
    end
    
    % display options
    fprintf('%s',t.prompt)
    inp.prompt_check = 0;
    while inp.prompt_check == 0             % loop to check for correct input
        [key.keyisdown,key.secs,key.keycode] = KbCheck;
        if any(key.keycode)
            inp.prompt_check = 1;
        end
        Screen('Flip', ps.window, 0);
    end
    Col2Use = isol.opt(isol.prompt.idx(key.keycode(IsoButtons(1:numel(isol.prompt.idx)))==1)).colors;
    % use selected colors
    for i_RDK = 1:numel(RDK.RDK)
        RDK.RDK(i_RDK).col(1,:) = Col2Use(i_RDK,:);        
    end
    % index function execution
    switch isol.prompt.idx(key.keycode(IsoButtons(1:numel(isol.prompt.idx)))==1)
        case 1
            p.isol.run = sprintf('default at %s',datestr(now));
        case 2
            p.isol.run = sprintf('reloaded at %s from %s',datestr(now),datestr(t.datenum{t.idx}));
        case 3
            p.isol.run = sprintf('override at %s',datestr(now));
    end
    p.isol.coladj = Col2Use;
    p.isol.RDKadj = RDK.RDK;
%     save(sprintf('%s%s',p.log.path,p.filename),'timing','button_presses','resp','randmat','p', 'RDK')
    
    fprintf('\nselected colors:\n')
    for i_col = 1:size(p.isol.coladj,1)
        fprintf('RDK%1.0f [%1.4f %1.4f %1.4f %1.4f]\n', i_col,p.isol.coladj(i_col,:))
    end
end

%% redo initialization
ps.input = struct('ScrNum',p.scr_num,'RefRate',p.scr_refrate,'PRPXres',p.scr_res,'BckGrCol',p.scr_color(1,:),'PRPXmode',2);
[~, ps.screensize, ps.xCenter, ps.yCenter, ps.window, ps.framerate, ps.RespDev, ps.keymap] = PTExpInit_GLSL(ps.input,1);

% some initial calculations
% fixation cross
ps.center = [ps.xCenter ps.yCenter];
p.crs.half = p.crs.size/2;
p.crs.bars = [-p.crs.half p.crs.half 0 0; 0 0 -p.crs.half p.crs.half];

% shift into 4 quadrants (running with 480 Hz)
ps.shift = [-ps.xCenter/2, -ps.yCenter/2; ps.xCenter/2, -ps.yCenter/2;... % shifts to four quadrants: upper left, upper right, lower left, lower right
    -ps.xCenter/2, ps.yCenter/2; ps.xCenter/2, ps.yCenter/2];

p.crs.lines = [];
for i_quad=1:p.scr_imgmultipl
    p.crs.lines = cat(2, p.crs.lines, [p.crs.bars(1,:)+ps.shift(i_quad,1); p.crs.bars(2,:)+ps.shift(i_quad,2)]); %array with start and end points for the fixation cross lines, for all four quadrants
end

% keyboard setup
KbName('UnifyKeyNames')
Buttons = [KbName('ESCAPE') KbName('Q') KbName('SPACE') KbName('j') KbName('n') KbName('1!') KbName('2@') KbName('3#')];
RestrictKeysForKbCheck(Buttons);
key.keymap=false(1,256);
key.keymap(Buttons) = true;
key.keymap_ind = find(key.keymap);
[key.ESC, key.SECRET, key.SPACE, key.YES, key.NO] = deal(...
    Buttons(1),Buttons(2),Buttons(3),Buttons(4),Buttons(5));


%% do training again?
% loop for training to be repeated
fprintf(1,'\nTraing starten (j/n)')
inp.prompt_check = 0;
while inp.prompt_check == 0             % loop to check for correct input
    [key.keyisdown,key.secs,key.keycode] = KbCheck;
    if key.keycode(key.YES)==1
        flag_trainend = 0; inp.prompt_check = 1;
    elseif key.keycode(key.NO)==1
        flag_trainend = 1; inp.prompt_check = 1;
    end
    Screen('Flip', ps.window, 0);
end

if ~exist('i_bl'); i_bl = 1; end
while flag_trainend == 0 % do training until ended
    %rand('state',p.sub*i_bl) % determine randstate
    rng(p.sub*i_bl,'v4')
    randmat.training{i_bl} = rand_FShift_ContraLum(p, RDK,  1);
    [timing.training{i_bl},button_presses.training{i_bl},resp.training{i_bl}] = ...
        pres_FShift_ContraLum(p, ps, key, RDK, randmat.training{i_bl}, i_bl,1);
    save(sprintf('%s%s',p.log.path,p.filename),'timing','button_presses','resp','randmat','p', 'RDK')
    pres_feedback(resp.training{i_bl},p,ps, key,RDK)
    
    % loop for training to be repeated
    fprintf(1,'\nTraing wiederholen? (j/n)')
    inp.prompt_check = 0;
    while inp.prompt_check == 0             % loop to check for correct input
        [key.keyisdown,key.secs,key.keycode] = KbCheck;
        if key.keycode(key.YES)==1
            i_bl = i_bl + 1; flag_trainend = 0; inp.prompt_check = 1;
        elseif key.keycode(key.NO)==1
            flag_trainend = 1; inp.prompt_check = 1;
        end
        Screen('Flip', ps.window, 0);
    end
    
end


%% present each block
% randomization
% rand('state',p.sub);                         % determine randstate
rng(p.sub,'v4')
randmat.experiment = rand_FShift_ContraLum(p, RDK,  0);    % randomization
for i_bl = p.flag_block:p.stim.blocknum
    % start experiment
    [timing.experiment{i_bl},button_presses.experiment{i_bl},resp.experiment{i_bl}] = ...
        pres_FShift_ContraLum(p, ps, key, RDK, randmat.experiment, i_bl,0);
    % save logfiles
    save(sprintf('%s%s',p.log.path,p.filename),'timing','button_presses','resp','randmat','p', 'RDK')
          
    pres_feedback(resp.experiment{i_bl},p,ps, key, RDK)    
end

fprintf(1,'\n\nENDE\n')

%Close everything
Datapixx('SetPropixxDlpSequenceProgram', 0);
Datapixx('RegWrRd');
Datapixx('close');
ppdev_mex('Close', 1);
ListenChar(0);
sca;


end

