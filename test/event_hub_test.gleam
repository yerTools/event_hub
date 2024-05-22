import event_hub
import event_hub/filtered
import event_hub/reactive
import event_hub/stateful
import event_hub/topic
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

/// Please do not use this library as a mutable state container.
type MutableValue(value_type) {
  MutableValue(container: stateful.Hub(value_type))
}

/// Please do not use this library as a mutable state container.
fn mut(value: value_type, context: fn(MutableValue(value_type)) -> Nil) -> Nil {
  use hub <- stateful.new(value)
  context(MutableValue(hub))
}

/// Please do not use this library as a mutable state container.
fn set(mutable_value: MutableValue(value_type), value: value_type) -> Nil {
  stateful.notify(mutable_value.container, value)
}

/// Please do not use this library as a mutable state container.
fn get(mutable_value: MutableValue(value_type)) -> value_type {
  stateful.state(mutable_value.container)
}

/// Please do not use this library as a mutable state container.
fn expect(
  mutable_value: MutableValue(value_type),
  to_have value: value_type,
) -> Nil {
  get(mutable_value)
  |> should.equal(value)
}

/// Please do not use this library as a mutable state container.
pub fn stateful_as_mutable_test() {
  use a <- mut(1)
  use b <- mut(2)
  use c <- mut(3)

  expect(a, 1)
  expect(b, 2)
  expect(c, 3)

  set(a, 4)
  set(b, 5)
  set(c, 6)

  expect(a, 4)
  expect(b, 5)
  expect(c, 6)
}

pub fn stateless_test() {
  use a <- mut(0)
  use b <- mut(0)

  use hub <- event_hub.new()

  expect(a, 0)
  expect(b, 0)

  event_hub.notify(hub, 1)

  expect(a, 0)
  expect(b, 0)

  let unsubscribe_a = event_hub.subscribe(hub, fn(value) { set(a, value) })

  expect(a, 0)
  expect(b, 0)

  event_hub.notify(hub, 2)

  expect(a, 2)
  expect(b, 0)

  let unsubscribe_b = event_hub.subscribe(hub, fn(value) { set(b, value) })

  expect(a, 2)
  expect(b, 0)

  event_hub.notify(hub, 3)

  expect(a, 3)
  expect(b, 3)

  unsubscribe_a()

  expect(a, 3)
  expect(b, 3)

  event_hub.notify(hub, 4)

  expect(a, 3)
  expect(b, 4)

  unsubscribe_b()

  expect(a, 3)
  expect(b, 4)

  event_hub.notify(hub, 5)

  expect(a, 3)
  expect(b, 4)

  Nil
}

pub fn stateful_without_subscription_notification_test() {
  use a <- mut(0)
  use b <- mut(0)

  use hub <- stateful.new(1)

  expect(a, 0)
  expect(b, 0)
  stateful.state(hub)
  |> should.equal(1)

  stateful.notify(hub, 2)

  expect(a, 0)
  expect(b, 0)
  stateful.state(hub)
  |> should.equal(2)

  let #(current, unsubscribe_a) =
    stateful.subscribe(hub, False, fn(value) { set(a, value) })

  expect(a, 0)
  expect(b, 0)
  current
  |> should.equal(2)
  stateful.state(hub)
  |> should.equal(2)

  stateful.notify(hub, 3)

  expect(a, 3)
  expect(b, 0)
  stateful.state(hub)
  |> should.equal(3)

  let #(current, unsubscribe_b) =
    stateful.subscribe(hub, False, fn(value) { set(b, value) })

  expect(a, 3)
  expect(b, 0)
  current
  |> should.equal(3)
  stateful.state(hub)
  |> should.equal(3)

  stateful.notify(hub, 4)

  expect(a, 4)
  expect(b, 4)
  stateful.state(hub)
  |> should.equal(4)

  unsubscribe_a()

  expect(a, 4)
  expect(b, 4)
  stateful.state(hub)
  |> should.equal(4)

  stateful.notify(hub, 5)

  expect(a, 4)
  expect(b, 5)
  stateful.state(hub)
  |> should.equal(5)

  unsubscribe_b()

  expect(a, 4)
  expect(b, 5)
  stateful.state(hub)
  |> should.equal(5)

  stateful.notify(hub, 6)

  expect(a, 4)
  expect(b, 5)
  stateful.state(hub)
  |> should.equal(6)

  Nil
}

