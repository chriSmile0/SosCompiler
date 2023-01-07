	.data
id:     .asciiz "mot"
str1:   .asciiz "egal"
str2:   .asciiz "egal"
	.text

print_str_by_carac:
    la $t0 , id
    loop:
    lb $t1 , ($t0)
    beqz $t1, exit_fnc 
    la $a0, ($t1)
    li $v0 , 11 
    syscall 
    addi $t0, $t0 , 1
    addi $t2 , $t2 , 1
    j loop
exit_fnc:
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

print_int:
    li $v0 1
    syscall 
    jr $ra

compare_str:
    la $t0 , str1
    la $t1 , str2
    loop_cmp:
    lb $t2 , ($t0)
    lb $t3 , ($t1)
    beqz $t2 , end_cmp
    move $t4 , $t2
    move $t5 , $t3
    addi $t4, $t4, -48
    addi $t5, $t5, -48
    bne $t4,$t5 not_equal 
    li $v0 11
    move $a0,$t2
    syscall 
    addi $t0, $t0 , 1
    addi $t1, $t1 , 1
    j loop_cmp
not_equal:
    jr $ra 
end_cmp:
    jr $ra

main:

jal print_str_by_carac
la $a0 , id 
jal strlen
jal print_int


jal compare_str

jal Exit

Exit:
li $v0, 10
syscall
jr $ra

