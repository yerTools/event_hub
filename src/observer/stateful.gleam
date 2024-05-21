//// The `stateful` module provides a way to manage and notify subscribers about events based on a mutable state.
//// It supports creating observers that can maintain and update state, which can be useful for handling stateful events
//// in an application.
////
//// ## Examples
////
//// ### Stateful Observer
//// ```gleam
//// import gleam/io
//// import observer/stateful
//// 
//// pub fn main() {
////   use hub <- stateful.new("initial state")
////   let #(current_state, unsubscribe) =
////     stateful.subscribe(hub, True, fn(value) {
////       io.println("Received initial state: " <> value)
////     })
//// 
////   io.println("Current state: " <> current_state)
//// 
////   stateful.notify(hub, "new state")
//// 
////   unsubscribe()
////   stateful.notify(hub, "final state")
//// }
//// ```

import observer

/// Starts the stateful observer process with an initial state.
@external(erlang, "observer_ffi", "start_stateful")
@external(javascript, "../observer_ffi.mjs", "startStateful")
fn start_stateful(value: value_type) -> Hub(value_type)

/// Adds a callback to the stateful observer, returning the current state and index.
@external(erlang, "observer_ffi", "add_stateful")
@external(javascript, "../observer_ffi.mjs", "addStateful")
fn add_stateful(
  hub: Hub(value_type),
  callback: observer.Callback(value_type),
) -> #(value_type, Int)

/// Retrieves the current state.
@external(erlang, "observer_ffi", "current_state")
@external(javascript, "../observer_ffi.mjs", "currentState")
fn current_state(hub: Hub(value_type)) -> value_type

/// Invokes all callbacks in parallel with a new state, updating the state and waits for all callbacks to complete.
@external(erlang, "observer_ffi", "invoke_stateful")
@external(javascript, "../observer_ffi.mjs", "invokeStateful")
fn invoke_stateful(hub: Hub(value_type), value: value_type) -> Nil

/// Removes a callback by its index.
@external(erlang, "observer_ffi", "remove_stateful")
@external(javascript, "../observer_ffi.mjs", "removeStateful")
fn remove_stateful(hub: Hub(value_type), index: Int) -> Nil

/// Stops the stateful observer process.
@external(erlang, "observer_ffi", "stop_stateful")
@external(javascript, "../observer_ffi.mjs", "stopStateful")
fn stop_stateful(hub: Hub(value_type)) -> Nil

/// Represents a hub for managing event subscriptions and notifications with a mutable state.
pub type Hub(value_type)

/// Creates a new stateful observer hub with an initial state, executes the given context with the hub, and stops the hub afterward.
///
/// ## Parameters
/// - `value`: The initial state value.
/// - `context`: A function that takes the created `Hub` and returns a result.
///
/// ## Returns
/// The result of executing the context function.
///
/// ## Example
/// ```gleam
/// import observer/stateful
///
/// pub fn example() {
///   stateful.new("initial state", fn(hub) {
///     // Use the hub
///     Nil
///   })
/// }
/// ```
pub fn new(
  with value: value_type,
  in context: fn(Hub(value_type)) -> result,
) -> result {
  let hub = start_stateful(value)

  let result = context(hub)
  stop_stateful(hub)

  result
}

/// Retrieves the current state of the hub.
///
/// ## Parameters
/// - `hub`: The `Hub` to retrieve the state from.
///
/// ## Returns
/// The current state value.
///
/// ## Example
/// ```gleam
/// import observer/stateful
///
/// pub fn example(hub: stateful.Hub(String)) {
///   let current_state = stateful.state(hub)
/// }
/// ```
pub fn state(of hub: Hub(value_type)) -> value_type {
  current_state(hub)
}

/// Notifies subscribers of the hub about an event with a new state value.
/// These notifications occur in parallel but `notify` waits for all of them to complete.
///
/// ## Parameters
/// - `hub`: The `Hub` to notify.
/// - `value`: The new state value.
///
/// ## Example
/// ```gleam
/// import observer/stateful
///
/// pub fn example(hub: stateful.Hub(String)) {
///   stateful.notify(hub, "new state")
/// }
/// ```
pub fn notify(on hub: Hub(value_type), with value: value_type) -> Nil {
  invoke_stateful(hub, value)
}

/// Subscribes to state changes and returns the current state and an unsubscribe function.
/// The callback will be invoked with the current state value when `notify` is called.
/// If `notify_current_state` is `True`, the callback will be immediately invoked with the current state.
///
/// ## Parameters
/// - `hub`: The `Hub` to add the callback to.
/// - `notify_current_state`: Whether to immediately invoke the callback with the current state.
/// - `callback`: The callback function to invoke with the state value.
///
/// ## Returns
/// A tuple containing the current state value and an `Unsubscribe` function that can be called to remove the callback.
///
/// ## Example
/// ```gleam
/// import gleam/io
/// import observer/stateful
/// 
/// pub fn example(hub: stateful.Hub(String)) {
///   let #(current_state, unsubscribe) =
///     stateful.subscribe(hub, True, fn(value) {
///       io.println("Received state: " <> value)
///     })
/// 
///   // To unsubscribe
///   unsubscribe()
/// }
/// ```
pub fn subscribe(
  on hub: Hub(value_type),
  should notify_current_state: Bool,
  with callback: observer.Callback(value_type),
) -> #(value_type, observer.Unsubscribe) {
  case notify_current_state {
    True -> {
      let current_state = state(hub)
      callback(current_state)
    }
    False -> Nil
  }

  let #(value, index) = add_stateful(hub, callback)

  let unsubscribe = fn() { remove_stateful(hub, index) }

  #(value, unsubscribe)
}
