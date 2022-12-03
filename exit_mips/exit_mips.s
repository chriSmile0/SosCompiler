.data

.text
main:

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
�
