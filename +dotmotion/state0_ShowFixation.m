classdef dotMotionState0 < stimuli.state
  % state 0 - wait for fixation

  % 07-07-2016 - Shaun L. Cloherty <s.cloherty@ieee.org>
  % 01-05-2017 - Jake L. Yates <jacoby8s@gmail.com>

  properties
    tStart = 0; % keep trial time in PLDAPS trial time
    
    % properties for flashing the fixation target
    showFix@logical = true;
    frameCnt = 0; % frame counter
  end
  
  methods (Access = public)
    function s = dotMotionState0(hTrial,varargin)
      fprintf(1,'dotMotionState0()\n');
      
      s = s@stimuli.state(0,hTrial); % call the parent constructor      
    end
    
   % --- Drawing commands
    function beforeFrame(s)
      fprintf(1,'dotMotionState0.beforeFrame()\n');
      
      hTrial = s.hTrial;

      if hTrial.showFix && s.showFix
        hTrial.hFix(1).beforeFrame(); % draw fixation target
      end
    end
    
    % -- Evaluate states (prepare before drawing)
    function afterFrame(s,t)
%       fprintf(1,'dotMotionState0.afterFrame()\n');
            
      hTrial = s.hTrial;
      
      s.frameCnt = mod(s.frameCnt+1,hTrial.fixFlashCnt);
      if s.frameCnt == 0
        s.showFix = ~s.showFix; % toggle fixation target
      end
      
      if t > (s.tStart + hTrial.trialTimeout)
        % failed to initiate the trial... move to state 7 - timeout interval
        hTrial.error = 1;
        hTrial.setState(7);
        return
      end
      
      r = norm([hTrial.x,hTrial.y]);
      fprintf(1, 'Eye distance : %2.2f Window: %02.2f\n', r, hTrial.fixWinRadius)
      
      if (r < hTrial.fixWinRadius)
        % move to state 1 - fixation grace period
        hTrial.setState(1);
        return
      end
    end
    
  end % methods
  
end % classdef