pub fn stateful_with_subscription_notification_test() {
  use a <- mut(0)
  use b <- mut(0)

  use hub <- stateful.new(1)

  expect(a, 0)
  expect(b, 0)
  stateful.state(hub)
  |> should.equal(1)

  stateful.notify(hub, 2)

  expect(a, 0)
  expect(b, 0)
  stateful.state(hub)
  |> should.equal(2)

  let #(current, unsubscribe_a) =
    stateful.subscribe(hub, True, fn(value) { set(a, value) })

  expect(a, 2)
  expect(b, 0)
  current
  |> should.equal(2)
  stateful.state(hub)
  |> should.equal(2)

  stateful.notify(hub, 3)

  expect(a, 3)
  expect(b, 0)
  stateful.state(hub)
  |> should.equal(3)

  let #(current, unsubscribe_b) =
    stateful.subscribe(hub, True, fn(value) { set(b, value) })

  expect(a, 3)
  expect(b, 3)
  current
  |> should.equal(3)
  stateful.state(hub)
  |> should.equal(3)

  stateful.notify(hub, 4)

  expect(a, 4)
  expect(b, 4)
  stateful.state(hub)
  |> should.equal(4)

  unsubscribe_a()

  expect(a, 4)
  expect(b, 4)
  stateful.state(hub)
  |> should.equal(4)

  stateful.notify(hub, 5)

  expect(a, 4)
  expect(b, 5)
  stateful.state(hub)
  |> should.equal(5)

  unsubscribe_b()

  expect(a, 4)
  expect(b, 5)
  stateful.state(hub)
  |> should.equal(5)

  stateful.notify(hub, 6)

  expect(a, 4)
  expect(b, 5)
  stateful.state(hub)
  |> should.equal(6)

  Nil
}

pub fn topic_based1_test() {
  use a <- mut(0)
  use b <- mut(0)
  use c <- mut(0)

  use hub <- topic.new()

  expect(a, 0)
  expect(b, 0)
  expect(c, 0)

  topic.notify(hub, ["x"], 1)

  expect(a, 0)
  expect(b, 0)
  expect(c, 0)

  let unsubscribe_a = topic.subscribe(hub, ["x"], fn(value) { set(a, value) })

  let unsubscribe_b = topic.subscribe(hub, ["y"], fn(value) { set(b, value) })

  let unsubscribe_c = topic.subscribe(hub, ["z"], fn(value) { set(c, value) })

  expect(a, 0)
  expect(b, 0)
  expect(c, 0)

  topic.notify(hub, ["x"], 2)

  expect(a, 2)
  expect(b, 0)
  expect(c, 0)

  topic.notify(hub, ["y"], 3)

  expect(a, 2)
  expect(b, 3)
  expect(c, 0)

  topic.notify(hub, ["z"], 4)

  expect(a, 2)
  expect(b, 3)
  expect(c, 4)

  unsubscribe_a()
  unsubscribe_b()
  unsubscribe_c()

  topic.notify(hub, ["x"], 5)
  topic.notify(hub, ["y"], 6)
  topic.notify(hub, ["z"], 7)

  expect(a, 2)
  expect(b, 3)
  expect(c, 4)

  Nil
}

