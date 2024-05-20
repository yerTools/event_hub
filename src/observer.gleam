@external(erlang, "observer_ffi", "start")
@external(javascript, "./observer_ffi.mjs", "start")
fn start() -> Hub(value_type)

@external(erlang, "observer_ffi", "add")
@external(javascript, "./observer_ffi.mjs", "add")
fn add(hub: Hub(value_type), callback: Callback(value_type)) -> Int

@external(erlang, "observer_ffi", "invoke")
@external(javascript, "./observer_ffi.mjs", "invoke")
fn invoke(hub: Hub(value_type), value: value_type) -> Nil

@external(erlang, "observer_ffi", "remove")
@external(javascript, "./observer_ffi.mjs", "remove")
fn remove(hub: Hub(value_type), index: Int) -> Nil

@external(erlang, "observer_ffi", "stop")
@external(javascript, "./observer_ffi.mjs", "stop")
fn stop(hub: Hub(value_type)) -> Nil

pub type Hub(value_type)

pub type Callback(value_type) =
  fn(value_type) -> Nil

pub type Unsubscribe =
  fn() -> Nil

pub fn new(in context: fn(Hub(value_type)) -> result) -> result {
  let hub = start()

  let result = context(hub)
  stop(hub)

  result
}

pub fn notify(on hub: Hub(value_type), with value: value_type) -> Nil {
  invoke(hub, value)
}

pub fn subscribe(
  on hub: Hub(value_type),
  with callback: Callback(value_type),
) -> Unsubscribe {
  let index = add(hub, callback)
  fn() { remove(hub, index) }
}
