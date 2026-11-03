function [ conmat ] = rand_FShift_ContraLum(p,RDK,flag_training)
%rand_FShift_ContraLum randomizes experimental conditions
% move onset only works for constant frequency for all RDKs (i.e. 120)




% set trial number etc
if flag_training~=0
    conmat.totaltrials = 2*numel(p.stim.eventnum_t)*p.stim.con_repeats_t;
    conmat.totalblocks = 1;
    p.stim.eventnum = p.stim.eventnum_t;
else
    conmat.totaltrials = sum(numel(p.stim.eventnum_e)*p.stim.con_repeats*numel(p.stim.condition));
    conmat.totalblocks = p.stim.blocknum;
    p.stim.eventnum = p.stim.eventnum_e;
end
conmat.trialsperblock = conmat.totaltrials/conmat.totalblocks;

% matrix with onset times of on framesfor RDKs
t.onframesonset = nan(numel(RDK.RDK),p.scr_refrate*p.stim.time_postcue);
t.onframesonset_times = t.onframesonset; % onset times in s
for i_rdk = 1:numel(RDK.RDK)
    t.mat = ceil(1:p.scr_refrate/RDK.RDK(i_rdk).freq:size(t.onframesonset,2));
    t.onframesonset(i_rdk,t.mat)=1;
    t.onframesonset_times(i_rdk,t.mat)=t.mat./p.scr_refrate;
end

% move
t.movonset_frames=nan(1,p.scr_refrate*p.stim.time_postcue);
t.movonset_times=nan(1,p.scr_refrate*p.stim.time_postcue);
t.mat = 1:p.scr_refrate/RDK.RDK(1).mov_freq:size(t.movonset_frames,2);
t.movonset_frames(t.mat)=1;
t.movonset_times(t.mat)=t.mat./p.scr_refrate;


%% start randomization
% randomize condition
if  conmat.totalblocks == 1
    t.block = randsample(unique(p.stim.con_block),1);
    t.mat = repmat(p.stim.condition(p.stim.con_block==t.block),conmat.totaltrials/sum(p.stim.con_block==t.block),1);
    conmat.mats.condition = t.mat(:)';
else
    t.mat = repmat(p.stim.condition,conmat.totaltrials/numel(p.stim.condition),1);
    conmat.mats.condition = t.mat(:)';
end


% randomize cue (1 = attend to RDK 1; 2 = attend to RDK 2)
t.mat = repmat(1:2,1,numel(p.stim.con_RDK2attend)/2);
conmat.mats.cue = t.mat(conmat.mats.condition);
conmat.mats.cueRDKid = p.stim.con_RDK2attend(conmat.mats.condition);

% track which RDKs to depict
conmat.mats.RDKidcenter = p.stim.con_RDKcenter(conmat.mats.condition,:)';
conmat.mats.RDKidperi = p.stim.con_RDKperi(conmat.mats.condition,:)';

% extract luminance level conditions
conmat.mats.con_lumlevel = p.stim.con_lumlevel(p.stim.condition(conmat.mats.condition));

% randomize event numbers per trial
% check if event numbers add up
if mod(conmat.totaltrials,numel(p.stim.eventnum))~=0 || mod(conmat.totaltrials/numel(p.stim.eventnum),2)~=0
    error('rando:eventdistribute', 'Can not distribute event numbers (ratio: [%s]) equally across %1.0f trials',...
        num2str(p.stim.eventnum), conmat.totaltrials);
end
conmat.mats.eventnum = repmat(p.stim.eventnum,1,conmat.totaltrials/numel(p.stim.eventnum));

