import gleam/int
import gleam/io
import gleam/list
import gleam/string

// mccole: pool_type
pub type Job {
  Process(Int)
}

pub type Worker {
  Worker(id: Int, alive: Bool)
}

pub type Pool {
  Pool(workers: List(Worker), results: List(Int))
}

// mccole: /pool_type

pub fn main() {
  io.println("starting worker pool simulation")
  io.println("---")

  let workers = [
    Worker(0, True),
    Worker(1, True),
    Worker(2, True),
  ]

  io.println(
    "initial pool: " <> int.to_string(list.length(workers)) <> " workers",
  )

  let pool = dispatch_jobs(workers, [Process(42), Process(99), Process(7)])
  io.println(string.inspect(pool))

  io.println("simulating worker crash...")
  let crashed = crash_worker(pool, 1)
  io.println(string.inspect(crashed))

  let restarted = restart_worker(crashed, 1)
  io.println("after restart:")
  io.println(string.inspect(restarted))
}

// mccole: dispatch_fn
pub fn dispatch_jobs(workers: List(Worker), jobs: List(Job)) -> Pool {
  let init = Pool(workers, [])

  list.fold(jobs, init, fn(pool, job) {
    case job {
      Process(n) -> {
        let worker_idx = list.length(pool.results) % list.length(pool.workers)
        io.println(
          "worker "
          <> int.to_string(worker_idx)
          <> " processing "
          <> int.to_string(n),
        )
        Pool(pool.workers, [n * 2, ..pool.results])
      }
    }
  })
}

// mccole: /dispatch_fn

// mccole: append_capped_fn
pub fn append_capped(history: List(a), item: a, limit: Int) -> List(a) {
  let updated = [item, ..history]
  case list.length(updated) > limit {
    True -> list.take(updated, limit)
    False -> updated
  }
}

// mccole: /append_capped_fn

// mccole: crash_restart_fn
pub fn crash_worker(pool: Pool, id: Int) -> Pool {
  let new_workers =
    list.map(pool.workers, fn(w) {
      case w.id == id {
        True -> Worker(w.id, False)
        False -> w
      }
    })
  Pool(new_workers, pool.results)
}

pub fn restart_worker(pool: Pool, id: Int) -> Pool {
  let new_workers =
    list.map(pool.workers, fn(w) {
      case w.id == id && !w.alive {
        True -> {
          io.println("worker " <> int.to_string(id) <> " restarted")
          Worker(w.id, True)
        }
        False -> w
      }
    })
  Pool(new_workers, pool.results)
}
// mccole: /crash_restart_fn
