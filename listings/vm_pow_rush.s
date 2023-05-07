0: (prelude)
	setmp 0
	call 1
1: (main)
	setmp 0
	push 2
	push 4
	call 2
	exit
2: (pow)
	setmp 3
	svari *rel[0]
	svari *rel[-1]
	push *rel[0]
	gvar
	push 0
	eq
	jmpfalse 11
	push 1
	setmp -3
	ret
	push *rel[0]
	gvar
	push 0
	lt
	jmpfalse 19
	push 0
	setmp -3
	ret
	push 1
	svari *rel[-2]
	push *rel[0]
	gvar
	push 1
	gt
	jmpfalse 54
	push *rel[0]
	gvar
	push 1
	bitand
	push 1
	eq
	jmpfalse 40
	push *rel[-2]
	clone
	gvar
	push *rel[-1]
	gvar
	mul
	svar
	push *rel[0]
	clone
	gvar
	push 2
	div
	svar
	push *rel[-1]
	clone
	gvar
	push *rel[-1]
	gvar
	mul
	svar
	jmp 21
	push *rel[-2]
	gvar
	push *rel[-1]
	gvar
	mul
	setmp -3
	ret
