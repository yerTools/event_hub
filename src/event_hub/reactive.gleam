//// The `reactive` module provides a way to manage and notify subscribers about events based on a state that can be
//// dynamically retrieved. It supports creating observers that can react to changes in state, which can be useful for
//// broadcasting things that constantly change like the current time or database updates.
////
//// ## Examples
////
//// ### Reactive Observer
//// ```gleam
//// import gleam/io
//// import event_hub/reactive
//// 
//// pub fn main() {
////   let get_time = fn() { "2024-05-21T16:30:00Z" }
//// 
////   use hub <- reactive.new(get_time)
////   let unsubscribe =
////     reactive.subscribe(hub, fn(value) { io.println("Current time: " <> value) })
//// 
////   reactive.notify(hub)
//// 
////   unsubscribe()
////   reactive.notify(hub)
//// }
//// ```

import event_hub

/// Represents a function that returns the current state value.
pub type State(value_type) =
  fn() -> value_type

/// Represents a hub for managing event subscriptions and notifications based on dynamic state.
pub opaque type Hub(value_type) {
  Hub(inner: event_hub.Hub(value_type), state: State(value_type))
}

/// Creates a new reactive observer hub, executes the given context with the hub.
///
/// ## Parameters
/// - `state`: A function that returns the current state value.
/// - `context`: A function that takes the created `Hub` and returns a result.
///
/// ## Returns
/// The result of executing the context function.
///
/// ## Example
/// ```gleam
/// import event_hub/reactive
///
/// pub fn example() {
///   let get_state = fn() { "current state" }
///
///   reactive.new(get_state, fn(hub) {
///     // Use the hub
///     Nil
///   })
/// }
/// ```
pub fn new(
  with state: State(value_type),
  in context: fn(Hub(value_type)) -> result,
) -> result {
  use inner <- event_hub.new()
  let hub = Hub(inner, state)

  context(hub)
}

/// Notifies subscribers of the hub about an event with the current state value.
/// These notifications occur in parallel but `notify` waits for all of them to complete.
///
/// ## Parameters
/// - `hub`: The `Hub` to notify.
///
/// ## Returns
/// The current state value.
///
/// ## Example
/// ```gleam
/// import event_hub/reactive
///
/// pub fn example(hub: reactive.Hub(String)) {
///   let value = reactive.notify(hub)
/// }
/// ```
pub fn notify(on hub: Hub(value_type)) -> value_type {
  let value = hub.state()
  event_hub.notify(hub.inner, value)
  value
}

/// Subscribes to state changes and returns an unsubscribe function.
/// The callback will be invoked with the current state value when `notify` is called.
///
/// ## Parameters
/// - `hub`: The `Hub` to add the callback to.
/// - `callback`: The callback function to invoke with the current state value.
///
/// ## Returns
/// An `Unsubscribe` function that can be called to remove the callback.
///
/// ## Example
/// ```gleam
/// import gleam/io
/// import event_hub/reactive
/// 
/// pub fn example(hub: reactive.Hub(String)) {
///   let unsubscribe =
///     reactive.subscribe(hub, fn(value) {
///       io.println("Received state: " <> value)
///     })
/// 
///   // To unsubscribe
///   unsubscribe()
/// }
/// ```
pub fn subscribe(
  on hub: Hub(value_type),
  with callback: event_hub.Callback(value_type),
) -> event_hub.Unsubscribe {
  event_hub.subscribe(hub.inner, callback)
}
