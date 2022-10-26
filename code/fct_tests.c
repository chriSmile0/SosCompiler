#include "../inc/fct_tests.h"
#include "tokens.h"

int test_motsreserves_s() {
	char *filename = "../fichiers_tests/motsreserves_s";
	yyin=fopen(filename,"r"); 
	if(yyin==NULL)
		perror(filename);
	
	int t;
	t = yylex();
	int result_t = 0;
	int nb_mots_res_detectables = 5;
	nb_mots_res_detectables *= MR; // on multiplie par la valeur du token 
	while(t != 0) {
		result_t += t;
		t = yylex();
	}
    fclose(yyin); //fermeture de l'entrée*/
	return (result_t == nb_mots_res_detectables) ? 0 : 1;
}

int test_motsreserves_m() {
	char *filename = "../exemple_sos/exemple1";
	yyin=fopen(filename,"r");
	if(yyin==NULL)
		perror(filename);
	
	int t;
	t = yylex();
	int result_t = 0;
	int nb_mots_res_detectables = 33;
	nb_mots_res_detectables *= MR;
	while(t != 0) {
		result_t += t;
		t = yylex();
	}
    fclose(yyin); //fermeture de l'entrée*/
	return (result_t == nb_mots_res_detectables) ? 0 : 1;
}

int test_motsreserves_d() {
	char *filename = "../fichiers_tests/motsreserves_d";
	yyin=fopen(filename,"r");
	if(yyin==NULL)
		perror(filename);
	
	int t;
	t = yylex();
	int result_t = 0;
	int nb_mots_res_detectables = 5;
	nb_mots_res_detectables *= MR;
	while(t != 0) {
		result_t += t;
		t = yylex();
	}
    fclose(yyin); //fermeture de l'entrée*/
	return (result_t == nb_mots_res_detectables) ? 0 : 1;
}
