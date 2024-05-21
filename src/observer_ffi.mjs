// @ts-check
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
 * @typedef  {{[index: number]: [string[][], Callback<T>]}} TopicCallbacks
 */

/**
 * @template T
 * @typedef {{ indices: number[], next: TopicIndex<T>}} TopicIndexEntry
 */

/**
 * @template T
 * @typedef {{[topic: string]: TopicIndexEntry<T>}} TopicIndex
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
 * @typedef {{callbacks: TopicCallbacks<T>, index: number, topicIndex: TopicIndex<T>}} TopicBasedHub
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
 * @template T
 * @param {TopicIndex<T>} topicIndex
 * @param {string[][]} topics
 * @param {number} index
 */
function updateTopicIndex(topicIndex, topics, index) {
  if (topics.length !== 0) {
    const [first, ...rest] = topics;

    for (const topic of first) {
      if (!topicIndex[topic]) {
        topicIndex[topic] = { indices: [], next: {} };
      }
      if (rest.length === 0) {
        topicIndex[topic].indices.push(index);
      } else {
        updateTopicIndex(topicIndex[topic].next, rest, index);
      }
    }
  }
}

/**
 * Removes a subscription from the topic index.
 * @template T
 * @param {TopicIndex<T>} topicIndex
 * @param {string[][]} topics
 * @param {number} index
 */
function removeFromTopicIndex(topicIndex, topics, index) {
  if (topics.length !== 0) {
    const [first, ...rest] = topics;

    for (const topic of first) {
      if (topicIndex[topic]) {
        if (rest.length === 0) {
          const indices = topicIndex[topic].indices;
          const newIndices = indices.filter((i) => i !== index);
          topicIndex[topic].indices = newIndices;

          if (
            newIndices.length === 0 &&
            Object.keys(topicIndex[topic].next).length === 0
          ) {
            delete topicIndex[topic];
          }
        } else {
          removeFromTopicIndex(topicIndex[topic].next, rest, index);
        }
      }
    }
  }
}

/**
 * Finds callbacks whose topics intersect with the provided topics.
 * @template T
 * @param {TopicIndex<T>} topicIndex
 * @param {string[][]} topics
 * @param {TopicCallbacks<T>} callbacks
 * @returns {Callbacks<T>}
 */
function findMatchingCallbacks(topicIndex, topics, callbacks) {
  if (topics.length === 0) {
    return {};
  }

  /** @type {Callbacks<T>} */
  const matchingCallbacks = {};
  const [first, ...rest] = topics;

  for (const topic of first) {
    if (rest.length === 0) {
      if (topicIndex[topic]) {
        for (const index of topicIndex[topic].indices) {
          matchingCallbacks[index] = callbacks[index][1];
        }
      }
    } else {
      if (!topicIndex[topic]) {
        continue;
      }

      const next = findMatchingCallbacks(
        topicIndex[topic].next,
        rest,
        callbacks,
      );
      for (const [index, callback] of Object.entries(next)) {
        matchingCallbacks[index] = callback;
      }
    }
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
  // @ts-ignore
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
 * @param {string[][]} topics
 * @param {Callback<T>} callback
 * @returns {number}
 */
export function addTopicBased(hub, topics, callback) {
  topics = [...topics];

  hub.index++;
  hub.callbacks[hub.index] = [topics, callback];

  updateTopicIndex(hub.topicIndex, topics, hub.index);
  return hub.index;
}

/**
 * Invokes all matching callbacks synchronously with the given topics and value.
 * @template T
 * @param {TopicBasedHub<T>} hub
 * @param {string[][]} topics
 * @param {T} value
 */
export function invokeTopicBased(hub, topics, value) {
  topics = [...topics];

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
  if (!hub.callbacks[index]) {
    return;
  }

  const topics = hub.callbacks[index][0];
  removeFromTopicIndex(hub.topicIndex, topics, index);
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
