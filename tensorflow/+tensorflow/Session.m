classdef Session < util.mixin.Pointer
  %SESSION Summary of this class goes here
  %   Detailed explanation goes here

  properties (SetAccess=protected)
    graph = [];
    opts = [];
    status = [];
  end

  methods
    function obj = Session(graph_)
      assert(isa(graph_, 'tensorflow.Graph'));

      % create SessionOptions and Status
      opts_ = tensorflow.SessionOptions();
      status_ = tensorflow.Status();

      % superclass constructor
      obj = obj@util.mixin.Pointer(mex_call('TF_NewSession', graph_.ref, opts_.ref, status_.ref));

      % obj.graph = graph_;
      obj.opts = opts_;
      obj.status = status_;
      obj.graph = graph_;
    end

    % TF_CAPI_EXPORT extern void TF_CloseSession(TF_Session*, TF_Status* status);
    % TF_CAPI_EXPORT extern void TF_DeleteSession(TF_Session*, TF_Status* status);
    % TF_CAPI_EXPORT extern void TF_SessionRun(TF_Session* session, const TF_Buffer* run_options, const TF_Output* inputs, TF_Tensor* const* input_values, int ninputs, const TF_Output* outputs, TF_Tensor** output_values, int noutputs, const TF_Operation* const* target_opers, int ntargets, TF_Buffer* run_metadata, TF_Status*);
    function res = run(obj, inputs, input_values, outputs, target_opers, run_options, run_metadata)
      if nargin < 4 || nargin > 8
        error('Wrong number of input arguments.');
      end
      assert(isa(inputs, 'tensorflow.Output'));
      assert(isa(input_values, 'tensorflow.Tensor'));
      assert(isa(outputs, 'tensorflow.Output'));

      % TODO additional arguments are not supported yet; consider this pseudo code
      if nargin > 4
        assert(isa(target_opers, 'tensorflow.Operation'));
        ntargets = numel(target_opers);
      else
        target_opers = [];
        ntargets = 0;
      end
      if nargin > 5
        assert(isa(run_options, 'tensorflow.Buffer'));
      else
        run_options = [];
      end
      if nargin > 6
        assert(isa(run_metadata, 'tensorflow.Buffer'));
      else
        run_metadata = [];
      end

      ninputs = numel(inputs);
      assert(ninputs == numel(input_values));
      noutputs = numel(outputs);

      refs = mex_call('TF_SessionRun', obj.ref, run_options, ...
                      uint64([inputs.ref]), uint64([input_values.ref]), int32(ninputs), ...
                      uint64([outputs.ref]), int32(noutputs), ...
                      target_opers, ntargets, run_metadata, obj.status.ref);

      obj.status.maybe_raise();

      res = tensorflow.Tensor.empty(noutputs,0);
      for i = 1:1:noutputs
        res(i) = tensorflow.Tensor(refs(i));
      end

    end

    % TF_CAPI_EXPORT extern void TF_SessionPRunSetup(TF_Session*, const TF_Output* inputs, int ninputs, const TF_Output* outputs, int noutputs, const TF_Operation* const* target_opers, int ntargets, const char** handle, TF_Status*);
    % TF_CAPI_EXPORT extern void TF_SessionPRun(TF_Session*, const char* handle, const TF_Output* inputs, TF_Tensor* const* input_values, int ninputs, const TF_Output* outputs, TF_Tensor** output_values, int noutputs, const TF_Operation* const* target_opers, int ntargets, TF_Status*);
    % TF_CAPI_EXPORT extern TF_DeviceList* TF_SessionListDevices(TF_Session* session, TF_Status* status);

    function delete(obj)
      if ~obj.isempty()
        mex_call('TF_DeleteSession', obj.ref, obj.status.ref);
        obj.status.maybe_raise();
      end
      delete@util.mixin.Pointer(obj);
    end
  end
end
