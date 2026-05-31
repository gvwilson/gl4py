import gleam/list
import gleam/otp/actor
import gleam/otp/supervisor

// mccole: supervisor_example
fn start_worker(id: Int) {
  actor.start(Nil, fn(job, _state) {
    case job {
      Process(n) -> {
        let assert n >= 0  // crashes on negative
        actor.Continue(Nil)
      }
    }
  })
}

pub fn main() {
  let children = list.map(list.range(0, 3), fn(id) {
    supervisor.worker(fn(_) { start_worker(id) })
  })
  supervisor.start_link(supervisor.OneForOne, children)
}
// mccole: /supervisor_example
