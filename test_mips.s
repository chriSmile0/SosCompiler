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

compare_strvdeux:
	li $t1 , 0
	la $v1 , ($a0)
	loop_cmp:
	lb $t2 , ($a0)
	lb $t3 , ($a1)
	beqz $t2 , end_cmpv
	beqz $t3 , end_cmpvf
	move $t4 , $t2
	move $t5 , $t3
	addi $t4, $t4, -48
	addi $t5, $t5, -48
	move $t6 , $a0
	bne $t4,$t5 not_equalv
	li $v0 11
	move $a0,$t2
	move $a0 , $t6
	addi $a0, $a0 , 1
	addi $a1, $a1 , 1
	j loop_cmp
not_equalv:
	li $t4 ,0
	beq $a2 ,2 true_little
	beq $a2 ,3 egal_little
	move $a0 $t4
	jr $ra
true_little:
	addi $a0 $zero 2
	jr $ra
egal_little:
	addi $a0 $zero 3
	jr $ra
not_equalvf:
	li $t4 ,0
	beq $a2 ,4 true_bigger
	beq $a2 ,5 egal_bigger
	move $a0 $t4
	jr $ra
true_bigger:
	addi $a0 $zero 4
	jr $ra
egal_bigger:
	addi $a0 $zero 5
	jr $ra
end_cmpv:
	li $t4 , 1
	move $t5 , $a2
	lb $t3 , ($a1)
	la $v1 ($a1)
	bnez $t3 not_equalv
	move $a0 , $t4
	jr $ra
end_cmpvf:
	li $t4 , 1
	move $t5 , $a2
	lb $t3 , ($a0)
	la $v1 ($a0)
	bnez $t3 not_equalvf
	move $a0 , $t4
	jr $ra
main:
la $a0 _0
jal proc_v_nv
li $v0 1
syscall 
la $a0 _1
jal proc_v_nv
addi $a0 , 1
li $v0 1
syscall 
la $a0 _2
jal proc_v_nv
addi $a0 , 1
li $v0 1
syscall 
la $a0 _3
la $a1 _4
li $a2 1
jal compare_strvdeux
li $v0 1
syscall
li $v0 10
syscall