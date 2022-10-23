#include "../inc/fct_tests.h"
#include <unistd.h>

int test_motsreserves_s() {
	char *filename = "fichiers_tests/motsreserves_s.sh";
	yyin=fopen(filename,"r"); //entrer du fichier 
	if(yyin==NULL)
		perror(filename);
	
	int t;
	t = yylex();
	int result_t = 0;
	int nb_mots_res_detectables = 15;
	while(t != 0) {
		printf("t : %d\n",t);
		result_t += t;
		t = yylex();
	}
    fclose(yyin); //fermeture de l'entrée*/
	return (result_t == nb_mots_res_detectables) ? 0 : 1;
}

int test_motsreserves_m() {
	return 0;
}

int test_motsreserves_d() {
	return 0;
}