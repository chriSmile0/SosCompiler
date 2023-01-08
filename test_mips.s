        .data
_0:     .asciiz "b"
_1:     .asciiz "a"
_2:     .asciiz "c"
_3:     .asciiz "d"
        .text
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
        li $t0 ,0
        move $a0 $t0
        jr $ra
end_cmp:
        li $t0 , 1
        move $a0 $t0
        jr $ra

proc_and:
        and $t0,$a0,$a1
        move $a0 $t0
        jr $ra

print_int:
    li $v0 1
    syscall 
    jr $ra

main:

la $a0 _0
jal strlen
move $t1 $a0
la $a0 _1
jal strlen
move $t2 $a0
la $a0 _0
la $a1 _1
move $a2 $t1
move $a3 $t2
jal compare_str
move $t1 $a0
la $a0 _2
jal strlen
move $t2 $a0
la $a0 _3
jal strlen
move $t3 $a0
la $a0 _2
la $a1 _3
move $a2 $t2
move $a3 $t3
jal compare_str
move $t2 $a0
move $a1 , $t2
move $a0 , $t1
jal proc_and
jal print_int 
li $v0 10
syscall