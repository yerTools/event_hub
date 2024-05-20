/// Starts the stateless observer process.
@external(erlang, "observer_ffi", "start_stateless")
@external(javascript, "./observer_ffi.mjs", "startStateless")
fn start_stateless() -> Hub(value_type)

/// Adds a callback to the stateless observer, returning the index.
@external(erlang, "observer_ffi", "add_stateless")
@external(javascript, "./observer_ffi.mjs", "addStateless")
fn add_stateless(hub: Hub(value_type), callback: Callback(value_type)) -> Int

/// Invokes all callbacks in parallel with the given value and waits for all of them to complete.
@external(erlang, "observer_ffi", "invoke_stateless")
@external(javascript, "./observer_ffi.mjs", "invokeStateless")
fn invoke_stateless(hub: Hub(value_type), value: value_type) -> Nil

/// Removes a callback by its index.
@external(erlang, "observer_ffi", "remove_stateless")
@external(javascript, "./observer_ffi.mjs", "removeStateless")
fn remove_stateless(hub: Hub(value_type), index: Int) -> Nil

/// Stops the stateless observer process.
@external(erlang, "observer_ffi", "stop_stateless")
@external(javascript, "./observer_ffi.mjs", "stopStateless")
fn stop_stateless(hub: Hub(value_type)) -> Nil

pub type Hub(value_type)

pub type Callback(value_type) =
  fn(value_type) -> Nil

pub type Unsubscribe =
  fn() -> Nil

pub fn new(in context: fn(Hub(value_type)) -> result) -> result {
  let hub = start_stateless()

  let result = context(hub)
  stop_stateless(hub)

  result
}

pub fn notify(on hub: Hub(value_type), with value: value_type) -> Nil {
  invoke_stateless(hub, value)
}

pub fn subscribe(
  on hub: Hub(value_type),
  with callback: Callback(value_type),
) -> Unsubscribe {
  let index = add_stateless(hub, callback)
  fn() { remove_stateless(hub, index) }
}