% randomize eventtype (1 = target; 2 = distractor)
conmat.mats.eventtype = nan(max(p.stim.eventnum),conmat.totaltrials);
t.evtype = [1 2];
for i_con = 1:numel(p.stim.condition)
    t.idx = conmat.mats.condition==p.stim.condition(i_con);
    for i_eventnum = 1:max(conmat.mats.eventnum)
        t.idx2 = conmat.mats.eventnum == i_eventnum;
        % extract all combinations
        t.text = sprintf('%s,',repmat("t.evtype",i_eventnum,1));
        eval(sprintf('t.all_combs = CombVec(%s);',t.text(1:end-1))) % create all combinations
        
        % randomly select the relevant number
        if size(t.all_combs,2)>sum(t.idx&t.idx2)
            t.evtypemat = t.all_combs(:,randperm(size(t.all_combs,2),sum(t.idx&t.idx2)));
        else
            % adjust!
            t.evtypemat = [repmat(t.all_combs,1,floor(sum(t.idx&t.idx2)/size(t.all_combs,2))) ...
                t.all_combs(:,randperm(size(t.all_combs,2), mod(sum(t.idx&t.idx2),size(t.all_combs,2))))];
        end
        conmat.mats.eventtype(1:i_eventnum,t.idx&t.idx2) = t.evtypemat;
    end
end


% determine event RDK
t.mat = [1 2; 2 1];
conmat.mats.eventRDK = nan(max(p.stim.eventnum),conmat.totaltrials);
conmat.mats.eventRDKid = nan(max(p.stim.eventnum),conmat.totaltrials);
for i_r = 1:size(conmat.mats.eventRDK,1)
    for i_c = 1:size(conmat.mats.eventRDK,2)
        if ~isnan(conmat.mats.eventtype(i_r,i_c))
            conmat.mats.eventRDK(i_r,i_c)=t.mat(conmat.mats.eventtype(i_r,i_c),conmat.mats.cue(i_c));
            conmat.mats.eventRDKid(i_r,i_c)= conmat.mats.RDKidcenter(conmat.mats.eventRDK(i_r,i_c),i_c);
        end
    end
end


% randomize event directions (according to RDK.event.direction)
conmat.mats.eventdirection = nan(max(p.stim.eventnum),conmat.totaltrials);
t.mat = [repmat(1:4,1,floor(sum(~isnan(conmat.mats.eventtype(:)))/4)) randperm(4,mod(sum(~isnan(conmat.mats.eventtype(:))),4))];
conmat.mats.eventdirection(~isnan(conmat.mats.eventtype)) = t.mat(randperm(numel(t.mat)));


% pre-allocate possible presentation times
conmat.mats.event_onset_frames = nan(max(p.stim.eventnum),conmat.totaltrials);
t.poss_frames = find(p.stim.event.min_onset<t.movonset_times & ...
    t.movonset_times<(p.stim.time_postcue-p.stim.event.length-p.stim.event.min_offset));
t.poss_frames_1 = find(p.stim.event.min_onset<t.movonset_times & ...
    t.movonset_times<(p.stim.time_postcue-p.stim.event.length-p.stim.event.min_offset-p.stim.event.min_dist-0.01));
t.poss_frames_2 = find(p.stim.event.min_onset+p.stim.event.min_dist<t.movonset_times & ...
    t.movonset_times<(p.stim.time_postcue-p.stim.event.length-p.stim.event.min_offset));
