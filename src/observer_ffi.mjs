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

/**
 * @template T
 * @typedef {{callbacks: Callbacks<T>, index: number, topicIndex: {[topic: string]: number[]}}} TopicBasedHub
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

/**
 * Updates the topic index with a new subscription.
 * @param {{[topic: string]: number[]}} topicIndex
 * @param {string[]} topics
 * @param {number} index
 * @returns {{[topic: string]: number[]}}
 */
function updateTopicIndex(topicIndex, topics, index) {
  const newTopicIndex = { ...topicIndex };
  for (const topic of topics) {
    if (!newTopicIndex[topic]) {
      newTopicIndex[topic] = [];
    }
    newTopicIndex[topic].push(index);
  }
  return newTopicIndex;
}

/**
 * Removes a subscription from the topic index.
 * @param {{[topic: string]: number[]}} topicIndex
 * @param {string[]} topics
 * @param {number} index
 * @returns {{[topic: string]: number[]}}
 */
function removeFromTopicIndex(topicIndex, topics, index) {
  const newTopicIndex = { ...topicIndex };
  for (const topic of topics) {
    if (newTopicIndex[topic]) {
      newTopicIndex[topic] = newTopicIndex[topic].filter((i) => i !== index);
      if (newTopicIndex[topic].length === 0) {
        delete newTopicIndex[topic];
      }
    }
  }
  return newTopicIndex;
}

/**
 * Finds callbacks whose topics intersect with the provided topics.
 * @template T
 * @param {{[topic: string]: number[]}} topicIndex
 * @param {string[]} topics
 * @param {Callbacks<T>} callbacks
 * @returns {Callbacks<T>}
 */
function findMatchingCallbacks(topicIndex, topics, callbacks) {
  const matchingIndices = new Set();
  for (const topic of topics) {
    if (topicIndex[topic]) {
      for (const index of topicIndex[topic]) {
        matchingIndices.add(index);
      }
    }
  }
  const matchingCallbacks = {};
  for (const index of matchingIndices) {
    matchingCallbacks[index] = callbacks[index];
  }
  return matchingCallbacks;
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
 * Clears all callbacks and the value from the stateful observer.
 * @template T
 * @param {StatefulHub<T>} hub
 */
export function stopStateful(hub) {
  hub.callbacks = {};
  hub.index = 0;
  hub.value = undefined;
}

// Topic-based observer
// ====================

/**
 * Creates a new topic-based observer.
 * @template T
 * @returns {TopicBasedHub<T>}
 */
export function startTopicBased() {
  return {
    callbacks: {},
    index: 0,
    topicIndex: {},
  };
}

/**
 * Adds a callback with a list of topics to the topic-based observer, returning the index.
 * @template T
 * @param {TopicBasedHub<T>} hub
 * @param {string[]} topics
 * @param {Callback<T>} callback
 * @returns {number}
 */
export function addTopicBased(hub, topics, callback) {
  hub.index++;
  hub.callbacks[hub.index] = callback;
  hub.topicIndex = updateTopicIndex(hub.topicIndex, topics, hub.index);
  return hub.index;
}

/**
 * Invokes all matching callbacks synchronously with the given topics and value.
 * @template T
 * @param {TopicBasedHub<T>} hub
 * @param {string[]} topics
 * @param {T} value
 */
export function invokeTopicBased(hub, topics, value) {
  const matchingCallbacks = findMatchingCallbacks(
    hub.topicIndex,
    topics,
    hub.callbacks,
  );
  invokeCallbacks(matchingCallbacks, value);
}

/**
 * Removes a callback by its index.
 * @template T
 * @param {TopicBasedHub<T>} hub
 * @param {number} index
 */
export function removeTopicBased(hub, index) {
  const topics = Object.keys(hub.topicIndex).filter((topic) =>
    hub.topicIndex[topic].includes(index),
  );
  hub.topicIndex = removeFromTopicIndex(hub.topicIndex, topics, index);
  delete hub.callbacks[index];
}

/**
 * Clears all callbacks and the topic index from the stateful observer.
 * @template T
 * @param {TopicBasedHub<T>} hub
 */
export function stopTopicBased(hub) {
  hub.callbacks = {};
  hub.index = 0;
  hub.topicIndex = {};
}
