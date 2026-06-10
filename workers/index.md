# Supervised Worker Pool

<div class="syllabus" markdown="1">

-   A worker pool distributes jobs across multiple workers;
    the pool tracks which workers are alive and which have crashed.
-   The "let it crash" philosophy: workers do not defend against bad input;
    they crash, and a supervisor restarts them.
-   This demo models crash and restart as state transitions
    rather than actual OTP processes, to focus on the logic.
-   On the BEAM, `gleam_otp/supervisor` manages the restart cycle automatically;
    `one_for_one` restarts only the crashed child.
-   Process isolation means a crashed worker cannot corrupt the state
    of other workers or the dispatcher.

</div>

## The Worker Pool Pattern

-   A worker pool is a fixed set of processes, each waiting for a job
-   A dispatcher sends jobs to workers in round-robin order (or some other strategy)
-   If a worker crashes, a supervisor restarts it; the other workers continue
-   This pattern appears in web servers, database connection pools, image processors,
    and anything with a bounded set of concurrent tasks

## Types

[%inc src/pool_demo.gleam mark=pool_type %]

-   `Job` wraps a single integer to process (a stand-in for real work)
-   `Worker` has an ID and an `alive` flag
-   `Pool` holds the worker list and the results collected so far
-   In a real OTP application, `Worker` would be an actor process,
    and `alive` would be replaced by monitoring the process with `process.monitor`

## Dispatching Jobs

[%inc src/pool_demo.gleam mark=dispatch_fn %]

-   `list.length(pool.results) % list.length(pool.workers)`
    distributes jobs evenly across workers by index
-   The result is `n * 2` (a trivial transformation representing work)
-   A real dispatcher would call the worker actor with `process.send`
    and collect replies on a `Subject`

## Crash and Restart

[%inc src/pool_demo.gleam mark=crash_restart_fn %]

-   `crash_worker` simulates a crash by setting `alive: False`
-   `restart_worker` sets `alive: True` again and logs the restart
-   In a real OTP supervisor, `crash_worker` would be `process.exit(pid, abnormal)`
    and `restart_worker` would be the supervisor's automatic response

## The "Let It Crash" Philosophy

-   In traditional programming, every function defends against bad input:

[%inc snippets/let_it_crash.py mark=python_defense %]

-   In BEAM Erlang and Gleam, the idiom is to let the process crash
    and rely on the supervisor to restart it:

[%inc snippets/let_it_crash.gleam mark=gleam_crash %]

-   BEAM processes are isolated: a crash does not affect other processes
-   The supervisor detects the crash via a process monitor and calls the start function again
-   The worker starts fresh with clean state; the total downtime per worker is microseconds
-   In Python, a crashed thread can leave shared data in a corrupt state
-   On the BEAM, a crashed process leaves nothing behind:
    its memory is freed and its mailbox is discarded

## OTP Supervisors in Practice

[%inc snippets/otp_supervisor.gleam mark=supervisor_example %]

-   `supervisor.OneForOne` restarts only the crashed child
-   `supervisor.OneForAll` restarts all children when any one crashes
    (useful when workers share state)
-   `supervisor.RestForOne` restarts the crashed child and all children defined after it

## Broadcasting to Subscribers

-   A worker pool handles jobs in isolation,
    but some actors must deliver results to multiple listeners simultaneously
-   The pattern: the actor holds a list of `Subject` values, one per subscriber;
    on each event it sends to all of them

[%inc snippets/broadcast.gleam mark=broadcast_types %]

[%inc snippets/broadcast.gleam mark=broadcast_handle %]

-   `process.send` is non-blocking;
    the actor delivers to each subscriber's mailbox and moves on
    without waiting for acknowledgement
-   The BEAM scheduler ensures fairness between processes without explicit `yield` calls
-   Subscribers that crash are removed from the list via process monitoring:
    `process.monitor` sends a `Down` message when a monitored process exits

## Capping Stateful History

-   Actors that accumulate history (message logs, event queues) must bound their state
    or memory grows without limit
-   A simple cap: prepend to the list, then trim if over the limit:

[%inc src/pool_demo.gleam mark=append_capped_fn %]

-   `list.take(updated, limit)` keeps only the most recent `limit` entries
-   Apply the same pattern to any actor state that grows monotonically:
    log buffers, recent-event queues, audit trails

## Testing

[%inc test/workers_test.gleam mark=tests %]

-   `dispatch_test` confirms jobs are processed and results doubled
-   `crash_test` verifies that `crash_worker` sets the target worker's `alive` flag to `False`
-   `restart_test` verifies that `restart_worker` sets it back to `True`

## Check Understanding

<details markdown="1">
<summary markdown="1">How does the BEAM handle thousands of concurrent connections?</summary>

Each connection becomes a BEAM process.
BEAM processes are lightweight:
the default stack is only a few hundred bytes,
and millions can coexist on a single machine.
The scheduler runs processes in round-robin on each CPU core;
no explicit thread management is needed.
If one connection's process crashes (for example, due to a malformed message),
only that connection is affected; all others continue.
This is why Erlang and other BEAM-based languages are popular for chat servers,
phone systems,
and other high-connection workloads.

</details>

<details markdown="1">
<summary markdown="1">Why is `one_for_all` a separate strategy?</summary>

Consider a pool where all workers share access to a database connection.
If one worker crashes, the connection might be in an indeterminate state
that would cause the other workers to also fail.
`one_for_all` restarts all children when any one crashes,
ensuring they all start fresh together.
`one_for_one` is correct when workers are fully independent,
which is the common case for stateless request handlers.

</details>

## Exercises

<div class="exercise" markdown="1">

### One-for-all strategy (10 minutes)

Explain what would change if `dispatch_jobs` were replaced
by an OTP supervisor using `OneForAll` instead of `OneForOne`.
Which scenario would benefit from `OneForAll`?
Add a second test that simulates crashing one worker and assert the
pool remains operational.

</div>

<div class="exercise" markdown="1">

### Least-busy dispatcher (20 minutes)

Track each worker's current job count in `Worker`.
Change `dispatch_jobs` to assign each job to the worker with the
fewest active jobs rather than round-robin.
Write a test confirming that an uneven job distribution assigns the
second job to the idle worker.

</div>

<div class="exercise" markdown="1">

### Restart counter (15 minutes)

Add a `restart_count: Int` field to `Worker`.
Increment it in `restart_worker`.
Write a function `over_limit(pool: Pool, limit: Int) -> List(Int)`
that returns the IDs of workers whose restart count exceeds `limit`.
Add tests.

</div>

<div class="exercise" markdown="1">

### Skip crashed workers (10 minutes)

Modify `dispatch_jobs` to skip workers with `alive: False`.
Write a test where one of three workers is crashed and confirm jobs are
distributed only to the two alive workers.

</div>
