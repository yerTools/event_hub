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
 * @param {Callbacks<T>} callbacks 
 * @param {T} value 
 */
function spawnInvoke (callbacks, value) {
  for (const [_, callback] of Object.entries(callbacks)) {
    queueMicrotask(() => callback.call(null, value));
  }
}

// Stateless observer
// ==================

/**
 * @template T
 * @returns {Hub<T>}
 */
export function start () {
    return {
        callbacks: {},
        index: 0,
    }
}

/**
 * @template T
 * @param {Hub<T>} hub 
 * @param {Callback<T>} callback
 * @returns {number}
 */
export function add (hub, callback) {
    const index = hub.index;
    hub.index++;

    hub.callbacks[index] = callback;
    return index;
}

/**
 * @template T
 * @param {Hub<T>} hub 
 * @param {T} value 
 */
export function invoke (hub, value) {
    spawnInvoke(hub.callbacks, value);
}

/**
 * @template T
 * @param {Hub<T>} hub 
 * @param {number} index 
 */
export function remove (hub, index) {
    delete hub.callbacks[index];
}

/**
 * @template T
 * @param {Hub<T>} hub 
 */
export function stop (hub) {
    hub.callbacks = {};
    hub.index = 0;
}

// Stateful observer
// =================

/**
 * @template T
 * @param {T} value 
 * @returns {StatefulHub<T>}
 */
export function startStateful (value) {
    return {
        callbacks: {},
        index: 0,
        value,
    }
}

/**
 * @template T
 * @param {StatefulHub<T>} hub 
 * @param {Callback<T>} callback
 * @returns {number}
 */
export function addStateful (hub, callback) {
    const index = hub.index;
    hub.index++;

    hub.callbacks[index] = callback;
    return index;
}

/**
 * @template T
 * @param {StatefulHub<T>} hub 
 */
export function currentState (hub) {
    return hub.value;
}

/**
 * @template T
 * @param {StatefulHub<T>} hub 
 * @param {T} value 
 */
export function invokeStateful (hub, value) {
    hub.value = value;
    spawnInvoke(hub.callbacks, value);
}

/**
 * @template T
 * @param {StatefulHub<T>} hub 
 * @param {number} index 
 */
export function removeStateful (hub, index) {
    delete hub.callbacks[index];
}

/**
 * @template T
 * @param {StatefulHub<T>} hub 
 */
export function stopStateful (hub) {
    hub.callbacks = {};
    hub.index = 0;
    hub.value = undefined;
}