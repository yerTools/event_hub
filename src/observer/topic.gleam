//// The `topic` module provides a way to manage and notify subscribers about events based on hierarchical topics.
//// It supports creating observers that can filter events using one or more levels of topics, allowing more fine-grained
//// control over event handling.
////
//// ## Examples
////
//// ### Single-Level Topic-Based Observer
//// ```gleam
//// import gleam/io
//// import observer/topic
//// 
//// pub fn main() {
////   use hub <- topic.new()
////   let unsubscribe_a =
////     topic.subscribe(hub, ["a"], fn(value) {
////       io.println("A received: " <> value)
////     })
//// 
////   let unsubscribe_b =
////     topic.subscribe(hub, ["b"], fn(value) {
////       io.println("B received: " <> value)
////     })
//// 
////   topic.notify(hub, ["a"], "Message for A")
////   topic.notify(hub, ["b"], "Message for B")
//// 
////   unsubscribe_a()
////   unsubscribe_b()
//// }
//// ```

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

/// Represents a hub for managing event subscriptions and notifications based on hierarchical topics.
pub type HubN(value_type)

/// Creates a new topic-based observer hub, executes the given context with the hub, and stops the hub afterward.
///
/// ## Parameters
/// - `context`: A function that takes the created `HubN` and returns a result.
///
/// ## Returns
/// The result of executing the context function.
///
/// ## Example
/// ```gleam
/// import observer/topic
///
/// pub fn example() {
///   topic.new(fn(hub) {
///     // Use the hub
///     Nil
///   })
/// }
/// ```
pub fn new_n(in context: fn(HubN(value_type)) -> result) -> result {
  let hub = start_topic_based()

  let result = context(hub)
  stop_topic_based(hub)

  result
}

/// Notifies subscribers of the hub about an event with the given topics and value.
/// These notifications occur in parallel but `notify_n` waits for all of them to complete.
///
/// ## Parameters
/// - `hub`: The `HubN` to notify.
/// - `topics`: The list of topics associated with the event.
/// - `value`: The value to send to all subscribers.
///
/// ## Example
/// ```gleam
/// import observer/topic
///
/// pub fn example(hub: topic.HubN(String)) {
///   topic.notify_n(hub, [["topic1"]], "event")
/// }
/// ```
pub fn notify_n(
  on hub: HubN(value_type),
  with topics: List(List(String)),
  and value: value_type,
) -> Nil {
  invoke_topic_based(hub, topics, value)
}

/// Subscribes to specific topics and returns an unsubscribe function.
/// The callback will be invoked only if the event topics match the subscription topics.
///
/// ## Parameters
/// - `hub`: The `HubN` to add the callback to.
/// - `topics`: The list of topics to subscribe to.
/// - `callback`: The callback function to invoke when an event with matching topics occurs.
///
/// ## Returns
/// An `Unsubscribe` function that can be called to remove the callback.
///
/// ## Example
/// ```gleam
/// import gleam/io
/// import observer/topic
/// 
/// pub fn example(hub: topic.HubN(String)) {
///   let unsubscribe =
///     topic.subscribe_n(hub, [["topic1"]], fn(value) {
///       io.println("Received value: " <> value)
///     })
/// 
///   // To unsubscribe
///   unsubscribe()
/// }
/// ```
pub fn subscribe_n(
  on hub: HubN(value_type),
  with topics: List(List(String)),
  and callback: observer.Callback(value_type),
) -> observer.Unsubscribe {
  let index = add_topic_based(hub, topics, callback)
  fn() { remove_topic_based(hub, index) }
}

/// Represents a hub for managing event subscriptions and notifications based on a single level of topics.
pub opaque type Hub(value_type) {
  Hub(hub: HubN(value_type))
}

/// Creates a new single-level topic-based observer hub, executes the given context with the hub.
///
/// ## Parameters
/// - `context`: A function that takes the created `Hub` and returns a result.
///
/// ## Returns
/// The result of executing the context function.
///
/// ## Example
/// ```gleam
/// import observer/topic
///
/// pub fn example() {
///   topic.new(fn(hub) {
///     // Use the hub
///     Nil
///   })
/// }
/// ```
pub fn new(in context: fn(Hub(value_type)) -> result) -> result {
  use hub <- new_n()
  context(Hub(hub))
}

/// Notifies subscribers of the hub about an event with the given single-level topics and value.
///
/// ## Parameters
/// - `hub`: The `Hub` to notify.
/// - `topics`: The list of topics associated with the event.
/// - `value`: The value to send to all subscribers.
///
/// ## Example
/// ```gleam
/// import observer/topic
///
/// pub fn example(hub: topic.Hub(String)) {
///   topic.notify(hub, ["topic1"], "event")
/// }
/// ```
pub fn notify(
  on hub: Hub(value_type),
  with topics: List(String),
  and value: value_type,
) -> Nil {
  notify_n(hub.hub, [topics], value)
}

