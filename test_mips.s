	.data
_0:	.asciiz ""
_1:	.asciiz "abc"
_2:	.asciiz "bcdf"
_3:	.asciiz "b"
_4:	.asciiz "a"
	.text
proc_v_nv:
	lb $t0 ($a0)
	beqz $t0 pasvide
	addi $a0 , $zero , 0
	jr $ra
pasvide:
	addi $a0 , $zero , 1
	jr $ra
strlen:
	li $t2, 0
	loop_len:
	lb $t1 , 0($a0)
	beqz $t1, exit_fnclen
	addi $a0, $a0 , 1
	addi $t2 , $t2 , 1
	j loop_len
exit_fnclen:
	move $a0, $t2
	jr $ra

compare_str:
	move $t0 $a2
	move $t1 $a3
	beq $t0,$t1 not_equal
	li $t1 , 0
loop_cmp:
	lb $t2 , ($a0)
	lb $t3 , ($a1)
	li $t1 , 0
	beqz $t2 , end_cmp
	move $t4 , $t2
	move $t5 , $t3
	addi $t4, $t4, -48
	addi $t5, $t5, -48
	move $t6 , $a0
	bne $t4,$t5 not_equal
	li $v0 11
	move $a0,$t2
	syscall
	move $a0 , $t6
	addi $a0, $a0 , 1
	addi $a1, $a1 , 1
	j loop_cmp
not_equal:
	li $t0 ,1
	move $a0 $t0
	jr $ra
end_cmp:
	li $t0 , 0
	move $a0 $t0
	jr $ra

print_int:
    li $v0 1
    syscall 
    jr $ra


main:

la $a0 _0
jal proc_v_nv
jal print_int
la $a0 _1
jal proc_v_nv
jal print_int 
la $a0 _2
jal proc_v_nv
jal print_int

la $a0 _3
jal strlen
move $t1 $a0
la $a0 _4
jal strlen
move $t2 $a0
la $a0 _3
la $a1 _4
move $a2 $t1
move $a3 $t2
jal compare_str
li $v0 10
syscall

jal Exit

Exit:
li $v0, 10
syscall
jr $ra

