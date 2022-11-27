.data
	buffer: .space 4000
.text
.globl _start
__start:
wr
it:
	li $v0 10
	syscall
