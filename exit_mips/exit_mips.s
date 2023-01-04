.data

	a0: .asciiz "ahah"

	a1: .asciiz "ohoh"

	nb: .space 5000
.text
main:
	la $a0, a0
	jal Affichage_Str 
	la $a0, a1
	jal Affichage_Str 
	la $a0, nb
	li $a1, 50
	jal Lecture_Str 

	jal Exit

Affichage_Int:
	li $v0 1
	syscall
	jr $ra

Affichage_Str:
	li $v0 4
	syscall
	jr $ra

Lecture_Int:
	li $v0 5
	syscall
	jr $ra

Lecture_Str:
	li $v0 8
	syscall
	jr $ra

Exit:
	li $v0, 10
	syscall
