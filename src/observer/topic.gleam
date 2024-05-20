import gleam/dict
import gleam/list
import observer

type TopicValue(value_type) {
  TopicValue(topics: List(String), value: value_type)
}

pub opaque type Hub(value_type) {
  Hub(inner: observer.Hub(TopicValue(value_type)))
}

fn has_intersection(a: List(String), b: List(String)) -> Bool {
  let #(smaller, larger) = case list.length(a) > list.length(b) {
    True -> #(a, b)
    False -> #(b, a)
  }

  let smaller = dict.from_list(list.map(smaller, fn(topic) { #(topic, Nil) }))
  list.any(larger, fn(topic) { dict.has_key(smaller, topic) })
}

pub fn new(in context: fn(Hub(value_type)) -> result) -> result {
  use inner <- observer.new()
  let hub = Hub(inner)

  context(hub)
}

pub fn notify(
  on hub: Hub(value_type),
  and topics: List(String),
  with value: value_type,
) -> Nil {
  observer.notify(hub.inner, TopicValue(topics, value))
}

pub fn subscribe(
  on hub: Hub(value_type),
  and topics: List(String),
  with callback: observer.Callback(value_type),
) -> observer.Unsubscribe {
  use value <- observer.subscribe(hub.inner)
  let TopicValue(message_topics, value) = value

  case has_intersection(topics, message_topics) {
    True -> callback(value)
    False -> Nil
  }
}

type TopicValue2(value_type) {
  TopicValue2(topics1: List(String), topics2: List(String), value: value_type)
}

pub opaque type Hub2(value_type) {
  Hub2(inner: observer.Hub(TopicValue2(value_type)))
}

pub fn new2(in context: fn(Hub2(value_type)) -> result) -> result {
  use inner <- observer.new()
  let hub = Hub2(inner)

  context(hub)
}

pub fn notify2(
  hub: Hub2(value_type),
  topics1: List(String),
  topics2: List(String),
  value: value_type,
) -> Nil {
  observer.notify(hub.inner, TopicValue2(topics1, topics2, value))
}

pub fn subscribe2(
  hub: Hub2(value_type),
  topics1: List(String),
  topics2: List(String),
  callback: observer.Callback(value_type),
) -> observer.Unsubscribe {
  use value <- observer.subscribe(hub.inner)
  let TopicValue2(message_topics1, message_topics2, value) = value

  case
    has_intersection(topics1, message_topics1)
    && has_intersection(topics2, message_topics2)
  {
    True -> callback(value)
    False -> Nil
  }
}

type TopicValue3(value_type) {
  TopicValue3(
    topics1: List(String),
    topics2: List(String),
    topics3: List(String),
    value: value_type,
  )
}

pub opaque type Hub3(value_type) {
  Hub3(inner: observer.Hub(TopicValue3(value_type)))
}

pub fn new3(in context: fn(Hub3(value_type)) -> result) -> result {
  use inner <- observer.new()
  let hub = Hub3(inner)

  context(hub)
}

pub fn notify3(
  hub: Hub3(value_type),
  topics1: List(String),
  topics2: List(String),
  topics3: List(String),
  value: value_type,
) -> Nil {
  observer.notify(hub.inner, TopicValue3(topics1, topics2, topics3, value))
}

pub fn subscribe3(
  hub: Hub3(value_type),
  topics1: List(String),
  topics2: List(String),
  topics3: List(String),
  callback: observer.Callback(value_type),
) -> observer.Unsubscribe {
  use value <- observer.subscribe(hub.inner)
  let TopicValue3(message_topics1, message_topics2, message_topics3, value) =
    value

  case
    has_intersection(topics1, message_topics1)
    && has_intersection(topics2, message_topics2)
    && has_intersection(topics3, message_topics3)
  {
    True -> callback(value)
    False -> Nil
  }
}

pub opaque type TopicValue4(value_type) {
  TopicValue4(
    topics1: List(String),
    topics2: List(String),
    topics3: List(String),
    topics4: List(String),
    value: value_type,
  )
}

pub opaque type Hub4(value_type) {
  Hub4(inner: observer.Hub(TopicValue4(value_type)))
}

pub fn new4(in context: fn(Hub4(value_type)) -> result) -> result {
  use inner <- observer.new()
  let hub = Hub4(inner)

  context(hub)
}

pub fn notify4(
  hub: Hub4(value_type),
  topics1: List(String),
  topics2: List(String),
  topics3: List(String),
  topics4: List(String),
  value: value_type,
) -> Nil {
  observer.notify(
    hub.inner,
    TopicValue4(topics1, topics2, topics3, topics4, value),
  )
}

pub fn subscribe4(
  hub: Hub4(value_type),
  topics1: List(String),
  topics2: List(String),
  topics3: List(String),
  topics4: List(String),
  callback: observer.Callback(value_type),
) -> observer.Unsubscribe {
  use value <- observer.subscribe(hub.inner)
  let TopicValue4(
    message_topics1,
    message_topics2,
    message_topics3,
    message_topics4,
    value,
  ) = value

  case
    has_intersection(topics1, message_topics1)
    && has_intersection(topics2, message_topics2)
    && has_intersection(topics3, message_topics3)
    && has_intersection(topics4, message_topics4)
  {
    True -> callback(value)
    False -> Nil
  }
}
