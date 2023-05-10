pub struct Vm<const MEM_SIZE: usize> {
    stack: Vec<Value>,
    mem: [Option<Value>; MEM_SIZE],
    mem_ptr: isize,
    call_stack: Vec<CallFrame>,
}
