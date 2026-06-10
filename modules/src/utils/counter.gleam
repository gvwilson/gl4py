// mccole: counter_type
pub opaque type Counter {
  Counter(value: Int)
}

pub fn new() -> Counter {
  Counter(0)
}

pub fn increment(c: Counter) -> Counter {
  Counter(c.value + 1)
}

pub fn decrement(c: Counter) -> Counter {
  case c.value > 0 {
    True -> Counter(c.value - 1)
    False -> c
  }
}

pub fn value(c: Counter) -> Int {
  c.value
}
// mccole: /counter_type
