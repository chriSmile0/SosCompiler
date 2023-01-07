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

int test_tds_s(void) {
	int ret = 0;
	init_tds();
	//var locale
	add_tds("id1", CH, 0, -1, -1, 0, "fonction_xy");
	//var globale
	add_tds("id2", CH, 0, -1, -1, 1, "");
	//tableau 3*3
	add_tds("id3", TAB, 0, 3, -1, 1, "");
	//fonction à 4 arguments
	add_tds("id4", FCT, 0, -1, 4, 1, "");
	int ind;
	if ((ind = find_entry("id2"))!= -1){
		update_entry(ind, MOT);
	} else {
		ret = 1;
	}
	if (get_type("id2") != MOT)
		ret = 1;
	if (strcmp(get_func("id1"), "fonction_xy") != 0)
		ret = 1;
	if (strcmp(get_func("id2"), "") != 0)
		ret = 1;
	if (get_dim("id3") != 3)
		ret = 1; 
	if (get_nb_args("id4") != 4)
		ret = 1;	
	print_tds();
	free_tds();
	return ret;
}

int test_mips(char *filename, char *correct_file) {
	yyin = fopen(filename,"r");
	if (yyin == NULL) 
		perror(filename);

	// gencode
	strcat(data, "\t.data\n");
	strcat(instructions, "\t.text\n__start:\n");
	
	init_tds();
	yyparse();
	print_tds();
	free_tds();
	fclose(yyin);
	char code[DATA_SIZE + INSTR_SIZE];
	sprintf(code,"%s%s",data,instructions);
	
	// overture et copie dans un buffer du fichier de correction
	FILE *correction = fopen(correct_file, "r");
	if (correction == NULL)
		perror(correct_file);
	fseek(correction, 0, SEEK_END);
	long size = ftell(correction);
	rewind(correction);
	char *corr = malloc(size + 1);
	fread(corr, 1, size, correction);
	fclose(correction);
	corr[size] = '\0';

	// comparaison
	int comp = strcmp(code,corr);
	printf("\n------- Code --------\n");
	printf("%s",code);
	printf("------- Corrigé ------\n");
	printf("%s",corr);
	printf("----------------------\n\n");
	int i = 0;
	int len_corr = strlen(corr);
	int len_code = strlen(code);
	while ((i < len_corr) && (code[i] == corr[i]))
		i++;
	printf("i : %d |%c| vs |%c| : len code -> %d, len corr -> %d\n",
			i,code[i],corr[i],len_code,len_corr);
	
	printf("comparaison : %s\n",comp?"FAUX":"OK");
	// remise a zero du gencode
	data[0] = '\0';
	instructions[0] = '\0';
	id_count = 0;
	resetVars();
	return comp;
}

int test_mips_operations_s() {
	return test_mips("f_tests/s/operations_s","f_tests/s/operations_s_corr");
}

int test_mips_operations_m() {
	return test_mips("f_tests/m/operations_m","f_tests/m/operations_m_corr");
}

int test_mips_operations_d() {
	return test_mips("f_tests/d/operations_d","f_tests/d/operations_d_corr");
}

int test_mips_dectab_s() {
	return test_mips("f_tests/s/dec_tab_s","f_tests/s/dec_tab_s_corr");
}

int test_mips_dectab_m() {
	return test_mips("f_tests/m/dec_tab_m","f_tests/m/dec_tab_m_corr");
}

int test_mips_dectab_d() {
	return test_mips("f_tests/d/dec_tab_d","f_tests/d/dec_tab_d_corr");
}

int test_mips_echoread_s() {
	return test_mips("f_tests/s/echoread_s","f_tests/s/echoread_s_corr");
}

int test_mips_echoread_m() {
	return test_mips("f_tests/m/echoread_m","f_tests/m/echoread_m_corr");
}

int test_mips_echoread_d() {
	return test_mips("f_tests/d/echoread_d","f_tests/d/echoread_d_corr");
}

int test_mips_if_s() {
	return test_mips("f_tests/s/if_s","f_tests/s/if_s_corr");
}

int test_mips_if_m() {
	return test_mips("f_tests/m/if_m","f_tests/m/if_m_corr");
}

int test_mips_if_d() {
	return test_mips("f_tests/d/if_d","f_tests/d/if_d_corr");
}
