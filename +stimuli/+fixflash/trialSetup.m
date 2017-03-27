function trialSetup(p, sn)

	if nargin < 2
		sn = 'stimulus';
	end

p.trial.pldaps.goodtrial = 1;

ppd   = p.trial.display.ppd;        % pixels per degree (linear approximation)
% fps   = p.trial.display.frate;      % frames per second
ctr   = p.trial.display.ctr(1:2);   % center of the screen

% % --- Staircase parameters
% if p.trial.(sn).staircaseOn
%     if p.trial.pldaps.iTrial > 1
%         lastError = p.data{p.trial.pldaps.iTrial - 1}.(sn).hTrial.error;
%         staircased = isfield(q, 'minFixDuration');
%         
%         switch lastError
%             case 0 % held the whole way
%                 if staircased
%                     p.trial.(sn).minFixDuration = p.data{p.trial.pldaps.iTrial-1}.(sn).minFixDuration + p.trial.(sn).staircaseStep;
%                     p.trial.(sn).maxFixDuration = p.data{p.trial.pldaps.iTrial-1}.(sn).maxFixDuration + p.trial.(sn).staircaseStep;
%                 else
%                     p.trial.(sn).minFixDuration = p.trial.(sn).minFixDuration + p.trial.(sn).staircaseStep;
%                     p.trial.(sn).maxFixDuration = p.trial.(sn).maxFixDuration + p.trial.(sn).staircaseStep;
%                 end
%                     
%             case 2 % broke fixation after obtaining
%                 if staircased
%                     p.trial.(sn).minFixDuration = p.data{p.trial.pldaps.iTrial-1}.(sn).minFixDuration - p.trial.(sn).staircaseStep;
%                     p.trial.(sn).maxFixDuration = p.data{p.trial.pldaps.iTrial-1}.(sn).maxFixDuration - p.trial.(sn).staircaseStep;
%                 else
%                     p.trial.(sn).minFixDuration = p.trial.(sn).minFixDuration - p.trial.(sn).staircaseStep;
%                     p.trial.(sn).maxFixDuration = p.trial.(sn).maxFixDuration - p.trial.(sn).staircaseStep;
%                 end
%             otherwise % never obtained fixation -- Do nothing
%                 
%         end
%         
%     end % trial number
%     
%     
% end % staircase on

% --- Fixation position
if p.trial.(sn).fixationJitter
    xpos = p.trial.(sn).fixationJitterSize * randn + p.trial.(sn).fixationX;
    ypos = p.trial.(sn).fixationJitterSize * randn + p.trial.(sn).fixationY;
else
    xpos = p.trial.(sn).fixationX;
    ypos = p.trial.(sn).fixationY;
end

% --- Set Fixation Point Properties
sz = p.trial.(sn).fixPointRadius * ppd;
p.trial.(sn).hFix(1).cSize      = sz;
p.trial.(sn).hFix(1).sSize      = 2*sz;
p.trial.(sn).hFix(1).cColour    = zeros(1,3);
p.trial.(sn).hFix(1).sColour    = ones(1,3);
p.trial.(sn).hFix(1).position   = [xpos ypos] * ppd + ctr;

p.trial.(sn).hFix(2).cSize      = sz;
p.trial.(sn).hFix(2).sSize      = 2*sz;
p.trial.(sn).hFix(2).cColour    = p.trial.display.bgColor + p.trial.(sn).fixPointDim;
p.trial.(sn).hFix(2).sColour    = p.trial.display.bgColor + p.trial.(sn).fixPointDim;
p.trial.(sn).hFix(2).position   = p.trial.(sn).hFix(1).position;

% --- Random seed
p.trial.(sn).rngs.conditionerRNG=RandStream(p.trial.(sn).rngs.randomNumberGenerater, 'seed', p.trial.(sn).rngs.trialSeeds(p.trial.pldaps.iTrial));
setupRNG=p.trial.(sn).rngs.conditionerRNG;

% fixation duration
rnd=rand(setupRNG);
p.trial.(sn).fixDuration = (1 - rnd) * p.trial.(sn).minFixDuration + rnd * p.trial.(sn).maxFixDuration;

assert(p.trial.display.colorclamp | p.trial.display.normalizeColor, 'color range not [0-1]')

% --- Feedback for incorrect choices...
p.trial.(sn).hFbk.size      = 2 * p.trial.(sn).feedbackApertureRadius * ppd;
p.trial.(sn).hFbk.position  = p.trial.(sn).hFix(1).position;
p.trial.(sn).hFbk.colour    = p.trial.display.bgColor + p.trial.(sn).feedbackApertureContrast;
p.trial.(sn).hFbk.weight    = 4;

% --- Face for aditional reward
p.trial.(sn).hFace.size     = 2 * p.trial.(sn).faceRadius * ppd;
p.trial.(sn).hFace.position = p.trial.(sn).hFix(1).position;
p.trial.(sn).hFace.id       = p.trial.(sn).faceIndex;

% --- Reward
p.trial.(sn).hReward.defaultAmount = p.trial.behavior.reward.defaultAmount;
p.trial.(sn).hReward.iTrial        = p.trial.pldaps.iTrial;

% --- Setup dot motion trial
% the @trial object (initially in state 0)
% hFix,hDots,hChoice,hCue,hFace,hReward,
p.trial.(sn).hTrial = stimuli.fixflash.fixFlashTrial( ...
  p.trial.(sn).hFix,p.trial.(sn).hFbk,p.trial.(sn).hFace, ...
  p.trial.(sn).hReward, ...
  'fixWinRadius',p.trial.(sn).fixWinRadius, ...
  'fixGracePeriod',p.trial.(sn).fixGracePeriod, ...
  'minFixation', p.trial.(sn).minFixDuration, ...
  'maxFixation', p.trial.(sn).maxFixDuration, ...
  'fixFlashCnt',p.trial.(sn).fixFlashCnt, ...
  'holdDuration',p.trial.(sn).holdDuration, ...
  'trialTimeout',p.trial.(sn).trialTimeout, ...
  'iti',p.trial.(sn).iti, ...
  'maxRewardCnt',p.trial.(sn).maxRewardCnt, ...
  'viewpoint',false);

%   'fixDuration',p.trial.(sn).fixDuration, ...