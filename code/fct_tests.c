#include "../inc/fct_tests.h"
#include "tokens.h"

// level = s ou m ou d
int test_type(char *chemin_fichier_test, int attendu, int token, char *def_tok) {
	char* filename = chemin_fichier_test;
	yyin = fopen(filename,"r");
	if (yyin == NULL) 
		perror(filename);
	int t;
	t = yylex();
	int nbr_t = 0;

	while (t != 0) {
		nbr_t += (t == token ? 1 : 0);
		t = yylex();
	}
	fclose(yyin);
	fprintf(stderr, "nombre de %s detectés(d) : %i (attendu : %i)\n", 
			def_tok,nbr_t, attendu);
	return (nbr_t == attendu) ? 0 : 1;
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


int test_motsreserves_s_v2() {
	return test_type("fichiers_tests/motsreserves_s",5,MR,"mots reserves");
}

int test_motsreserves_m_v2() {
	return test_type("exemple_sos/exemple1",39,MR,"mots reserves");
}

int test_motsreserves_d_v2() {
	return test_type("fichiers_tests/motsreserves_d",4,MR,"mots reserves");
}

int test_chainescarac_s_v2() {
	return test_type("fichiers_tests/chainescarac_s",3,CC,"string");
}

int test_chainescarac_m_v2() {
	return test_type("exemple_sos/exemple1",9,CC,"string");
}

int test_chainescarac_d_v2() {
	return test_type("fichiers_tests/chainescarac_d",8,CC,"string");
}

int test_commentaires_s_v2() {
	return test_type("fichiers_tests/facile.sh",3,COM,"com");
}

int test_commentaires_m_v2() {
	return test_type("fichiers_tests/moyen.sh",3,COM,"com");
}

int test_commentaires_d_v2() {
	return test_type("fichiers_tests/difficile.sh",4,COM,"com");
}

int test_nombres_s_v2() {
	return test_type("fichiers_tests/facile_nb",1,NB,"nombres");
}

int test_nombres_m_v2() {
	return test_type("exemple_sos/exemple1",15,NB,"nombres");
}

int test_nombres_d_v2() {
	return test_type("fichiers_tests/difficile_nb",2,NB,"nombres");
}

int test_id_s_v2() {
	return test_type("fichiers_tests/id_s",1,ID,"id"); // 1
}

int test_id_m_v2() {
	return test_type("exemple_sos/exemple1",32,ID,"id");
}

int test_id_d_v2() {
	return test_type("fichiers_tests/id_d",4,ID,"id");
}
