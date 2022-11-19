#include "../inc/fct_tests.h"
#include "tokens.h"

int test_motsreserves_s() {
	char *filename = "fichiers_tests/motsreserves_s";
	yyin=fopen(filename,"r"); 
	if (yyin==NULL)
		perror(filename);
	int t;
	t = yylex();
	int result_t = 0;
	int nb_mots_res_detectables = 5;
	nb_mots_res_detectables *= MR; // on multiplie par la valeur du token 
	while (t != 0) {
		result_t += (t == MR ? MR : 0);
		t = yylex();
	}
    fclose(yyin); //fermeture de l'entrée*/
	return (result_t == nb_mots_res_detectables) ? 0 : 1;
}

int test_motsreserves_m() {
	char *filename = "exemple_sos/exemple1";
	yyin=fopen(filename,"r");
	if (yyin==NULL)
		perror(filename);
	int t;
	t = yylex();
	int result_t = 0;
	int nb_mots_res_detectables = 33;
	nb_mots_res_detectables *= MR;
	while (t != 0) {
		result_t += (t == MR ? MR : 0);
		t = yylex();
	}
    fclose(yyin); //fermeture de l'entrée*/
	return (result_t == nb_mots_res_detectables) ? 0 : 1;
}

int test_motsreserves_d() {
	char *filename = "fichiers_tests/motsreserves_d";
	yyin=fopen(filename,"r");
	if (yyin==NULL)
		perror(filename);
	int t;
	t = yylex();
	int result_t = 0;
	int nb_mots_res_detectables = 5;
	nb_mots_res_detectables *= MR;
	while (t != 0) {
		result_t += (t == MR ? MR : 0);
		t = yylex();
	}
    fclose(yyin); //fermeture de l'entrée*/
	return (result_t == nb_mots_res_detectables) ? 0 : 1;
}


int test_chainescarac_s() {
	char *filename = "fichiers_tests/chainescarac_s";
	yyin = fopen(filename, "r");
	if (yyin == NULL)
		perror(filename);
	int t;
	int result_t = 0;
	//3 chaines dans le fichier chainescarac_s
	int res_att = 3;
	while ((t = yylex()) != 0) 
		result_t += (t == CC ? 1 : 0);
	
	fprintf(stderr, "nombre de string detectés(s): %i (attendu : %i)\n", 
			result_t, res_att);
	fclose(yyin);
	return (result_t == res_att ? 0 : 1);

}


int test_chainescarac_m() {
	char *filename = "exemple_sos/exemple1";
	yyin = fopen(filename, "r");
	if (yyin == NULL)
		perror(filename);
	int t;
	int result_t = 0;
	//9 chaines dans le fichier exemple1
	int res_att = 9;
	while ((t = yylex()) != 0) 
		result_t += (t == CC ? 1 : 0);
	fprintf(stderr, "nombre de string detectés(m): %i (attendu : %i)\n", 
			result_t, res_att);
	fclose(yyin);
	return (result_t == res_att ? 0 : 1);
}

int test_chainescarac_d() {
	char *filename = "fichiers_tests/chainescarac_d";
	yyin = fopen(filename, "r");
	if (yyin == NULL)
		perror(filename);
	int t;
	int result_t = 0;
	//8 chaines dans le fichier chainescarac_d
	int res_att = 8;
	while ((t = yylex()) != 0) 
		result_t += (t == CC ? 1 : 0);
	fprintf(stderr, "nombre de string detectés(d) : %i (attendu : %i)\n", 
			result_t, res_att);
	fclose(yyin);
	return (result_t == res_att ? 0 : 1);
}

int test_ascii_s() {
	char *filename = "fichiers_tests/ascii_s";
	yyin = fopen(filename, "r");
	if (yyin == NULL)
		perror(filename);
	int t;
	int rtn = 0;
	while ((t = yylex()) != 0) {
		if (t != CC && t != CHAR) {
			rtn = 1;
		}
	}
	fclose(yyin);
	return rtn;
}

int test_ascii_m() {
	char *filename = "exemple_sos/exemple1";
	yyin = fopen(filename, "r");
	if (yyin == NULL)
		perror(filename);
	int t;
	int rtn = 0;
	while ((t = yylex()) != 0) {
		if (t == -1) {
			rtn = 1;
		}
	}
	fclose(yyin);
	return rtn;
}

int test_ascii_d() {
	char *filename = "fichiers_tests/ascii_d";
	yyin = fopen(filename, "r");
	if (yyin == NULL)
		perror(filename);
	int t;
	int rtn;
	while ((t = yylex()) != 0) {
		if (t == 1) {
			rtn = 0;
		}
	}
	fclose(yyin);
	return rtn;
}

int test_commentaires(char* chemin_fichier_test, int attendu) {
	char* filename = chemin_fichier_test;
	yyin = fopen(filename,"r");
	if (yyin == NULL) 
		perror(filename);
	int t;
	t = yylex();
	int nbr_comm = 0;

	while (t != 0) {
		nbr_comm += (t == COM ? 1 : 0);
		t = yylex();
	}
	fclose(yyin);
	return (nbr_comm == attendu) ? 0 : 1;
}

int test_commentaires_s() {
	return test_commentaires("fichiers_tests/facile.sh", 3);
}

int test_commentaires_m() {
	return test_commentaires("fichiers_tests/moyen.sh", 3);
}

int test_commentaires_d() {
	return test_commentaires("fichiers_tests/difficile.sh", 4);
}

int test_nombres(char* chemin_fichier_test, int attendu) {
	char* filename = chemin_fichier_test;
	yyin = fopen(filename,"r");
	if (yyin == NULL) 
		perror(filename);
	int t;
	t = yylex();
	int nbr_nb = 0;

	while (t != 0) {
		nbr_nb += (t == NB ? 1 : 0);
		t = yylex();
	}
	fclose(yyin);
	return (nbr_nb == attendu) ? 0 : 1;
}

int test_nombres_s() {
	return test_nombres("fichiers_tests/facile_nb",1);
}

int test_nombres_m() {
	return test_nombres("exemple_sos/exemple1",15);
}

int test_nombres_d() {
	return test_nombres("fichiers_tests/difficile_nb",2);
}
