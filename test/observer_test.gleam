import gleeunit
import gleeunit/should
import observer
import observer/reactive
import observer/stateful

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

  use hub <- observer.new()

  expect(a, 0)
  expect(b, 0)

  observer.notify(hub, 1)

  expect(a, 0)
  expect(b, 0)

  let unsubscribe_a = observer.subscribe(hub, fn(value) { set(a, value) })

  expect(a, 0)
  expect(b, 0)

  observer.notify(hub, 2)

  expect(a, 2)
  expect(b, 0)

  let unsubscribe_b = observer.subscribe(hub, fn(value) { set(b, value) })

  expect(a, 2)
  expect(b, 0)

  observer.notify(hub, 3)

  expect(a, 3)
  expect(b, 3)

  unsubscribe_a()

  expect(a, 3)
  expect(b, 3)

  observer.notify(hub, 4)

  expect(a, 3)
  expect(b, 4)

  unsubscribe_b()

  expect(a, 3)
  expect(b, 4)

  observer.notify(hub, 5)

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
