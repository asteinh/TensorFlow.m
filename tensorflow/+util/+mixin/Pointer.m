classdef Pointer < util.mixin.Base
  %POINTER Summary of this class goes here
  %   Detailed explanation goes here

  properties (SetAccess=private, GetAccess=protected)
    ref = uint64([]);
    is_owned = true;
  end

  methods
    function obj = Pointer(ref, owned)
      assert(~isempty(ref) && isa(ref, 'uint64') && ref ~= 0, 'You must supply a non-empty, non-zero reference of type ''uint64''.');
      obj.ref = ref;

      if nargin == 2 && owned == false
        obj.is_owned = false;
      end
    end

    % check if the Pointer object holds a valid reference
    function res = isempty(obj)
      res = isempty(obj.ref);
    end

    % check if the referenced memory is owned by tensorflow.m
    function res = isowned(obj)
      res = obj.is_owned();
    end

    function delete(obj)
      obj.ref = [];
      delete@util.mixin.Base(obj);
    end
  end
end