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
	return test_type("f_tests/s/motsreserves_s",5,EXT,MR,"mots reserves");
}

int test_motsreserves_m_v2() {
	return test_type("f_tests/e_sos/exemple1",39,EXT,MR,"mots reserves");
}

int test_motsreserves_d_v2() {
	return test_type("f_tests/d/motsreserves_d",4,EXT,MR,"mots reserves");
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

int test_operations_s() {
	// Redirection de l'entrée standard (comme test_type)
	char* filename = "f_tests/s/operations_s";
	yyin = fopen(filename,"r");
	if (yyin == NULL) 
		perror(filename);

	// gencode
	strcat(data, "\t.data\n");
	strcat(instructions, "\t.text\n__start:\n");
	init_tds();
	yyparse();
	free_tds();
	fclose(yyin);
	char code[BUFSIZ];
	sprintf(code,"%s%s",data,instructions);

	// overture et copie dans un buffer du fichier de correction
	FILE *correction = fopen("f_tests/s/operations_s_corr", "r");
	if (correction == NULL)
		perror("f_tests/s/operations_s_corr");
	fseek(correction, 0, SEEK_END);
	long size = ftell(correction);
	rewind(correction);
	char *corr = malloc(size + 1);
	fread(corr, 1, size, correction);
	fclose(correction);
	corr[size] = '\0';

	// comparaison
	int comp = strcmp(code,corr);
	printf("code : |%s|\n",code);
	printf("corr : |%s|\n",corr);
	printf("  comparaison : %s\n",comp==0?"OK":"FAUX");

	// remise a zero du gencode
	data[0] = '\0';
	instructions[0] = '\0';
	id_count = 0;
	return comp;
}

int test_operations_m() {
	// Redirection de l'entrée standard (comme test_type)
	char* filename = "f_tests/m/operations_m";
	yyin = fopen(filename,"r");
	if (yyin == NULL) 
		perror(filename);
	// gencode
	strcat(data, "\t.data\n");
	strcat(instructions, "\t.text\n__start:\n");
	init_tds();
	yyparse();
	free_tds();
	fclose(yyin);
	char code[BUFSIZ];
	sprintf(code,"%s%s",data,instructions);

	// overture et copie dans un buffer du fichier de correction
	FILE *correction = fopen("f_tests/m/operations_m_corr", "r");
	if (correction == NULL)
		perror("f_tests/m/operations_m_corr");
	fseek(correction, 0, SEEK_END);
	long size = ftell(correction);
	rewind(correction);
	char *corr = malloc(size + 1);
	fread(corr, 1, size, correction);
	fclose(correction);
	corr[size] = '\0';

	// comparaison
	int comp = strcmp(code,corr);
	printf("  comparaison : %s\n",comp==0?"OK":"FAUX");

	// remise a zero du gencode
	data[0] = '\0';
	instructions[0] = '\0';
	id_count = 0;
	return comp;
}

int test_operations_d() {
	// Redirection de l'entrée standard (comme test_type)
	char* filename = "f_tests/d/operations_d";
	yyin = fopen(filename,"r");
	if (yyin == NULL) 
		perror(filename);

	// gencode
	strcat(data, "\t.data\n");
	strcat(instructions, "\t.text\n__start:\n");
	init_tds();
	yyparse();
	free_tds();
	fclose(yyin);
	char code[BUFSIZ];
	sprintf(code,"%s%s",data,instructions);

	// overture et copie dans un buffer du fichier de correction
	FILE *correction = fopen("f_tests/d/operations_d_corr", "r");
	if (correction == NULL)
		perror("f_tests/d/operations_d_corr");
	fseek(correction, 0, SEEK_END);
	long size = ftell(correction);
	rewind(correction);
	char *corr = malloc(size + 1);
	fread(corr, 1, size, correction);
	fclose(correction);
	corr[size] = '\0';

	// comparaison
	int comp = strcmp(code,corr);
	printf("  comparaison : %s\n",comp==0?"OK":"FAUX");

	// remise a zero du gencode
	data[0] = '\0';
	instructions[0] = '\0';
	id_count = 0;
	return comp;
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
	if (strcmp(get_valeur("id5"),"chaines") != 0)
		ret = 1;

	print_tds();
	free_tds();
	return ret;
}

int test_dec_tab_s(void){
	// Redirection de l'entrée standard (comme test_type)
	char* filename = "f_tests/s/dec_tab_s";
	yyin = fopen(filename,"r");
	if (yyin == NULL) 
		perror(filename);

	// gencode
	strcat(data, "\t.data\n");
	strcat(instructions, "\t.text\n__start:\n");
	init_tds();
	yaccc = 1;
	yyparse();
	free_tds();
	yaccc = 0;
	fclose(yyin);
	char code[BUFSIZ];
	sprintf(code,"%s%s",data,instructions);

	// overture et copie dans un buffer du fichier de correction
	FILE *correction = fopen("f_tests/s/dec_tab_s_corr", "r");
	if (correction == NULL)
		perror("f_tests/s/dec_tab_s_corr");
	fseek(correction, 0, SEEK_END);
	long size = ftell(correction);
	rewind(correction);
	char *corr = malloc(size + 1);
	fread(corr, 1, size, correction);
	fclose(correction);
	corr[size] = '\0';

	// comparaison
	int comp = strcmp(code,corr);
	printf("  comparaison : %s\n",comp==0?"OK":"FAUX");

	// remise a zero du gencode
	data[0] = '\0';
	instructions[0] = '\0';
	id_count = 0;
	return comp;
}

int test_dec_tab_m(void){
	// Redirection de l'entrée standard (comme test_type)
	char* filename = "f_tests/m/dec_tab_m";
	yyin = fopen(filename,"r");
	if (yyin == NULL) 
		perror(filename);

	// gencode
	strcat(data, "\t.data\n");
	strcat(instructions, "\t.text\n__start:\n");
	init_tds();
	yaccc = 1;
	yyparse();
	free_tds();
	yaccc = 0;
	fclose(yyin);
	char code[BUFSIZ];
	sprintf(code,"%s%s",data,instructions);

	// overture et copie dans un buffer du fichier de correction
	FILE *correction = fopen("f_tests/m/dec_tab_m_corr", "r");
	if (correction == NULL)
		perror("f_tests/m/dec_tab_m_corr");
	fseek(correction, 0, SEEK_END);
	long size = ftell(correction);
	rewind(correction);
	char *corr = malloc(size + 1);
	fread(corr, 1, size, correction);
	fclose(correction);
	corr[size] = '\0';

	// comparaison
	int comp = strcmp(code,corr);
	printf("  comparaison : %s\n",comp==0?"OK":"FAUX");

	// remise a zero du gencode
	data[0] = '\0';
	instructions[0] = '\0';
	id_count = 0;
	return comp;
}

int test_dec_tab_d(void){
	// Redirection de l'entrée standard (comme test_type)
	char* filename = "f_tests/d/dec_tab_d";
	yyin = fopen(filename,"r");
	if (yyin == NULL) 
		perror(filename);

	// gencode
	strcat(data, "\t.data\n");
	strcat(instructions, "\t.text\n__start:\n");
	init_tds();
	yaccc = 1;
	yyparse();
	free_tds();
	yaccc = 0;
	fclose(yyin);
	char code[BUFSIZ];
	sprintf(code,"%s%s",data,instructions);

	// overture et copie dans un buffer du fichier de correction
	FILE *correction = fopen("f_tests/d/dec_tab_d_corr", "r");
	if (correction == NULL)
		perror("f_tests/d/dec_tab_d_corr");
	fseek(correction, 0, SEEK_END);
	long size = ftell(correction);
	rewind(correction);
	char *corr = malloc(size + 1);
	fread(corr, 1, size, correction);
	fclose(correction);
	corr[size] = '\0';

	int comp = strcmp(code,corr);
	printf("  comparaison : %s\n",comp==0?"OK":"FAUX");

	// remise a zero du gencode
	data[0] = '\0';
	instructions[0] = '\0';
	id_count = 0;
	return comp;
}
int test_echo_read(char* chemin_fichier_test, int attendu) {
	char* filename = chemin_fichier_test;
	yyin = fopen(filename,"r");
	if (yyin == NULL) 
		perror(filename);
	yyout_data = fopen("exit_mips/exit_mips_data.s","w+");
	yyout_text = fopen("exit_mips/exit_mips_text.s","w+");
	yyout_main = fopen("exit_mips/exit_mips_main.s","w+");
	yyout_proc = fopen("exit_mips/exit_mips_proc.s","w+");
	yyout_final = fopen("exit_mips/exit_mips.s","w+");

	//init table des symboles

	table.taille = 0;
	table.champs = (champ*)(malloc(sizeof(champ)*1024));//1024 pour le moment 
	if (table.champs != NULL)
		for (int i = 0 ; i < 1024 ; i++) {
			table.champs[i].name = malloc(50); //49 carac par id max 
			table.champs[i].name[0] = '\0';
			table.champs[i].valeur = malloc(sizeof(50));
			table.champs[i].valeur[0] = '\0';
		}

	if (yyout_proc == NULL) 
		perror("exit_mips.s doit exister");
		
	//mips_struct_file();
	int r = yyparse();
	if(fin_prog)
		printf("Fin programme ");
	else 
		printf("pas de fin de programme ");
	printf(": %d\n",r);
	build_final_mips();
	kill_all_global_use();
	fclose(yyout_final);
	free(table.champs);
	return r;
}

int test_echo_read_s() {
	return test_echo_read("f_tests/s/word_s", 4);
}

int test_echo_read_m() {
	return test_echo_read("f_tests/e_sos/exemple1", 100);
}

int test_echo_read_d() {
	return test_echo_read("f_tests/d/word_d", 6);
}


int test_echo_read_v2() {
	char* filename = "f_tests/s/word_s";
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
	char code[BUFSIZ];
	sprintf(code,"%s%s",data,instructions);
	
	

	// overture et copie dans un buffer du fichier de correction
	FILE *correction = fopen("f_tests/s/word_s_corr", "r");
	if (correction == NULL)
		perror("f_tests/s/word_s_corr");
	fseek(correction, 0, SEEK_END);
	long size = ftell(correction);
	rewind(correction);
	char *corr = malloc(size + 1);
	fread(corr, 1, size, correction);
	fclose(correction);
	corr[size] = '\0';

	// comparaison
	int comp = strcmp(code,corr);
	printf("code : |%s|\n",code);
	printf("corr : |%s|\n",corr);
	int i = 0;
	int len_corr = strlen(corr);
	int len_code = strlen(code);
	while ((i < len_corr) && (code[i] == corr[i]))
		i++;
	printf("i : %d |%c| vs |%c| : len code -> %d, len corr -> %d\n",
			i,code[i],corr[i],len_code,len_corr);
	
	printf("comparaison : %s\n",comp==0?"OK":"FAUX");

	// remise a zero du gencode
	data[0] = '\0';
	instructions[0] = '\0';
	id_count = 0;
	return comp;
}
