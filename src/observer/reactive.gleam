import observer

pub type State(value_type) =
  fn() -> value_type

pub opaque type Hub(value_type) {
  Hub(inner: observer.Hub(value_type), state: State(value_type))
}

pub fn new(
  with sate: State(value_type),
  in context: fn(Hub(value_type)) -> result,
) -> result {
  use inner <- observer.new()
  let hub = Hub(inner, sate)

  context(hub)
}

pub fn notify(on hub: Hub(value_type)) -> value_type {
  let value = hub.state()
  observer.notify(hub.inner, value)
  value
}

pub fn subscribe(
  on hub: Hub(value_type),
  with callback: observer.Callback(value_type),
) -> observer.Unsubscribe {
  observer.subscribe(hub.inner, callback)
}