/// Subscribes to specific single-level topics and returns an unsubscribe function.
///
/// ## Parameters
/// - `hub`: The `Hub` to add the callback to.
/// - `topics`: The list of topics to subscribe to.
/// - `callback`: The callback function to invoke when an event with matching topics occurs.
///
/// ## Returns
/// An `Unsubscribe` function that can be called to remove the callback.
///
/// ## Example
/// ```gleam
/// import gleam/io
/// import observer/topic
/// 
/// pub fn example(hub: topic.Hub(String)) {
///   let unsubscribe =
///     topic.subscribe(hub, ["topic1"], fn(value) {
///       io.println("Received value: " <> value)
///     })
/// 
///   // To unsubscribe
///   unsubscribe()
/// }
/// ```
pub fn subscribe(
  on hub: Hub(value_type),
  with topics: List(String),
  and callback: observer.Callback(value_type),
) -> observer.Unsubscribe {
  subscribe_n(hub.hub, [topics], callback)
}

/// Represents a hub for managing event subscriptions and notifications based on two levels of topics.
pub opaque type Hub2(value_type) {
  Hub2(hub: HubN(value_type))
}

/// Creates a new two-level topic-based observer hub, executes the given context with the hub.
///
/// ## Parameters
/// - `context`: A function that takes the created `Hub2` and returns a result.
///
/// ## Returns
/// The result of executing the context function.
///
/// ## Example
/// ```gleam
/// import observer/topic
///
/// pub fn example() {
///   topic.new2(fn(hub) {
///     // Use the hub
///     Nil
///   })
/// }
/// ```
pub fn new2(in context: fn(Hub2(value_type)) -> result) -> result {
  use hub <- new_n()
  context(Hub2(hub))
}

/// Notifies subscribers of the hub about an event with two levels of topics and a value.
///
/// ## Parameters
/// - `hub`: The `Hub2` to notify.
/// - `topics1`: The first level of topics associated with the event.
/// - `topics2`: The second level of topics associated with the event.
/// - `value`: The value to send to all subscribers.
///
/// ## Example
/// ```gleam
/// import observer/topic
///
/// pub fn example(hub: topic.Hub2(String)) {
///   topic.notify2(hub, ["topic1"], ["subtopic1"], "event")
/// }
/// ```
pub fn notify2(
  hub: Hub2(value_type),
  topics1: List(String),
  topics2: List(String),
  value: value_type,
) -> Nil {
  notify_n(hub.hub, [topics1, topics2], value)
}

/// Subscribes to specific two-level topics and returns an unsubscribe function.
///
/// ## Parameters
/// - `hub`: The `Hub2` to add the callback to.
/// - `topics1`: The first level of topics to subscribe to.
/// - `topics2`: The second level of topics to subscribe to.
/// - `callback`: The callback function to invoke when an event with matching topics occurs.
///
/// ## Returns
/// An `Unsubscribe` function that can be called to remove the callback.
///
/// ## Example
/// ```gleam
/// import observer/topic
/// import gleam/io
/// 
/// pub fn example(hub: topic.Hub2(String)) {
///   let unsubscribe =
///     topic.subscribe2(hub, ["topic1"], ["subtopic1"], fn(value) {
///       io.println("Received value: " <> value)
///     })
/// 
///   // To unsubscribe
///   unsubscribe()
/// }
/// ```
pub fn subscribe2(
  hub: Hub2(value_type),
  topics1: List(String),
  topics2: List(String),
  callback: observer.Callback(value_type),
) -> observer.Unsubscribe {
  subscribe_n(hub.hub, [topics1, topics2], callback)
}

/// Represents a hub for managing event subscriptions and notifications based on three levels of topics.
pub opaque type Hub3(value_type) {
  Hub3(hub: HubN(value_type))
}

/// Creates a new three-level topic-based observer hub, executes the given context with the hub.
///
/// ## Parameters
/// - `context`: A function that takes the created `Hub3` and returns a result.
///
/// ## Returns
/// The result of executing the context function.
///
/// ## Example
/// ```gleam
/// import observer/topic
///
/// pub fn example() {
///   topic.new3(fn(hub) {
///     // Use the hub
///     Nil
///   })
/// }
/// ```
pub fn new3(in context: fn(Hub3(value_type)) -> result) -> result {
  use hub <- new_n()
  context(Hub3(hub))
}

