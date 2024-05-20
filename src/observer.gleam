import gleam/erlang/process
import gleam/int
import gleam/io

@external(erlang, "observer_ffi", "start")
fn start() -> Hub(value_type)

@external(erlang, "observer_ffi", "add")
fn add(hub: Hub(value_type), callback: Callback(value_type)) -> Int

@external(erlang, "observer_ffi", "invoke")
fn invoke(hub: Hub(value_type), value: value_type) -> Nil

@external(erlang, "observer_ffi", "remove")
fn remove(hub: Hub(value_type), index: Int) -> Nil

@external(erlang, "observer_ffi", "stop")
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

pub fn main() {
  use hub <- new()

  notify(hub, fn(value: Int) { "(1-" <> int.to_string(value) <> ")" })

  let unsubscribe_1 =
    subscribe(hub, fn(value) { io.println("u1 received: " <> value(1)) })

  notify(hub, fn(value: Int) { "(2-" <> int.to_string(value) <> ")" })

  let unsubscribe_2 =
    subscribe(hub, fn(value) { io.println("u2 received: " <> value(2)) })

  notify(hub, fn(value: Int) { "(3-" <> int.to_string(value) <> ")" })

  unsubscribe_1()

  notify(hub, fn(value: Int) { "(4-" <> int.to_string(value) <> ")" })

  unsubscribe_2()

  notify(hub, fn(value: Int) { "(5-" <> int.to_string(value) <> ")" })

  process.sleep(1000)

  io.println("done")
}
