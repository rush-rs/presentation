0: (prelude)
    setmp 0
    call 1
1: (main)
    setmp 0
    push 10
    call 2
    exit
2: (fib)
    setmp 1
    svari *rel[0]
    push *rel[0]
    gvar
    push 2
    lt
    jmpfalse 10
    push *rel[0]
    gvar
    jmp 21
    push *rel[0]
    gvar
    push 2
    sub
    call 2
    push *rel[0]
    gvar
    push 1
    sub
    call 2
    add
    setmp -1
    ret
