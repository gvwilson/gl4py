import gleam/int
import gleam/list
import gleeunit
import gleeunit/should
import pool_demo.{Pool, Process, Worker, crash_worker, dispatch_jobs, restart_worker}

pub fn main() {
  gleeunit.main()
}

// mccole: tests
pub fn dispatch_test() {
  let workers = [Worker(0, True), Worker(1, True)]
  let pool = dispatch_jobs(workers, [Process(5), Process(3)])
  list.sort(pool.results, int.compare)
  |> should.equal([6, 10])
}

pub fn crash_test() {
  let workers = [Worker(0, True), Worker(1, True)]
  let pool = Pool(workers, [])
  let crashed = crash_worker(pool, 1)
  list.find(crashed.workers, fn(w) { w.id == 1 })
  |> should.be_ok
  |> fn(w) { w.alive }
  |> should.be_false()
}

pub fn restart_test() {
  let workers = [Worker(0, True), Worker(1, False)]
  let pool = Pool(workers, [])
  let restarted = restart_worker(pool, 1)
  list.find(restarted.workers, fn(w) { w.id == 1 })
  |> should.be_ok
  |> fn(w) { w.alive }
  |> should.be_true()
}
// mccole: /tests
