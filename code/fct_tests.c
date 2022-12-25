#include "../inc/fct_tests.h"
#include "tokens.h"

// level = s ou m ou d
int test_type(char *chemin_fichier_test, int attendu, int token_d, 
			int token_l, char *def_tok) {
	char* filename = chemin_fichier_test;
	yyin = fopen(filename,"r");
	if (yyin == NULL) 
		perror(filename);
	int t;
	t = yylex();
	int nbr_t = 0;

	while (t != 0) {
		nbr_t += (t >= token_d && (t <= token_l) ? 1 : 0);
		t = yylex();
	}
	fclose(yyin);
	fprintf(stderr, "  nombre de %s detectés(d) : %i (attendu : %i)\n", 
			def_tok,nbr_t, attendu);
	return (nbr_t == attendu) ? 0 : 1;
}


int test_ascii_s() {
	char *filename = "f_tests/s/ascii_s";
	yyin = fopen(filename, "r");
	if (yyin == NULL)
		perror(filename);
	int t;
	int rtn = 0;
	int attendu = 0;
	while ((t = yylex()) != 0) 
		if (t != CC && t != CHAR && t != ID && t != MOT) 
			rtn = 1;
	
	fclose(yyin);
	fprintf(stderr, "  nombre de carac non ascii detectés(d) : min %i (attendu : %i)\n", 
			rtn,attendu);
	return rtn;
}

int test_ascii_m_v2() {
	return test_type("f_tests/e_sos/exemple1",0,-1,-1,"carac non ascii");
}

int test_ascii_d_v2() {
	return test_type("f_tests/d/ascii_d",2,1,1,"carac non ascii");
}


int test_motsreserves_s_v2() {
	return test_type("f_tests/s/motsreserves_s",5,MR,MR,"mots reserves");
}

int test_motsreserves_m_v2() {
	return test_type("f_tests/e_sos/exemple1",39,MR,MR,"mots reserves");
}

int test_motsreserves_d_v2() {
	return test_type("f_tests/d/motsreserves_d",4,MR,MR,"mots reserves");
}

int test_chainescarac_s_v2() {
	return test_type("f_tests/s/chainescarac_s",3,CC,CC,"string");
}

int test_chainescarac_m_v2() {
	return test_type("f_tests/e_sos/exemple1",9,CC,CC,"string");
}

int test_chainescarac_d_v2() {
	return test_type("f_tests/d/chainescarac_d",8,CC,CC,"string");
}

int test_commentaires_s_v2() {
	return test_type("f_tests/s/com_s",3,COM,COM,"com");
}

int test_commentaires_m_v2() {
	return test_type("f_tests/e_sos/exemple1",3,COM,COM,"com");
}

int test_commentaires_d_v2() {
	return test_type("f_tests/d/com_d",4,COM,COM,"com");
}

int test_nombres_s_v2() {
	return test_type("f_tests/s/nb_s",1,NB,NB,"nombres");
}

int test_nombres_m_v2() {
	return test_type("f_tests/e_sos/exemple1",15,NB,NB,"nombres");
}

int test_nombres_d_v2() {
	return test_type("f_tests/d/nb_d",2,NB,NB,"nombres");
}

int test_id_s_v2() {
	return test_type("f_tests/s/id_s",1,ID,ID,"id"); // 1
}

int test_id_m_v2() {
	return test_type("f_tests/e_sos/exemple1",29,ID,ID,"id");
}

int test_id_d_v2() {
	return test_type("f_tests/d/id_d",3,ID,ID,"id");
}

int test_mot_s_v2() {
	return test_type("f_tests/s/mot_s",0,MOT,MOT,"mot");
}

int test_mot_m_v2() {
	return test_type("f_tests/e_sos/exemple1",0,MOT,MOT,"mot");
}

int test_mot_d_v2() {
	return test_type("f_tests/d/mot_d",7,MOT,MOT,"mot");
}

int test_oper_s_v2() {
	return test_type("f_tests/s/oper_s",0,GT,EQ,"Ope relationnels");
}

int test_oper_m_v2() {
	return test_type("f_tests/e_sos/exemple1",3,GT,EQ,"Ope relationnels");
}

int test_oper_d_v2() {
	return test_type("f_tests/d/oper_d",0,GT,EQ,"Ope relationnels");
}

int test_opel_s_v2() {
	return test_type("f_tests/s/opel_s",0,ET,CCNV,"Ope logique");
}

int test_opel_m_v2() {
	return test_type("f_tests/e_sos/exemple1",0,ET,CCNV,"Ope logique");
}

int test_opel_d_v2() {
	return test_type("f_tests/d/opel_d",0,ET,CCNV,"Ope logique");
}

int test_operande(char* chemin_fichier_test, int attendu) {
	char* filename = chemin_fichier_test;
	yyin = fopen(filename,"r");
	if (yyin == NULL) 
		perror(filename);
	yyout = fopen("exit_mips/exit_mips.s","w+");

	if (yyout == NULL) 
		perror("exit_mips.s doit exister");
		
	int r = yyparse();
	printf("r : %d\n",r);
	return r;
}

int test_operande_s() {
	return test_operande("f_tests/s/operande_s", 0);
}

int test_operande_m() {
	return test_operande("f_tests/e_sos/exemple1", 0);
}

int test_operande_d() {
	return test_operande("f_tests/d/operande_d", 1); //nb de concat a faire
}

