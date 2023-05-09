(module
  (type (;0;) (func (param i32)))
  (type (;1;) (func))
  (type (;2;) (func (param i64) (result i64)))
  (import "wasi_snapshot_preview1" "proc_exit" (func $__wasi_exit (type 0)))
  (func $main (type 1)
    i64.const 10
    call $fib
    i32.wrap_i64
    call $__wasi_exit
    unreachable)
  (func $fib (type 2) (param $n i64) (result i64)
    local.get $n
    i64.const 2
    i64.lt_s
    if (result i64)  ;; label = @1
      local.get $n
    else
      local.get $n
      i64.const 2
      i64.sub
      call $fib
      local.get $n
      i64.const 1
      i64.sub
      call $fib
      i64.add
    end)
  (memory (;0;) 0)
  (export "_start" (func $main))
  (export "memory" (memory 0))
  (start $main))
