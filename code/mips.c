#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <string.h>
#include <unistd.h>
//Fonction initialisant la traduction du code SOS en assembleur MIPS.
//Elle initialise les deux fichiers servant à la génération du code :
//- mips[0] : fichier des données (.data);
//- mips[1] : fichier des fonctions (.text).
FILE** init_mips(int trad){
	//On ouvre les fichiers
	if (trad) {
		static FILE* mips[2]; 
		mips[0] = fopen("exit_mips/mips_d", "w+");
		mips[1] = fopen("exit_mips/mips_t", "w+");
		if (mips[0] == NULL || mips[1] == NULL){
				fprintf(stderr, "Problème fopen");
				exit(1);
		}
		//On écrit le début de chacun des fichiers
		fprintf(mips[0], ".data\n");
		fprintf(mips[1], ".text\n");	
		return mips;
	}
	return NULL;
}

//Procédure terminant la traduction du code SOS en assembleur MIPS.
//mips : fichiers de la traduction MIPS 
void end_mips(FILE** mips, int trad){
	if (trad){
		//On ajoute le contenu du fichier texte au fichier données
		system("cat exit_mips/mips_t >> exit_mips/mips_d");
		fclose(mips[0]);
		fclose(mips[1]);
	}
}