/// Notifies subscribers of the hub about an event with three levels of topics and a value.
///
/// ## Parameters
/// - `hub`: The `Hub3` to notify.
/// - `topics1`: The first level of topics associated with the event.
/// - `topics2`: The second level of topics associated with the event.
/// - `topics3`: The third level of topics associated with the event.
/// - `value`: The value to send to all subscribers.
///
/// ## Example
/// ```gleam
/// import observer/topic
///
/// pub fn example(hub: topic.Hub3(String)) {
///   topic.notify3(hub, ["topic1"], ["subtopic1"], ["subsubtopic1"], "event")
/// }
/// ```
pub fn notify3(
  hub: Hub3(value_type),
  topics1: List(String),
  topics2: List(String),
  topics3: List(String),
  value: value_type,
) -> Nil {
  notify_n(hub.hub, [topics1, topics2, topics3], value)
}

/// Subscribes to specific three-level topics and returns an unsubscribe function.
///
/// ## Parameters
/// - `hub`: The `Hub3` to add the callback to.
/// - `topics1`: The first level of topics to subscribe to.
/// - `topics2`: The second level of topics to subscribe to.
/// - `topics3`: The third level of topics to subscribe to.
/// - `callback`: The callback function to invoke when an event with matching topics occurs.
///
/// ## Returns
/// An `Unsubscribe` function that can be called to remove the callback.
///
/// ## Example
/// ```gleam
/// import gleam/io
/// import observer/topic
/// 
/// pub fn example(hub: topic.Hub3(String)) {
///   let unsubscribe =
///     topic.subscribe3(
///       hub,
///       ["topic1"],
///       ["subtopic1"],
///       ["subsubtopic1"],
///       fn(value) { io.println("Received value: " <> value) },
///     )
/// 
///   // To unsubscribe
///   unsubscribe()
/// }
/// ```
pub fn subscribe3(
  hub: Hub3(value_type),
  topics1: List(String),
  topics2: List(String),
  topics3: List(String),
  callback: observer.Callback(value_type),
) -> observer.Unsubscribe {
  subscribe_n(hub.hub, [topics1, topics2, topics3], callback)
}

/// Represents a hub for managing event subscriptions and notifications based on four levels of topics.
pub opaque type Hub4(value_type) {
  Hub4(hub: HubN(value_type))
}

/// Creates a new four-level topic-based observer hub, executes the given context with the hub.
///
/// ## Parameters
/// - `context`: A function that takes the created `Hub4` and returns a result.
///
/// ## Returns
/// The result of executing the context function.
///
/// ## Example
/// ```gleam
/// import observer/topic
///
/// pub fn example() {
///   topic.new4(fn(hub) {
///     // Use the hub
///     Nil
///   })
/// }
/// ```
pub fn new4(in context: fn(Hub4(value_type)) -> result) -> result {
  use hub <- new_n()
  context(Hub4(hub))
}

/// Notifies subscribers of the hub about an event with four levels of topics and a value.
///
/// ## Parameters
/// - `hub`: The `Hub4` to notify.
/// - `topics1`: The first level of topics associated with the event.
/// - `topics2`: The second level of topics associated with the event.
/// - `topics3`: The third level of topics associated with the event.
/// - `topics4`: The fourth level of topics associated with the event.
/// - `value`: The value to send to all subscribers.
///
/// ## Example
/// ```gleam
/// import observer/topic
/// 
/// pub fn example(hub: topic.Hub4(String)) {
///   topic.notify4(
///     hub,
///     ["topic1"],
///     ["subtopic1"],
///     ["subsubtopic1"],
///     ["subsubsubtopic1"],
///     "event",
///   )
/// }
/// ```
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

/// Subscribes to specific four-level topics and returns an unsubscribe function.
///
/// ## Parameters
/// - `hub`: The `Hub4` to add the callback to.
/// - `topics1`: The first level of topics to subscribe to.
/// - `topics2`: The second level of topics to subscribe to.
/// - `topics3`: The third level of topics to subscribe to.
/// - `topics4`: The fourth level of topics to subscribe to.
/// - `callback`: The callback function to invoke when an event with matching topics occurs.
///
/// ## Returns
/// An `Unsubscribe` function that can be called to remove the callback.
///
/// ## Example
/// ```gleam
/// import gleam/io
/// import observer/topic
/// 
/// pub fn example(hub: topic.Hub4(String)) {
///   let unsubscribe =
///     topic.subscribe4(
///       hub,
///       ["topic1"],
///       ["subtopic1"],
///       ["subsubtopic1"],
///       ["subsubsubtopic1"],
///       fn(value) { io.println("Received value: " <> value) },
///     )
/// 
///   // To unsubscribe
///   unsubscribe()
/// }
/// ```
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