% loop across conditions
for i_con = 1:numel(p.stim.condition)
    % for single events first
    t.idx = repmat(conmat.mats.cue,2,1) == i_con & repmat(conmat.mats.eventnum,2,1) == 1 & ~isnan(conmat.mats.eventtype);
    if sum(t.idx(:))<numel(t.poss_frames) % if more possible positons than actual events
        t.poss_frames_mat = t.poss_frames(randsample(numel(t.poss_frames),sum(t.idx(:))));
    else
        t.poss_frames_mat = [repmat(t.poss_frames,1,floor(sum(t.idx(:))/numel(t.poss_frames)))...
            t.poss_frames(randsample(numel(t.poss_frames),mod(sum(t.idx(:)),numel(t.poss_frames))))];
    end
    % write to frame mat
    conmat.mats.event_onset_frames(t.idx)=t.poss_frames_mat;
    
    % for two events
    t.idx = repmat(conmat.mats.cue,2,1) == i_con & repmat(conmat.mats.eventnum,2,1) == 2;
    t.idx2=find(t.idx(1,:));
    t.poss_frames_mat = [];
    % loop across all events
    for i_ev = 1:numel(t.idx2)
        t.poss_frames_mat(1,i_ev)= t.poss_frames_1(randperm(numel(t.poss_frames_1),1));
        % index all positions still possible
        t.idx3 = t.poss_frames_2>(t.poss_frames_mat(1,i_ev)+p.stim.event.min_dist*p.scr_refrate);
        t.idx4 = find(t.idx3);
        % randomly select from possible frames (uniqform distribution)
        t.idx5 = t.idx4(randsample(numel(t.idx4),1));
        % randomly select from pssoble frames (beta distribution random number) --> compensate for righward distribution?
%         t.idx5 = round(betarnd(1,5,1)*(t.idx4(end)-t.idx4(1))+t.idx4(1));
        t.idx5 = round(betarnd(1.2,3,1)*(t.idx4(end)-t.idx4(1))+t.idx4(1));
        t.poss_frames_mat(2,i_ev)=t.poss_frames_2(t.idx5);
    end
    conmat.mats.event_onset_frames(t.idx)=t.poss_frames_mat;
    
end
conmat.mats.event_onset_times = conmat.mats.event_onset_frames./p.scr_refrate;
% % graphical check
% figure; subplot(2,1,1);histogram(conmat.mats.event_onset_frames(:),50);subplot(2,1,2);histogram(conmat.mats.event_onset_times(:),50)
% figure; subplot(2,1,1);histogram(diff(conmat.mats.event_onset_frames),50);subplot(2,1,2);histogram(conmat.mats.event_onset_times(:),50)
% 
% for i_tr = 1:100
% test(i_tr,:,:) = conmat.mats.event_onset_times;
% end
% figure; subplot(2,1,1); histogram(test(:)); subplot(2,1,2); histogram(diff(test,1,2))


% randomize pre-cue times
% all possible pre_cue_frames
t.allframes = p.stim.time_precue(1)*p.scr_refrate:p.stim.time_precue(2)*p.scr_refrate;
t.allframes = t.allframes(mod(t.allframes,p.scr_imgmultipl)==0); % only frames that are integers of frames per flip (i.e. 4)
if conmat.totaltrials<numel(t.allframes)
    conmat.mats.pre_cue_frames = t.allframes(randsample(1:numel(t.allframes),conmat.totaltrials));
else
    conmat.mats.pre_cue_frames = [repmat(t.allframes,1,floor(conmat.totaltrials/numel(t.allframes))) ...
        t.allframes(round(linspace(1,numel(t.allframes),mod(conmat.totaltrials,numel(t.allframes)))))];
end
conmat.mats.pre_cue_frames = conmat.mats.pre_cue_frames(randperm(numel(conmat.mats.pre_cue_frames)));
conmat.mats.pre_cue_times = conmat.mats.pre_cue_frames./p.scr_refrate;

% add pre-cue frames to events
conmat.mats.event_onset_times = conmat.mats.event_onset_times+conmat.mats.pre_cue_times;
conmat.mats.event_onset_frames = conmat.mats.event_onset_frames + conmat.mats.pre_cue_frames;

%% randomize all information across experiment
% keep block structure of
t.tidx_step1 = nan(1,conmat.totaltrials);
t.lumlevel =unique(conmat.mats.con_lumlevel);
for i_con = 1:numel(t.lumlevel)
    t.tidx_step1(conmat.mats.con_lumlevel==t.lumlevel(i_con)) = ...
        randsample(find(conmat.mats.con_lumlevel==t.lumlevel(i_con)),sum(conmat.mats.con_lumlevel==t.lumlevel(i_con)));
