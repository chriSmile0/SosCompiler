        .data
didi:   .space  1
        .text
main:
la $t1, didi
addi $t1,$t1, 0
li $v0 5
syscall
move $t2, $v0
sw $t2, ($t1)
lw $a0, ($t1)
li $v0, 1
syscall
li $v0 10
syscall
