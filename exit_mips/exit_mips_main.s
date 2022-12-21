	la $a0, a0
	jal Affichage_Str 
	la $a0, a1
	jal Affichage_Str 
	la $a0, nb
	li $a1, 50
	jal Lecture_Str 

	jal Exit