pub fn topic_based2_test() {
  use a <- mut(0)
  use b <- mut(0)
  use c <- mut(0)

  use hub <- topic.new2()

  expect(a, 0)
  expect(b, 0)
  expect(c, 0)

  topic.notify2(hub, ["x"], ["y"], 1)

  expect(a, 0)
  expect(b, 0)
  expect(c, 0)

  let unsubscribe_a =
    topic.subscribe2(hub, ["x"], ["y"], fn(value) { set(a, value) })

  let unsubscribe_b =
    topic.subscribe2(hub, ["x"], ["z"], fn(value) { set(b, value) })

  let unsubscribe_c =
    topic.subscribe2(hub, ["y"], ["z"], fn(value) { set(c, value) })

  topic.notify2(hub, ["x"], ["y"], 2)
  topic.notify2(hub, ["x"], ["z"], 3)
  topic.notify2(hub, ["y"], ["z"], 4)

  expect(a, 2)
  expect(b, 3)
  expect(c, 4)

  unsubscribe_a()
  unsubscribe_b()
  unsubscribe_c()

  topic.notify2(hub, ["x"], ["y"], 5)
  topic.notify2(hub, ["x"], ["z"], 6)
  topic.notify2(hub, ["y"], ["z"], 7)

  expect(a, 2)
  expect(b, 3)
  expect(c, 4)

  Nil
}

pub fn topic_based3_test() {
  use a <- mut(0)
  use b <- mut(0)
  use c <- mut(0)
  use d <- mut(0)

  use hub <- topic.new3()

  expect(a, 0)
  expect(b, 0)
  expect(c, 0)
  expect(d, 0)

  topic.notify3(hub, ["x"], ["y"], ["z"], 1)

  expect(a, 0)
  expect(b, 0)
  expect(c, 0)
  expect(d, 0)

  let unsubscribe_a =
    topic.subscribe3(hub, ["x"], ["y"], ["z"], fn(value) { set(a, value) })

  let unsubscribe_b =
    topic.subscribe3(hub, ["x"], ["y"], ["w"], fn(value) { set(b, value) })

  let unsubscribe_c =
    topic.subscribe3(hub, ["x"], ["z"], ["w"], fn(value) { set(c, value) })

  let unsubscribe_d =
    topic.subscribe3(hub, ["y"], ["z"], ["w"], fn(value) { set(d, value) })

  topic.notify3(hub, ["x"], ["y"], ["z"], 2)
  topic.notify3(hub, ["x"], ["y"], ["w"], 3)
  topic.notify3(hub, ["x"], ["z"], ["w"], 4)
  topic.notify3(hub, ["y"], ["z"], ["w"], 5)

  expect(a, 2)
  expect(b, 3)
  expect(c, 4)
  expect(d, 5)

  unsubscribe_a()
  unsubscribe_b()
  unsubscribe_c()
  unsubscribe_d()

  topic.notify3(hub, ["x"], ["y"], ["z"], 6)
  topic.notify3(hub, ["x"], ["y"], ["w"], 7)
  topic.notify3(hub, ["x"], ["z"], ["w"], 8)
  topic.notify3(hub, ["y"], ["z"], ["w"], 9)

  expect(a, 2)
  expect(b, 3)
  expect(c, 4)
  expect(d, 5)

  Nil
}

