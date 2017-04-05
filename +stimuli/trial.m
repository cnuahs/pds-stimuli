% abstract class for stimulus paradigm trials

% 07-06-2016 - Shaun L. Cloherty <s.cloherty@ieee.irg>

classdef (Abstract) trial < handle
  % Abstract class for a stimulus paradigm trial.
  %
  % To see the public properties of this class, type
  %
  %   properties(marmoview.trial)
  %
  % To see a list of methods, type
  %
  %   methods(marmoview.trial)
  %
  % The class constructor can be called with a range of arguments:
  %
  %   None.

  % note: the @trial class together with the @state class implement the
  %       so called 'state' pattern... the @trial object provides the
  %       context while the @state class provides the state specific
  %       behaviour and transition logic
  %
  %       we minimize overhead associated with creating the @state objects
  %       by pre-allocating the @state objects in the constructor and then
  %       assigning the appropriate handles to hState as we progress through
  %       the trial

  properties (Access = private)
    % the state object pool
    stateIds@double; % FIXME: this is clunky...
    stateHandles; % cell array of @state object handles

    hState@stimuli.state; % the current @state object
  end

%  properties (Access = {?stimuli.trial,?stimuli.state})
  properties (Access = private)
    numTxTimes@double = 0; % state transition counter
    txTimes@double; % state transition times
  end

  % dependent properties...
  properties (Dependent, SetAccess = private, GetAccess = public)
    stateId@double;
  end

  methods % get/set dependent properties
    % dependent property get methods
    function value = get.stateId(o)
      value = o.hState.id;
    end
  end

  methods (Access = public)
%     function o = trial(varargin),
%     end

    % called before each screen flip
    function beforeFrame(o,varargin)
      o.hState.beforeFrame(varargin{:});
    end

    % called after each screen flip
    function err = afterFrame(o,t,varargin)
      o.hState.afterFrame(t,varargin{:});
    end

    % methods for manipulating the pool of @state objects
    function addState(o,h)
      assert(~any(ismember(o.stateIds,h.id)),'Duplicate state, id = %i',h.id);

      n = length(o.stateIds);

      o.stateIds(n+1) = h.id;
      o.stateHandles{n+1} = h;

%       o.txTimes(n+1) = NaN;
    end

    function setState(o,stateId) % FIXME; varargin?
      % set the current state...
      ii = o.stateIds == stateId;
      o.hState = o.stateHandles{ii};

      % TODO: it seems like this should call setTxTime() to automatically
      %       log state transitions...
    end

    % get/set methods for the state transition times
    function varargout = getTxTime(o,varargin)
      % get state transition time(s)

      id = o.stateId; % default: current state...
      if nargin == 2
        id = varargin{1};
      end

      if nargout > 2
        error('Too many output arguments.')
      end

      varargout{1} = NaN;
      varargout{2} = NaN;

      ii = find(o.txTimes(:,1) == id);

      if isempty(ii) % no state transitions?
        return;
      end

      varargout{1} = o.txTimes(ii(end),2); % most recent transition time
      varargout{2} = o.txTimes(ii,2); % all transition times
    end

    function setTxTime(o,t,varargin)
      % set state transition time

      id = o.stateId; % default: current state...
      if nargin == 3
        id = varargin{1};        
      end
      
      assert(ismember(id,o.stateIds),'Unknown stateId %i',id);
      
      o.numTxTimes = o.numTxTimes + 1;
      o.txTimes(o.numTxTimes,1:2) = [id,t];
    end

  end % public methods

  methods (Static)
    function o = loadobj(o)
      % force legacy trial objects to conform to the new class definition
      %
      % previously, o.txTimes was 1xN, with N being the number of states,
      % and only the most recent state transition time was logged.
      %
      % now all state transitions are logged and o.txTimes is Mx2, with M
      % being the number of state transitions.
      if isprop(o,'numTxTimes')
        return;
      end

      ii = find(~isnan(o.txTimes));

      if isempty(ii)
        return;
      end

      o.numTxTimes = numel(ii);
      o.txTimes = [o.stateIds(ii); o.txTimes(ii)]';
    end
  end

end % classdef
