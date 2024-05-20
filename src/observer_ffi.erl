-module(observer_ffi).
-export([
    invoke_callback/2,
    start/0,
    add/2,
    invoke/2,
    remove/2,
    stop/1,
    start_stateful/1,
    add_stateful/2,
    current_state/1,
    invoke_stateful/2,
    remove_stateful/2,
    stop_stateful/1
]).

%% Helper functions

spawn_invoke(Callbacks, Value) ->
    lists:foreach(
        fun({_, Callback}) ->
            invoke(Callback, Value)
        end,
        maps:to_list(Callbacks)
    ).

invoke_callback(Callback, Value) ->
    spawn(fun() -> Callback(Value) end).

%% Stateless observer

start() ->
    spawn(fun() -> loop(#{}, 0) end).

loop(Callbacks, Index) ->
    receive
        {add, Callback, From} ->
            NewIndex = Index + 1,
            NewCallbacks = Callbacks#{Index => Callback},
            From ! {ok, Index},
            loop(NewCallbacks, NewIndex);
        {invoke, Value} ->
            spawn_invoke(Callbacks, Value),
            loop(Callbacks, Index);
        {remove, Id} ->
            NewCallbacks = maps:remove(Id, Callbacks),
            loop(NewCallbacks, Index);
        stop ->
            ok
    end.

add(Process, Callback) ->
    Process ! {add, Callback, self()},
    receive
        {ok, Index} -> Index
    end.

invoke(Process, Value) ->
    Process ! {invoke, Value}.

remove(Process, Index) ->
    Process ! {remove, Index}.

stop(Process) ->
    Process ! stop.

%% Stateful observer

start_stateful(State) ->
    spawn(fun() -> loop_stateful(State, #{}, 0) end).

loop_stateful(State, Callbacks, Index) ->
    receive
        {add, Callback, From} ->
            NewIndex = Index + 1,
            NewCallbacks = Callbacks#{Index => Callback},
            From ! {ok, State, Index},
            loop_stateful(State, NewCallbacks, NewIndex);
        {current, From} ->
            From ! {ok, State},
            loop_stateful(State, Callbacks, Index);
        {invoke, Value} ->
            spawn_invoke(Callbacks, Value),
            loop_stateful(Value, Callbacks, Index);
        {remove, Id} ->
            NewCallbacks = maps:remove(Id, Callbacks),
            loop(NewCallbacks, Index);
        stop ->
            ok
    end.

add_stateful(Process, Callback) ->
    Process ! {add, Callback, self()},
    receive
        {ok, State, Index} -> {State, Index}
    end.

current_state(Process) ->
    Process ! {current, self()},
    receive
        {ok, State} -> State
    end.

invoke_stateful(Process, Value) ->
    Process ! {invoke, Value}.

remove_stateful(Process, Index) ->
    Process ! {remove, Index}.

stop_stateful(Process) ->
    Process ! stop.
