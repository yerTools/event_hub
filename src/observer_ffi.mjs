/**
 * @template T
 * @typedef {(value: T) => void} Callback
 */

/**
 * @template T
 * @typedef  {{[index: number]: Callback<T>}} Callbacks
 */

/**
 * @template T
 * @typedef {{callbacks: Callbacks<T>, index: number}} Hub
 */

/**
 * @template T
 * @typedef {{callbacks: Callbacks<T>, index: number, value: T}} StatefulHub
 */

// Helper functions
// ================

/**
 * Invoke each callback synchronously with the provided value.
 * @template T
 * @param {Callbacks<T>} callbacks
 * @param {T} value
 */
function invokeCallbacks(callbacks, value) {
  for (const [_, callback] of Object.entries(callbacks)) {
    callback.call(null, value);
  }
}

// Stateless observer
// ==================

/**
 * Creates a new stateless observer.
 * @template T
 * @returns {Hub<T>}
 */
export function startStateless() {
  return {
    callbacks: {},
    index: 0,
  };
}

/**
 * Adds a callback to the stateless observer, returning the index.
 * @template T
 * @param {Hub<T>} hub
 * @param {Callback<T>} callback
 * @returns {number}
 */
export function addStateless(hub, callback) {
  hub.index++;

  hub.callbacks[hub.index] = callback;
  return hub.index;
}

/**
 * Invokes all callbacks synchronously with the given value.
 * @template T
 * @param {Hub<T>} hub
 * @param {T} value
 */
export function invokeStateless(hub, value) {
  invokeCallbacks(hub.callbacks, value);
}

/**
 * Removes a callback by its index.
 * @template T
 * @param {Hub<T>} hub
 * @param {number} index
 */
export function removeStateless(hub, index) {
  delete hub.callbacks[index];
}

/**
 * Clears all callbacks from the stateless observer.
 * @template T
 * @param {Hub<T>} hub
 */
export function stopStateless(hub) {
  hub.callbacks = {};
  hub.index = 0;
}

// Stateful observer
// =================

/**
 * Creates a new stateful observer with an initial state.
 * @template T
 * @param {T} value
 * @returns {StatefulHub<T>}
 */
export function startStateful(value) {
  return {
    callbacks: {},
    index: 0,
    value,
  };
}

/**
 * Adds a callback to the stateful observer, returning the current state and index.
 * @template T
 * @param {StatefulHub<T>} hub
 * @param {Callback<T>} callback
 * @returns {[T, number]}
 */
export function addStateful(hub, callback) {
  hub.index++;

  hub.callbacks[hub.index] = callback;
  return [hub.value, hub.index];
}

/**
 * Retrieves the current state.
 * @template T
 * @param {StatefulHub<T>} hub
 * @returns {T}
 */
export function currentState(hub) {
  return hub.value;
}

/**
 * Invokes all callbacks synchronously with a new state, updating the state.
 * @template T
 * @param {StatefulHub<T>} hub
 * @param {T} value
 */
export function invokeStateful(hub, value) {
  hub.value = value;
  invokeCallbacks(hub.callbacks, value);
}

/**
 * Removes a callback by its index.
 * @template T
 * @param {StatefulHub<T>} hub
 * @param {number} index
 */
export function removeStateful(hub, index) {
  delete hub.callbacks[index];
}

/**
 * Stops the stateful observer process.
 * @template T
 * @param {StatefulHub<T>} hub
 */
export function stopStateful(hub) {
  hub.callbacks = {};
  hub.index = 0;
  hub.value = undefined;
}