pub fn topic_based_n_test() {
  use a <- mut(0)
  use b <- mut(0)
  use c <- mut(0)
  use d <- mut(0)
  use e <- mut(0)

  use hub <- topic.new_n()

  expect(a, 0)
  expect(b, 0)
  expect(c, 0)
  expect(d, 0)
  expect(e, 0)

  topic.notify_n(hub, [["x"], ["y"], ["z"], ["w"]], 1)

  expect(a, 0)
  expect(b, 0)
  expect(c, 0)
  expect(d, 0)
  expect(e, 0)

  let unsubscribe_a =
    topic.subscribe_n(hub, [["x"], ["y"], ["z"], ["w"]], fn(value) {
      set(a, value)
    })

  let unsubscribe_b =
    topic.subscribe_n(hub, [["x"], ["y"], ["z"], ["v"]], fn(value) {
      set(b, value)
    })

  let unsubscribe_c =
    topic.subscribe_n(hub, [["x"], ["y"], ["v"], ["w"]], fn(value) {
      set(c, value)
    })

  let unsubscribe_d =
    topic.subscribe_n(hub, [["x"], ["v"], ["z"], ["w"]], fn(value) {
      set(d, value)
    })

  let unsubscribe_e =
    topic.subscribe_n(hub, [["v"], ["y"], ["z"], ["w"]], fn(value) {
      set(e, value)
    })

  topic.notify_n(hub, [["x"], ["y"], ["z"], ["w"]], 2)
  topic.notify_n(hub, [["x"], ["y"], ["z"], ["v"]], 3)
  topic.notify_n(hub, [["x"], ["y"], ["v"], ["w"]], 4)
  topic.notify_n(hub, [["x"], ["v"], ["z"], ["w"]], 5)
  topic.notify_n(hub, [["v"], ["y"], ["z"], ["w"]], 6)

  expect(a, 2)
  expect(b, 3)
  expect(c, 4)
  expect(d, 5)
  expect(e, 6)

  unsubscribe_a()
  unsubscribe_b()
  unsubscribe_c()
  unsubscribe_d()
  unsubscribe_e()

  topic.notify_n(hub, [["x"], ["y"], ["z"], ["w"]], 7)
  topic.notify_n(hub, [["x"], ["y"], ["z"], ["v"]], 8)
  topic.notify_n(hub, [["x"], ["y"], ["v"], ["w"]], 9)
  topic.notify_n(hub, [["x"], ["v"], ["z"], ["w"]], 10)
  topic.notify_n(hub, [["v"], ["y"], ["z"], ["w"]], 11)

  expect(a, 2)
  expect(b, 3)
  expect(c, 4)
  expect(d, 5)
  expect(e, 6)

  Nil
}

pub fn topic_based4_test() {
  use a <- mut(0)
  use b <- mut(0)
  use c <- mut(0)

  use hub <- topic.new4()

  expect(a, 0)
  expect(b, 0)
  expect(c, 0)

  topic.notify4(hub, ["x"], ["y"], ["z"], ["a"], 1)

  expect(a, 0)
  expect(b, 0)
  expect(c, 0)

  let unsubscribe_a =
    topic.subscribe4(hub, ["x"], ["y"], ["z"], ["a", "*", "ab"], fn(value) {
      set(a, value)
    })

  expect(a, 0)
  expect(b, 0)
  expect(c, 0)

  topic.notify4(hub, ["x"], ["y"], ["z"], ["a", "c"], 2)

  expect(a, 2)
  expect(b, 0)
  expect(c, 0)

  let unsubscribe_b =
    topic.subscribe4(hub, ["x"], ["y"], ["z"], ["b", "*", "ab"], fn(value) {
      set(b, value)
    })

  expect(a, 2)
  expect(b, 0)
  expect(c, 0)

  topic.notify4(hub, ["x"], ["y"], ["z"], ["*"], 3)

  expect(a, 3)
  expect(b, 3)
  expect(c, 0)

  let unsubscribe_c =
    topic.subscribe4(hub, ["x"], ["y"], ["z"], ["c", "*"], fn(value) {
      set(c, value)
    })

  expect(a, 3)
  expect(b, 3)
  expect(c, 0)

  topic.notify4(hub, ["x"], ["y"], ["z"], ["ab", "a"], 4)

  expect(a, 4)
  expect(b, 4)
  expect(c, 0)

  topic.notify4(hub, ["x"], ["y"], ["z"], ["a", "c"], 5)

  expect(a, 5)
  expect(b, 4)
  expect(c, 5)

  topic.notify4(hub, ["x"], ["y"], ["z"], ["c", "d"], 6)

  expect(a, 5)
  expect(b, 4)
  expect(c, 6)

  topic.notify4(hub, ["x"], ["y"], ["z"], ["a"], 7)

  expect(a, 7)
  expect(b, 4)
  expect(c, 6)

  topic.notify4(hub, ["x"], ["y"], ["z"], [], 8)

  expect(a, 7)
  expect(b, 4)
  expect(c, 6)

  topic.notify4(hub, ["x"], ["y"], ["z"], ["*"], 9)

  expect(a, 9)
  expect(b, 9)
  expect(c, 9)

  unsubscribe_a()

  expect(a, 9)
  expect(b, 9)
  expect(c, 9)

  topic.notify4(hub, ["x"], ["y"], ["z"], ["ab"], 10)

  expect(a, 9)
  expect(b, 10)
  expect(c, 9)

  unsubscribe_b()

  expect(a, 9)
  expect(b, 10)
  expect(c, 9)

  topic.notify4(hub, ["x"], ["y"], ["z"], ["ab"], 11)

  expect(a, 9)
  expect(b, 10)
  expect(c, 9)

  unsubscribe_c()

  expect(a, 9)
  expect(b, 10)
  expect(c, 9)

  topic.notify4(hub, ["x"], ["y"], ["z"], ["a", "b", "c"], 11)

  expect(a, 9)
  expect(b, 10)
  expect(c, 9)

  Nil
}

