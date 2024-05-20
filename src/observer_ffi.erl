-module(observer_ffi).
-export([
    start_stateless/0,
    add_stateless/2,
    invoke_stateless/2,
    remove_stateless/2,
    stop_stateless/1,
    start_stateful/1,
    add_stateful/2,
    current_state/1,
    invoke_stateful/2,
    remove_stateful/2,
    stop_stateful/1
]).

%% Helper functions
%% ================

%% Spawns processes to invoke each callback with the provided value,
%% and waits for all of them to complete.
spawn_invoke(Callbacks, Value) ->
    Monitors = lists:map(
        fun({_, Callback}) ->
            {_, Ref} = spawn_monitor(fun() -> Callback(Value) end),
            Ref
        end,
        maps:to_list(Callbacks)
    ),
    wait_for_monitors(Monitors).

%% Waits for all monitored processes to complete.
wait_for_monitors([]) ->
    ok;
wait_for_monitors([Ref | Rest]) ->
    receive
        {'DOWN', Ref, process, _, _} ->
            wait_for_monitors(Rest)
    end.

%% Stateless observer
%% ==================

%% Starts the stateless observer process.
start_stateless() ->
    spawn(fun() -> stateless_loop(#{}, 0) end).

%% The main loop for the stateless observer.
stateless_loop(Callbacks, Index) ->
    receive
        {add, Callback, From} ->
            NewIndex = Index + 1,
            NewCallbacks = Callbacks#{NewIndex => Callback},
            From ! {ok, NewIndex},
            stateless_loop(NewCallbacks, NewIndex);
        {invoke, Value, From} ->
            spawn_invoke(Callbacks, Value),
            From ! {ok},
            stateless_loop(Callbacks, Index);
        {remove, Id} ->
            NewCallbacks = maps:remove(Id, Callbacks),
            stateless_loop(NewCallbacks, Index);
        stop ->
            ok
    end.

%% Adds a callback to the stateless observer, returning the index.
add_stateless(Process, Callback) ->
    Process ! {add, Callback, self()},
    receive
        {ok, Index} -> Index
    end.

%% Invokes all callbacks in parallel with the given value and waits for all of them to complete.
invoke_stateless(Process, Value) ->
    Process ! {invoke, Value, self()},
    receive
        {ok} -> ok
    end.

%% Removes a callback by its index.
remove_stateless(Process, Index) ->
    Process ! {remove, Index}.

%% Stops the stateless observer process.
stop_stateless(Process) ->
    Process ! stop.

%% Stateful observer
%% =================

%% Starts the stateful observer process with an initial state.
start_stateful(State) ->
    spawn(fun() -> stateful_loop(State, #{}, 0) end).

%% The main loop for the stateful observer.
stateful_loop(State, Callbacks, Index) ->
    receive
        {add, Callback, From} ->
            NewIndex = Index + 1,
            NewCallbacks = Callbacks#{NewIndex => Callback},
            From ! {ok, State, NewIndex},
            stateful_loop(State, NewCallbacks, NewIndex);
        {current, From} ->
            From ! {ok, State},
            stateful_loop(State, Callbacks, Index);
        {invoke, Value, From} ->
            spawn_invoke(Callbacks, Value),
            From ! {ok},
            stateful_loop(Value, Callbacks, Index);
        {remove, Id} ->
            NewCallbacks = maps:remove(Id, Callbacks),
            stateful_loop(State, NewCallbacks, Index);
        stop ->
            ok
    end.

%% Adds a callback to the stateful observer, returning the current state and index.
add_stateful(Process, Callback) ->
    Process ! {add, Callback, self()},
    receive
        {ok, State, Index} -> {State, Index}
    end.

%% Retrieves the current state.
current_state(Process) ->
    Process ! {current, self()},
    receive
        {ok, State} -> State
    end.

%% Invokes all callbacks in parallel with a new state, updating the state and waits for all callbacks to complete.
invoke_stateful(Process, Value) ->
    Process ! {invoke, Value, self()},
    receive
        {ok} -> ok
    end.

%% Removes a callback by its index.
remove_stateful(Process, Index) ->
    Process ! {remove, Index}.

%% Stops the stateful observer process.
stop_stateful(Process) ->
    Process ! stop.
