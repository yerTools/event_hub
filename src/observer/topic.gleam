import observer

/// Starts the topic-based observer process.
@external(erlang, "observer_ffi", "start_topic_based")
@external(javascript, "../observer_ffi.mjs", "startTopicBased")
fn start_topic_based() -> Hub(value_type)

/// Adds a callback with topics to the topic-based observer, returning the index.
@external(erlang, "observer_ffi", "add_topic_based")
@external(javascript, "../observer_ffi.mjs", "addTopicBased")
fn add_topic_based(
  hub: Hub(value_type),
  topics: List(String),
  callback: observer.Callback(value_type),
) -> Int

/// Invokes all matching callbacks in parallel with the given topics and value, and waits for all of them to complete.
@external(erlang, "observer_ffi", "invoke_topic_based")
@external(javascript, "../observer_ffi.mjs", "invokeTopicBased")
fn invoke_topic_based(
  hub: Hub(value_type),
  topics: List(String),
  value: value_type,
) -> Nil

/// Removes a callback by its index.
@external(erlang, "observer_ffi", "remove_topic_based")
@external(javascript, "../observer_ffi.mjs", "removeTopicBased")
fn remove_topic_based(hub: Hub(value_type), index: Int) -> Nil

/// Stops the topic-based observer process.
@external(erlang, "observer_ffi", "stop_topic_based")
@external(javascript, "../observer_ffi.mjs", "stopTopicBased")
fn stop_topic_based(hub: Hub(value_type)) -> Nil

pub type Hub(value_type)

pub fn new(in context: fn(Hub(value_type)) -> result) -> result {
  let hub = start_topic_based()

  let result = context(hub)
  stop_topic_based(hub)

  result
}

pub fn notify(
  on hub: Hub(value_type),
  with topics: List(String),
  and value: value_type,
) -> Nil {
  invoke_topic_based(hub, topics, value)
}

pub fn subscribe(
  on hub: Hub(value_type),
  with topics: List(String),
  and callback: observer.Callback(value_type),
) -> observer.Unsubscribe {
  let index = add_topic_based(hub, topics, callback)
  fn() { remove_topic_based(hub, index) }
}
