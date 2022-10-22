#include "../inc/code_proj.tab.h"
#include <stdio.h>
#include <stdlib.h>
extern int yylex();
extern void yyerror();

/**
 * @brief
 * @param[:]
 * @return
*/

int test_simple() {
	printf("test simple\n");
	/*int r;
	r = yyparse();*/

	/*
		Insertion du code du test simple
	*/

	return 0;
}

/**
 * @brief
 * @param[:]
 * @return 
*/


int test_median() {
	printf("test median \n");
	/*int r;
	r = yyparse();*/

	/*
		Insertion du code du test median
	*/

	return 1;
}


/**
 * @brief 
 * @param[:]
 * @return 
*/

int test_difficile() {
	printf("test difficile \n");
	/*int r;
	r = yyparse();*/

	/*
		Insertion du code du test difficile
	*/

	return 1;
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