pub fn reactive_test() {
  use counter <- mut(1)

  use a <- mut(0)
  use b <- mut(0)

  use hub <- reactive.new(fn() {
    let next = get(counter) + 1
    set(counter, next)
    next
  })

  expect(counter, 1)
  expect(a, 0)
  expect(b, 0)

  reactive.notify(hub)

  expect(counter, 2)
  expect(a, 0)
  expect(b, 0)

  let unsubscribe_a = reactive.subscribe(hub, fn(value) { set(a, value) })

  expect(counter, 2)
  expect(a, 0)
  expect(b, 0)

  reactive.notify(hub)

  expect(counter, 3)
  expect(a, 3)
  expect(b, 0)

  let unsubscribe_b = reactive.subscribe(hub, fn(value) { set(b, value) })

  expect(counter, 3)
  expect(a, 3)
  expect(b, 0)

  reactive.notify(hub)

  expect(counter, 4)
  expect(a, 4)
  expect(b, 4)

  unsubscribe_a()

  expect(counter, 4)
  expect(a, 4)
  expect(b, 4)

  reactive.notify(hub)

  expect(counter, 5)
  expect(a, 4)
  expect(b, 5)

  unsubscribe_b()

  expect(counter, 5)
  expect(a, 4)
  expect(b, 5)

  reactive.notify(hub)

  expect(counter, 6)
  expect(a, 4)
  expect(b, 5)

  Nil
}

pub fn stateful_function_test() {
  use a <- mut("")
  let callback = fn(value) { set(a, value) }

  use hub <- stateful.new(callback)

  let #(_, unsubscribe) =
    stateful.subscribe(hub, False, fn(value) { value("test 1") })

  expect(a, "")

  stateful.notify(hub, callback)

  expect(a, "test 1")
  unsubscribe()

  stateful.subscribe(hub, True, fn(value) { value("test 2") })

  expect(a, "test 2")

  Nil
}

pub fn stateless_hub_in_hub_test() {
  use a <- mut(0)

  use inner_hub <- event_hub.new()
  use outer_hub <- event_hub.new()

  event_hub.subscribe(inner_hub, fn(value) { set(a, value) })

  event_hub.subscribe(outer_hub, fn(hub) { event_hub.notify(hub, 1) })

  event_hub.notify(outer_hub, inner_hub)

  expect(a, 1)

  Nil
}

pub fn filtered_with_function_test() {
  use a <- mut(0)
  use b <- mut(0)

  let set_a = fn(value) { set(a, value) }
  let set_b = fn(value) { set(b, value) }

  use hub <- filtered.new()

  let unsubscribe_a = filtered.subscribe(hub, [set_a], set_a)
  let unsubscribe_b = filtered.subscribe(hub, [set_b], set_b)

  expect(a, 0)
  expect(b, 0)

  filtered.notify(hub, [set_a], 1)

  expect(a, 1)
  expect(b, 0)

  filtered.notify(hub, [set_b], 2)

  expect(a, 1)
  expect(b, 2)

  filtered.notify(hub, [set_a, set_b], 3)

  expect(a, 3)
  expect(b, 3)

  unsubscribe_a()

  filtered.notify(hub, [set_a, set_b], 4)

  expect(a, 3)
  expect(b, 4)

  unsubscribe_b()

  filtered.notify(hub, [set_b], 5)

  expect(a, 3)
  expect(b, 4)

  Nil
}