end
if mod(conmat.totalblocks,numel(p.stim.condition)) ~=0 & flag_training ~= 1
    fprintf("There are %1.0f blocks and %1.0f conditions; They need to be multiples!\n",conmat.totalblocks,numel(p.stim.condition))
    return
end
conmat.mats.block = repmat(1:conmat.totalblocks,conmat.trialsperblock,1);
conmat.mats.block = conmat.mats.block(:)';
% randomize block sequence
t.tidx = nan(1,conmat.totaltrials);
t.tidx_blocks = randperm(conmat.totalblocks);
for i_block = 1:conmat.totalblocks
    % swap trials around
    t.tidx(conmat.mats.block==i_block) = t.tidx_step1(conmat.mats.block==t.tidx_blocks(i_block));
end


% this needs to be checked!!!!!
t.fields = fieldnames(conmat.mats);
t.fields = t.fields(t.fields~="block");
for i_fields = 1:numel(t.fields)
    conmat.mats.(t.fields{i_fields}) = conmat.mats.(t.fields{i_fields})(:,t.tidx);
end


% conmat.mats.condition = conmat.mats.condition(:,t.tidx);
% conmat.mats.cue = conmat.mats.cue(:,t.tidx);
% conmat.mats.cueRDKid = conmat.mats.cueRDKid(:,t.tidx);
% conmat.mats.con_lumlevel = conmat.mats.con_lumlevel(:,t.tidx);
% conmat.mats.RDKidcenter = conmat.mats.RDKidcenter(:,t.tidx);
% conmat.mats.RDKidperi = conmat.mats.RDKidperi(:,t.tidx);
% conmat.mats.eventnum = conmat.mats.eventnum(:,t.tidx);
% conmat.mats.eventtype = conmat.mats.eventtype(:,t.tidx);
% conmat.mats.eventRDK = conmat.mats.eventRDK(:,t.tidx);
% conmat.mats.eventRDKid = conmat.mats.eventRDKid(:,t.tidx);
% conmat.mats.eventdirection = conmat.mats.eventdirection(:,t.tidx);
% conmat.mats.event_onset_frames = conmat.mats.event_onset_frames(:,t.tidx);
% conmat.mats.event_onset_times = conmat.mats.event_onset_times(:,t.tidx);
% conmat.mats.pre_cue_frames = conmat.mats.pre_cue_frames(:,t.tidx);
% conmat.mats.pre_cue_times = conmat.mats.pre_cue_times(:,t.tidx);



%% write all information into trial structure
% create frame mat, onset time for events
t.fields = fieldnames(conmat.mats);
conmat.trials = struct();

for i_field = 1:numel(t.fields)
    if conmat.totaltrials == 1
        if ndims(conmat.mats.(t.fields{i_field}))>1
            values = num2cell(conmat.mats.(t.fields{i_field}),[1,2]);
        else
            values = num2cell(conmat.mats.(t.fields{i_field}),[1]);
        end
    else
        if ndims(conmat.mats.(t.fields{i_field}))>2
            values = num2cell(conmat.mats.(t.fields{i_field}),[1,2]);
        else
            values = num2cell(conmat.mats.(t.fields{i_field}),[1]);
        end
    end
    [conmat.trials(1:conmat.totaltrials).(t.fields{i_field})] = values{:};              % Assign field dynamically
end
% add trial num
t.trials = num2cell(1:conmat.totaltrials);
[conmat.trials(1:conmat.totaltrials).trialnum] = t.trials{:};

% post-cue times
[conmat.trials(1:conmat.totaltrials).post_cue_times] = deal(p.stim.time_postcue);

% post-cue frames
[conmat.trials(1:conmat.totaltrials).post_cue_frames] = deal(p.stim.time_postcue*p.scr_refrate);

    

end

