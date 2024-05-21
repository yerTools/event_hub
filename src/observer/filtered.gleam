//// The `filtered` module provides a way to manage and notify subscribers about events based on specific topics.
//// It supports creating observers that can filter events using topics, allowing more fine-grained control over event handling.
//// If you only want to use topics of the type `String`, you should use the `observer/topic` module instead.
//// 
//// ## Examples
////
//// ### Filtered Observer
//// ```gleam
//// import gleam/io
//// import observer/filtered
//// 
//// pub fn main() {
////   use hub <- filtered.new()
//// 
////   let unsubscribe_a =
////     filtered.subscribe(hub, [Ok("topic1")], fn(value) {
////       io.println("A received: " <> value)
////     })
//// 
////   let unsubscribe_b =
////     filtered.subscribe(hub, [Error("topic2")], fn(value) {
////       io.println("B received: " <> value)
////     })
//// 
////   filtered.notify(hub, [Ok("topic1")], "Message for topic1")
////   filtered.notify(hub, [Error("topic2")], "Message for topic2")
//// 
////   unsubscribe_a()
////   unsubscribe_b()
//// }
//// ```

import gleam/list
import gleam/set
import observer

type TopicValuePair(value_type, topic_type) =
  #(List(topic_type), value_type)

/// Represents a hub for managing event subscriptions and notifications based on topics.
pub opaque type Hub(value_type, topic_type) {
  Hub(hub: observer.Hub(TopicValuePair(value_type, topic_type)))
}

/// Creates a new filtered observer hub, executes the given context with the hub.
/// If you only want to use topics of the type `String`, you should use the `observer/topic` module instead.
///
/// ## Parameters
/// - `context`: A function that takes the created `Hub` and returns a result.
///
/// ## Returns
/// The result of executing the context function.
///
/// ## Example
/// ```gleam
/// import observer/filtered
///
/// pub fn example() {
///   filtered.new(fn(hub) {
///     // Use the hub
///     Nil
///   })
/// }
/// ```
pub fn new(in context: fn(Hub(value_type, topic_type)) -> result) -> result {
  use hub <- observer.new()
  let hub = Hub(hub)

  context(hub)
}

