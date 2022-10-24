#include "../inc/code_proj.tab.h"
#include "../inc/fct_tests.h"
#include <stdio.h>
#include <stdlib.h>


/**
 * @brief Suite de fonctions de type_*_s()
 * 		
 * 
 * @param[:]
 * @return un entier qui est l'incrément de toutes les fonctions tests
*/

int test_simple() {
	printf("test simple\n");
	int tests = 0;
	tests += test_motsreserves_s();
	/*
		Insertion du code du test simple
		Exemple de la structure de la fonction : 
		int incr = 0;
			incr+=test_nombres_s();
			incr+=test_chaines_s();
		return incr;
	*/
	return tests;
}

/**
 * @brief
 * @param[:]
 * @return 
*/


int test_median() {
	printf("test median \n");
	int tests = 0;
	tests += test_motsreserves_m();
	return tests;
}


/**
 * @brief 
 * @param[:]
 * @return 
*/

int test_difficile() {
	printf("test difficile \n");
	int tests = 0;
	tests += test_motsreserves_d();
	return tests;
}

int main(int argc, char *argv[]) {
	printf("test\n");

	if(argc != 2) {
		fprintf(stderr,"format : %s {1,2,3}\n",argv[0]);
		return 1;
	}
	int (*test_F[3])() = {test_simple,test_median,test_difficile};

	int niveau_test = atoi(argv[1]);
	printf("Test de niveau de rang : %d\n",niveau_test);
	int retour = 0;
	for(int i = 0 ; i < niveau_test ; i++)
		printf("test %d/%d >>> %s\n",i+1,niveau_test,
			(((retour = test_F[i]())) ? "\x1B[31m" "ECHOUE" "\x1B[37m"
				: "\x1B[32m" "VALIDE" "\x1B[37m" ));

	return retour;
}