0: (prelude)
	setmp 0
	call 1
1: (main)
	setmp 0
	push 2
	call 2
2: (foo)
	setmp 2
	svari *rel[0]
	push 3
	svari *rel[-1]
	push *rel[0]
	gvar
	push *rel[-1]
	gvar
	add
	exit
	setmp -2
	ret