/// Notifies subscribers of the hub about an event with the given topics and value.
/// These notifications occur in parallel but `notify` waits for all of them to complete.
///
/// ## Parameters
/// - `hub`: The `Hub` to notify.
/// - `topics`: The list of topics associated with the event.
/// - `value`: The value to send to all subscribers.
///
/// ## Example
/// ```gleam
/// import observer/filtered
///
/// pub fn example(hub: filtered.Hub(String, String)) {
///   filtered.notify(hub, ["topic1"], "event")
/// }
/// ```
pub fn notify(
  on hub: Hub(value_type, topic_type),
  with topics: List(topic_type),
  and value: value_type,
) -> Nil {
  observer.notify(hub.hub, #(topics, value))
}

/// Subscribes to specific topics and returns an unsubscribe function.
/// The callback will be invoked only if the event topics match the subscription topics.
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
/// import observer/filtered
/// 
/// pub fn example(hub: filtered.Hub(String, String)) {
///   let unsubscribe =
///     filtered.subscribe(hub, ["topic1"], fn(value) {
///       io.println("Received value: " <> value)
///     })
/// 
///   // To unsubscribe
///   unsubscribe()
/// }
/// ```
pub fn subscribe(
  on hub: Hub(value_type, topic_type),
  with topics: List(topic_type),
  and callback: observer.Callback(value_type),
) -> observer.Unsubscribe {
  let topics = set.from_list(topics)

  use #(event_topics, event_value) <- observer.subscribe(hub.hub)

  case list.any(event_topics, fn(topic) { set.contains(topics, topic) }) {
    True -> callback(event_value)
    False -> Nil
  }
}

/// Represents a hub for managing event subscriptions and notifications based on two levels of topics.
pub opaque type Hub2(value_type, topic_type1, topic_type2) {
  Hub2(hub: Hub(TopicValuePair(value_type, topic_type2), topic_type1))
}

/// Creates a new filtered observer hub with two levels of topics.
/// If you only want to use topics of the type `String`, you should use the `observer/topic` module instead.
///
/// ## Parameters
/// - `context`: A function that takes the created `Hub2` and returns a result.
///
/// ## Returns
/// The result of executing the context function.
///
/// ## Example
/// ```gleam
/// import observer/filtered
///
/// pub fn example() {
///   filtered.new2(fn(hub) {
///     // Use the hub
///     Nil
///   })
/// }
/// ```
pub fn new2(
  in context: fn(Hub2(value_type, topic_type1, topic_type2)) -> result,
) -> result {
  use hub <- new()
  let hub = Hub2(hub)

  context(hub)
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
/// import observer/filtered
/// 
/// pub fn example(hub: filtered.Hub2(String, String, String)) {
///   filtered.notify2(hub, ["topic1"], ["subtopic1"], "event")
/// }
/// ```
pub fn notify2(
  hub: Hub2(value_type, topic_type1, topic_type2),
  topics1: List(topic_type1),
  topics2: List(topic_type2),
  value: value_type,
) -> Nil {
  notify(hub.hub, topics1, #(topics2, value))
}

/// Subscribes to specific topics in a two-level hierarchy and returns an unsubscribe function.
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
/// import gleam/io
/// import observer/filtered
/// 
/// pub fn example(hub: filtered.Hub2(String, String, String)) {
///   let unsubscribe =
///     filtered.subscribe2(hub, ["topic1"], ["subtopic1"], fn(value) {
///       io.println("Received value: " <> value)
///     })
/// 
///   // To unsubscribe
///   unsubscribe()
/// }
/// ```
pub fn subscribe2(
  hub: Hub2(value_type, topic_type1, topic_type2),
  topics1: List(topic_type1),
  topics2: List(topic_type2),
  callback: observer.Callback(value_type),
) -> observer.Unsubscribe {
  let topics = set.from_list(topics2)

  use #(event_topics, event_value) <- subscribe(hub.hub, topics1)

  case list.any(event_topics, fn(topic) { set.contains(topics, topic) }) {
    True -> callback(event_value)
    False -> Nil
  }
}

/// Represents a hub for managing event subscriptions and notifications based on three levels of topics.
pub opaque type Hub3(value_type, topic_type1, topic_type2, topic_type3) {
  Hub3(
    hub: Hub2(TopicValuePair(value_type, topic_type3), topic_type1, topic_type2),
  )
}

/// Creates a new filtered observer hub with three levels of topics.
/// If you only want to use topics of the type `String`, you should use the `observer/topic` module instead.
///
/// ## Parameters
/// - `context`: A function that takes the created `Hub3` and returns a result.
///
/// ## Returns
/// The result of executing the context function.
///
/// ## Example
/// ```gleam
/// import observer/filtered
///
/// pub fn example() {
///   filtered.new3(fn(hub) {
///     // Use the hub
///     Nil
///   })
/// }
/// ```
pub fn new3(
  in context: fn(Hub3(value_type, topic_type1, topic_type2, topic_type3)) ->
    result,
) -> result {
  use hub <- new2()
  let hub = Hub3(hub)

  context(hub)
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
/// import observer/filtered
///
/// pub fn example(hub: filtered.Hub3(String, String, String, String)) {
///   filtered.notify3(hub, ["topic1"], ["subtopic1"], ["subsubtopic1"], "event")
/// }
/// ```
pub fn notify3(
  hub: Hub3(value_type, topic_type1, topic_type2, topic_type3),
  topics1: List(topic_type1),
  topics2: List(topic_type2),
  topics3: List(topic_type3),
  value: value_type,
) -> Nil {
  notify2(hub.hub, topics1, topics2, #(topics3, value))
}

/// Subscribes to specific topics in a three-level hierarchy and returns an unsubscribe function.
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
/// import observer/filtered
/// 
/// pub fn example(hub: filtered.Hub3(String, String, String, String)) {
///   let unsubscribe =
///     filtered.subscribe3(
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
  hub: Hub3(value_type, topic_type1, topic_type2, topic_type3),
  topics1: List(topic_type1),
  topics2: List(topic_type2),
  topics3: List(topic_type3),
  callback: observer.Callback(value_type),
) -> observer.Unsubscribe {
  let topics = set.from_list(topics3)

  use #(event_topics, event_value) <- subscribe2(hub.hub, topics1, topics2)

  case list.any(event_topics, fn(topic) { set.contains(topics, topic) }) {
    True -> callback(event_value)
    False -> Nil
  }
}

/// Represents a hub for managing event subscriptions and notifications based on four levels of topics.
pub opaque type Hub4(
  value_type,
  topic_type1,
  topic_type2,
  topic_type3,
  topic_type4,
) {
  Hub4(
    hub: Hub3(
      TopicValuePair(value_type, topic_type4),
      topic_type1,
      topic_type2,
      topic_type3,
    ),
  )
}

/// Creates a new filtered observer hub with four levels of topics.
/// If you only want to use topics of the type `String`, you should use the `observer/topic` module instead.
///
/// ## Parameters
/// - `context`: A function that takes the created `Hub4` and returns a result.
///
/// ## Returns
/// The result of executing the context function.
///
/// ## Example
/// ```gleam
/// import observer/filtered
///
/// pub fn example() {
///   filtered.new4(fn(hub) {
///     // Use the hub
///     Nil
///   })
/// }
/// ```
pub fn new4(
  in context: fn(
    Hub4(value_type, topic_type1, topic_type2, topic_type3, topic_type4),
  ) ->
    result,
) -> result {
  use hub <- new3()
  let hub = Hub4(hub)

  context(hub)
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
/// import observer/filtered
/// 
/// pub fn example(hub: filtered.Hub4(String, String, String, String, String)) {
///   filtered.notify4(
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
  hub: Hub4(value_type, topic_type1, topic_type2, topic_type3, topic_type4),
  topics1: List(topic_type1),
  topics2: List(topic_type2),
  topics3: List(topic_type3),
  topics4: List(topic_type4),
  value: value_type,
) -> Nil {
  notify3(hub.hub, topics1, topics2, topics3, #(topics4, value))
}

/// Subscribes to specific topics in a four-level hierarchy and returns an unsubscribe function.
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
/// import observer/filtered
/// 
/// pub fn example(hub: filtered.Hub4(String, String, String, String, String)) {
///   let unsubscribe =
///     filtered.subscribe4(
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
  hub: Hub4(value_type, topic_type1, topic_type2, topic_type3, topic_type4),
  topics1: List(topic_type1),
  topics2: List(topic_type2),
  topics3: List(topic_type3),
  topics4: List(topic_type4),
  callback: observer.Callback(value_type),
) -> observer.Unsubscribe {
  let topics = set.from_list(topics4)

  use #(event_topics, event_value) <- subscribe3(
    hub.hub,
    topics1,
    topics2,
    topics3,
  )

  case list.any(event_topics, fn(topic) { set.contains(topics, topic) }) {
    True -> callback(event_value)
    False -> Nil
  }
}
