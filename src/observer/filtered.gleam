import gleam/list
import gleam/set
import observer

type TopicValuePair(value_type, topic_type) =
  #(List(topic_type), value_type)

pub opaque type Hub(value_type, topic_type) {
  Hub(hub: observer.Hub(TopicValuePair(value_type, topic_type)))
}

pub fn new(in context: fn(Hub(value_type, topic_type)) -> result) -> result {
  use hub <- observer.new()
  let hub = Hub(hub)

  context(hub)
}

pub fn notify(
  on hub: Hub(value_type, topic_type),
  with topics: List(topic_type),
  and value: value_type,
) -> Nil {
  observer.notify(hub.hub, #(topics, value))
}

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

pub opaque type Hub2(value_type, topic_type1, topic_type2) {
  Hub2(hub: Hub(TopicValuePair(value_type, topic_type2), topic_type1))
}

pub fn new2(
  in context: fn(Hub2(value_type, topic_type1, topic_type2)) -> result,
) -> result {
  use hub <- new()
  let hub = Hub2(hub)

  context(hub)
}

pub fn notify2(
  hub: Hub2(value_type, topic_type1, topic_type2),
  topics1: List(topic_type1),
  topics2: List(topic_type2),
  value: value_type,
) -> Nil {
  notify(hub.hub, topics1, #(topics2, value))
}

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

pub opaque type Hub3(value_type, topic_type1, topic_type2, topic_type3) {
  Hub3(
    hub: Hub2(TopicValuePair(value_type, topic_type3), topic_type1, topic_type2),
  )
}

pub fn new3(
  in context: fn(Hub3(value_type, topic_type1, topic_type2, topic_type3)) ->
    result,
) -> result {
  use hub <- new2()
  let hub = Hub3(hub)

  context(hub)
}

pub fn notify3(
  hub: Hub3(value_type, topic_type1, topic_type2, topic_type3),
  topics1: List(topic_type1),
  topics2: List(topic_type2),
  topics3: List(topic_type3),
  value: value_type,
) -> Nil {
  notify2(hub.hub, topics1, topics2, #(topics3, value))
}

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
