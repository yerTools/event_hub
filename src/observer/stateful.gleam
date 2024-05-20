import observer

@external(erlang, "observer_ffi", "start_stateful")
fn start_stateful(value: value_type) -> Hub(value_type)

@external(erlang, "observer_ffi", "add_stateful")
fn add_stateful(
  hub: Hub(value_type),
  callback: observer.Callback(value_type),
) -> #(value_type, Int)

@external(erlang, "observer_ffi", "current_state")
fn current_state(hub: Hub(value_type)) -> value_type

@external(erlang, "observer_ffi", "invoke_stateful")
fn invoke_stateful(hub: Hub(value_type), value: value_type) -> Nil

@external(erlang, "observer_ffi", "remove_stateful")
fn remove_stateful(hub: Hub(value_type), index: Int) -> Nil

@external(erlang, "observer_ffi", "stop_stateful")
fn stop_stateful(hub: Hub(value_type)) -> Nil

pub type Hub(value_type)

pub fn new(
  with value: value_type,
  in context: fn(Hub(value_type)) -> result,
) -> result {
  let hub = start_stateful(value)

  let result = context(hub)
  stop_stateful(hub)

  result
}

pub fn state(of hub: Hub(value_type)) -> value_type {
  current_state(hub)
}

pub fn notify(on hub: Hub(value_type), with value: value_type) -> Nil {
  invoke_stateful(hub, value)
}

pub fn subscribe(
  on hub: Hub(value_type),
  with callback: observer.Callback(value_type),
) -> #(value_type, observer.Unsubscribe) {
  let #(value, index) = add_stateful(hub, callback)

  let unsubscribe = fn() { remove_stateful(hub, index) }

  #(value, unsubscribe)
}