pub fn filtered_with_hub_test() {
  use a <- mut(0)
  use b <- mut(0)

  let set_a = fn(value) { set(a, value) }
  let set_b = fn(value) { set(b, value) }

  use hub <- filtered.new()
  use hub_a <- filtered.new()
  use hub_b <- filtered.new()

  filtered.subscribe(hub_a, ["a"], fn(_) { Nil })
  filtered.subscribe(hub_b, ["b"], fn(_) { Nil })

  let unsubscribe_a = filtered.subscribe(hub, [hub_a], set_a)
  let unsubscribe_b = filtered.subscribe(hub, [hub_b], set_b)

  expect(a, 0)
  expect(b, 0)

  filtered.notify(hub, [hub_a], 1)

  expect(a, 1)
  expect(b, 0)

  filtered.notify(hub, [hub_b], 2)

  expect(a, 1)
  expect(b, 2)

  filtered.notify(hub, [hub_a, hub_b], 3)

  expect(a, 3)
  expect(b, 3)

  unsubscribe_a()

  filtered.notify(hub, [hub_a, hub_b], 4)

  expect(a, 3)
  expect(b, 4)

  unsubscribe_b()

  filtered.notify(hub, [hub_b], 5)

  expect(a, 3)
  expect(b, 4)

  Nil
}

pub fn filtered_with_result_test() {
  use a <- mut(0)
  use b <- mut(0)

  let set_a = fn(value) { set(a, value) }
  let set_b = fn(value) { set(b, value) }

  use hub <- filtered.new()

  let unsubscribe_a = filtered.subscribe(hub, [Ok(Nil)], set_a)
  let unsubscribe_b = filtered.subscribe(hub, [Error(Nil)], set_b)

  expect(a, 0)
  expect(b, 0)

  filtered.notify(hub, [Ok(Nil)], 1)

  expect(a, 1)
  expect(b, 0)

  filtered.notify(hub, [Error(Nil)], 2)

  expect(a, 1)
  expect(b, 2)

  filtered.notify(hub, [Ok(Nil), Error(Nil)], 3)

  expect(a, 3)
  expect(b, 3)

  unsubscribe_a()

  filtered.notify(hub, [Ok(Nil), Error(Nil)], 4)

  expect(a, 3)
  expect(b, 4)

  unsubscribe_b()

  filtered.notify(hub, [Error(Nil)], 5)

  expect(a, 3)
  expect(b, 4)

  Nil
}

pub fn filtered3_test() {
  use a <- mut(0)
  use b <- mut(0)

  use hub <- filtered.new3()

  let unsubscribe_a =
    filtered.subscribe3(hub, [1], ["a", "*"], [Ok(Nil)], fn(value) {
      set(a, value)
    })

  let unsubscribe_b =
    filtered.subscribe3(hub, [2], ["b", "*"], [Ok(Nil)], fn(value) {
      set(b, value)
    })

  filtered.notify3(hub, [1], ["a", "b"], [Ok(Nil)], 1)

  expect(a, 1)
  expect(b, 0)

  filtered.notify3(hub, [2], ["a", "b"], [Ok(Nil)], 2)

  expect(a, 1)
  expect(b, 2)

  filtered.notify3(hub, [1, 2], ["*"], [Ok(Nil)], 3)

  expect(a, 3)
  expect(b, 3)

  filtered.notify3(hub, [1, 2], ["a", "b", "c", "*"], [Ok(Nil)], 4)

  expect(a, 4)
  expect(b, 4)

  filtered.notify3(hub, [1], ["a", "b", "c", "*"], [Ok(Nil)], 5)

  expect(a, 5)
  expect(b, 4)

  filtered.notify3(hub, [2], ["a", "b", "c", "*"], [Ok(Nil)], 6)

  expect(a, 5)
  expect(b, 6)

  unsubscribe_a()

  filtered.notify3(hub, [1, 2], ["*"], [Error(Nil)], 7)

  expect(a, 5)
  expect(b, 6)

  filtered.notify3(hub, [1, 2], ["*"], [Ok(Nil)], 8)

  expect(a, 5)
  expect(b, 8)

  unsubscribe_b()

  Nil
}

