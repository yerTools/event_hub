import observer

/// Starts the topic-based observer process.
@external(erlang, "observer_ffi", "start_topic_based")
@external(javascript, "../observer_ffi.mjs", "startTopicBased")
fn start_topic_based() -> HubN(value_type)

/// Adds a callback with topics to the topic-based observer, returning the index.
@external(erlang, "observer_ffi", "add_topic_based")
@external(javascript, "../observer_ffi.mjs", "addTopicBased")
fn add_topic_based(
  hub: HubN(value_type),
  topics: List(List(String)),
  callback: observer.Callback(value_type),
) -> Int

/// Invokes all matching callbacks in parallel with the given topics and value, and waits for all of them to complete.
@external(erlang, "observer_ffi", "invoke_topic_based")
@external(javascript, "../observer_ffi.mjs", "invokeTopicBased")
fn invoke_topic_based(
  hub: HubN(value_type),
  topics: List(List(String)),
  value: value_type,
) -> Nil

/// Removes a callback by its index.
@external(erlang, "observer_ffi", "remove_topic_based")
@external(javascript, "../observer_ffi.mjs", "removeTopicBased")
fn remove_topic_based(hub: HubN(value_type), index: Int) -> Nil

/// Stops the topic-based observer process.
@external(erlang, "observer_ffi", "stop_topic_based")
@external(javascript, "../observer_ffi.mjs", "stopTopicBased")
fn stop_topic_based(hub: HubN(value_type)) -> Nil

pub type HubN(value_type)

pub fn new_n(in context: fn(HubN(value_type)) -> result) -> result {
  let hub = start_topic_based()

  let result = context(hub)
  stop_topic_based(hub)

  result
}

pub fn notify_n(
  on hub: HubN(value_type),
  with topics: List(List(String)),
  and value: value_type,
) -> Nil {
  invoke_topic_based(hub, topics, value)
}

pub fn subscribe_n(
  on hub: HubN(value_type),
  with topics: List(List(String)),
  and callback: observer.Callback(value_type),
) -> observer.Unsubscribe {
  let index = add_topic_based(hub, topics, callback)
  fn() { remove_topic_based(hub, index) }
}

pub opaque type Hub(value_type) {
  Hub(hub: HubN(value_type))
}

pub fn new(in context: fn(Hub(value_type)) -> result) -> result {
  use hub <- new_n()
  context(Hub(hub))
}

pub fn notify(
  on hub: Hub(value_type),
  with topics: List(String),
  and value: value_type,
) -> Nil {
  notify_n(hub.hub, [topics], value)
}

pub fn subscribe(
  on hub: Hub(value_type),
  with topics: List(String),
  and callback: observer.Callback(value_type),
) -> observer.Unsubscribe {
  subscribe_n(hub.hub, [topics], callback)
}

pub opaque type Hub2(value_type) {
  Hub2(hub: HubN(value_type))
}

pub fn new2(in context: fn(Hub2(value_type)) -> result) -> result {
  use hub <- new_n()
  context(Hub2(hub))
}

pub fn notify2(
  hub: Hub2(value_type),
  topics1: List(String),
  topics2: List(String),
  value: value_type,
) -> Nil {
  notify_n(hub.hub, [topics1, topics2], value)
}

pub fn subscribe2(
  hub: Hub2(value_type),
  topics1: List(String),
  topics2: List(String),
  callback: observer.Callback(value_type),
) -> observer.Unsubscribe {
  subscribe_n(hub.hub, [topics1, topics2], callback)
}

pub opaque type Hub3(value_type) {
  Hub3(hub: HubN(value_type))
}

pub fn new3(in context: fn(Hub3(value_type)) -> result) -> result {
  use hub <- new_n()
  context(Hub3(hub))
}

pub fn notify3(
  hub: Hub3(value_type),
  topics1: List(String),
  topics2: List(String),
  topics3: List(String),
  value: value_type,
) -> Nil {
  notify_n(hub.hub, [topics1, topics2, topics3], value)
}

pub fn subscribe3(
  hub: Hub3(value_type),
  topics1: List(String),
  topics2: List(String),
  topics3: List(String),
  callback: observer.Callback(value_type),
) -> observer.Unsubscribe {
  subscribe_n(hub.hub, [topics1, topics2, topics3], callback)
}

pub opaque type Hub4(value_type) {
  Hub4(hub: HubN(value_type))
}

pub fn new4(in context: fn(Hub4(value_type)) -> result) -> result {
  use hub <- new_n()
  context(Hub4(hub))
}

pub fn notify4(
  hub: Hub4(value_type),
  topics1: List(String),
  topics2: List(String),
  topics3: List(String),
  topics4: List(String),
  value: value_type,
) -> Nil {
  notify_n(hub.hub, [topics1, topics2, topics3, topics4], value)
}

pub fn subscribe4(
  hub: Hub4(value_type),
  topics1: List(String),
  topics2: List(String),
  topics3: List(String),
  topics4: List(String),
  callback: observer.Callback(value_type),
) -> observer.Unsubscribe {
  subscribe_n(hub.hub, [topics1, topics2, topics3, topics4], callback)
}
