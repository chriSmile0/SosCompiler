# LVMC
## USAGE
```bash
make 				# Compile simplement le programme
make test_lex ARGS = {1,2,3}	# Execute une séries de tests pour la reconnaissance de tokens
make test_yacc ARGS = {1,2,3}	# Execute une séries de tests pour la génératon de code
bin/sos 			# Lance le programme et lit depuis l'entrée standard pour afficher la reconnaissance de tokens
bin/sos -g			# Lance le programme et lit depuis l'entrée standard pour afficher la génération de code
bin/sos -g --tos		# Affichage du code MIPS + table des symboles
bin/sos -g -o {fichier}		# Code MIPS écrit dans un fichier indiqué en ligne de commande
bin/sos --version		# Crédits
```