pub fn filtered4_test() {
  use a <- mut(0)
  use b <- mut(0)
  use c <- mut(0)

  use hub <- filtered.new4()

  expect(a, 0)
  expect(b, 0)
  expect(c, 0)

  filtered.notify4(hub, ["x"], ["y"], ["z"], ["a"], 1)

  expect(a, 0)
  expect(b, 0)
  expect(c, 0)

  let unsubscribe_a =
    filtered.subscribe4(hub, ["x"], ["y"], ["z"], ["a", "*", "ab"], fn(value) {
      set(a, value)
    })

  expect(a, 0)
  expect(b, 0)
  expect(c, 0)

  filtered.notify4(hub, ["x"], ["y"], ["z"], ["a", "c"], 2)

  expect(a, 2)
  expect(b, 0)
  expect(c, 0)

  let unsubscribe_b =
    filtered.subscribe4(hub, ["x"], ["y"], ["z"], ["b", "*", "ab"], fn(value) {
      set(b, value)
    })

  expect(a, 2)
  expect(b, 0)
  expect(c, 0)

  filtered.notify4(hub, ["x"], ["y"], ["z"], ["*"], 3)

  expect(a, 3)
  expect(b, 3)
  expect(c, 0)

  let unsubscribe_c =
    filtered.subscribe4(hub, ["x"], ["y"], ["z"], ["c", "*"], fn(value) {
      set(c, value)
    })

  expect(a, 3)
  expect(b, 3)
  expect(c, 0)

  filtered.notify4(hub, ["x"], ["y"], ["z"], ["ab", "a"], 4)

  expect(a, 4)
  expect(b, 4)
  expect(c, 0)

  filtered.notify4(hub, ["x"], ["y"], ["z"], ["a", "c"], 5)

  expect(a, 5)
  expect(b, 4)
  expect(c, 5)

  filtered.notify4(hub, ["x"], ["y"], ["z"], ["c", "d"], 6)

  expect(a, 5)
  expect(b, 4)
  expect(c, 6)

  filtered.notify4(hub, ["x"], ["y"], ["z"], ["a"], 7)

  expect(a, 7)
  expect(b, 4)
  expect(c, 6)

  filtered.notify4(hub, ["x"], ["y"], ["z"], [], 8)

  expect(a, 7)
  expect(b, 4)
  expect(c, 6)

  filtered.notify4(hub, ["x"], ["y"], ["z"], ["*"], 9)

  expect(a, 9)
  expect(b, 9)
  expect(c, 9)

  unsubscribe_a()

  expect(a, 9)
  expect(b, 9)
  expect(c, 9)

  filtered.notify4(hub, ["x"], ["y"], ["z"], ["ab"], 10)

  expect(a, 9)
  expect(b, 10)
  expect(c, 9)

  unsubscribe_b()

  expect(a, 9)
  expect(b, 10)
  expect(c, 9)

  filtered.notify4(hub, ["x"], ["y"], ["z"], ["ab"], 11)

  expect(a, 9)
  expect(b, 10)
  expect(c, 9)

  unsubscribe_c()

  expect(a, 9)
  expect(b, 10)
  expect(c, 9)

  filtered.notify4(hub, ["x"], ["y"], ["z"], ["a", "b", "c"], 11)

  expect(a, 9)
  expect(b, 10)
  expect(c, 9)

  Nil
}
