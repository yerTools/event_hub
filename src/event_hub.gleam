//// The `event_hub` module provides a way to manage and notify subscribers about events.
//// It supports stateless observers, allowing functions to be registered and invoked in parallel when an event occurs.
////
//// ## Examples
////
//// ### Simple Observer
//// ```gleam
//// import gleam/io
//// import event_hub
//// 
//// pub fn main() {
////   use hub <- event_hub.new()
//// 
////   let unsubscribe =
////     event_hub.subscribe(hub, fn(value) {
////       io.println("Received value: " <> value)
////     })
//// 
////   event_hub.notify(hub, "Hello, world!")
////   unsubscribe()
////   event_hub.notify(hub, "This won't be received")
//// }
//// ```

/// Starts the stateless observer process.
@external(erlang, "event_hub_ffi", "start_stateless")
@external(javascript, "./event_hub_ffi.mjs", "startStateless")
fn start_stateless() -> Hub(value_type)

/// Adds a callback to the stateless observer, returning the index.
@external(erlang, "event_hub_ffi", "add_stateless")
@external(javascript, "./event_hub_ffi.mjs", "addStateless")
fn add_stateless(hub: Hub(value_type), callback: Callback(value_type)) -> Int

/// Invokes all callbacks in parallel with the given value and waits for all of them to complete.
@external(erlang, "event_hub_ffi", "invoke_stateless")
@external(javascript, "./event_hub_ffi.mjs", "invokeStateless")
fn invoke_stateless(hub: Hub(value_type), value: value_type) -> Nil

/// Removes a callback by its index.
@external(erlang, "event_hub_ffi", "remove_stateless")
@external(javascript, "./event_hub_ffi.mjs", "removeStateless")
fn remove_stateless(hub: Hub(value_type), index: Int) -> Nil

/// Stops the stateless observer process.
@external(erlang, "event_hub_ffi", "stop_stateless")
@external(javascript, "./event_hub_ffi.mjs", "stopStateless")
fn stop_stateless(hub: Hub(value_type)) -> Nil

/// Represents a hub for managing event subscriptions and notifications.
pub type Hub(value_type)

/// Represents a callback function that gets called with a value when an event occurs.
pub type Callback(value_type) =
  fn(value_type) -> Nil

/// Represents an unsubscribe function that can be called to remove a previously added callback.
pub type Unsubscribe =
  fn() -> Nil

/// Creates a new stateless observer hub, executes the given context with the hub, and stops the hub afterward.
///
/// ## Parameters
/// - `context`: A function that takes the created `Hub` and returns a result.
///
/// ## Returns
/// The result of executing the context function.
///
/// ## Example
/// ```gleam
/// import event_hub
/// 
/// pub fn example() {
///   event_hub.new(fn(hub) { event_hub.notify(hub, "event") })
/// }
/// ```
pub fn new(in context: fn(Hub(value_type)) -> result) -> result {
  let hub = start_stateless()

  let result = context(hub)
  stop_stateless(hub)

  result
}

/// Notifies all subscribers of the hub that an event has occurred with the given value.
/// These notifications occur in parallel but `notify` waits for all of them to complete.
///
/// ## Parameters
/// - `hub`: The `Hub` to notify.
/// - `value`: The value to send to all subscribers.
///
/// ## Example
/// ```gleam
/// import event_hub
///
/// pub fn example(hub: event_hub.Hub(String)) {
///   event_hub.notify(hub, "event")
/// }
/// ```
pub fn notify(on hub: Hub(value_type), with value: value_type) -> Nil {
  invoke_stateless(hub, value)
}

/// Adds a callback to the hub and returns an unsubscribe function.
///
/// ## Parameters
/// - `hub`: The `Hub` to add the callback to.
/// - `callback`: The callback function to add.
///
/// ## Returns
/// An `Unsubscribe` function that can be called to remove the callback.
///
/// ## Example
/// ```gleam
/// import gleam/io
/// import event_hub
/// 
/// pub fn example(hub: event_hub.Hub(String)) {
///   let unsubscribe =
///     event_hub.subscribe(hub, fn(value) {
///       io.println("Received value: " <> value)
///     })
/// 
///   // To unsubscribe
///   unsubscribe()
/// }
/// ```
pub fn subscribe(
  on hub: Hub(value_type),
  with callback: Callback(value_type),
) -> Unsubscribe {
  let index = add_stateless(hub, callback)
  fn() { remove_stateless(hub, index) }
}
