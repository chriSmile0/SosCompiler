#include "../inc/code_proj.tab.h"
#include "../inc/fct_tests.h"
#include <stdio.h>
#include <stdlib.h>




/**
 * @brief	Suite de fonctions de type_*_s()
 * 			Chaque fonction ouvre le fichier *_s.sh
 * 			et check le type de tokens que l'on veut reconnaitre
 * 			dans notre test ainsi que le bon nombre qui est censé s'y trouver 
 * 
 * @param[:]
 * @return 0 si tout les tests passe sinon >0 (check potentiel du test défaillant)
*/
int test_simple() {
	printf("\n--- TEST SIMPLE\n");
	int tests = 0;
	/*printf("- test_chainescarac_s\n");
	tests += test_chainescarac_s_v2();
	printf("- test_ascii_s\n");
	tests += test_ascii_s();
	printf("- test_commentaires_s\n");
	tests += test_commentaires_s_v2();
	printf("- test_nombres_s\n");
	tests += test_nombres_s_v2();
	printf("- test_motsreserves_s\n");
	tests += test_motsreserves_s_v2();
	printf("- test_id_s\n");
	tests += test_id_s_v2();
	printf("- test_mot_s\n");
	tests += test_mot_s_v2();
	printf("- test_oper_s\n");
	tests += test_oper_s_v2();
	printf("- test_opel_s\n");
	tests += test_opel_s_v2();*/
	printf("- test_operations_s\n");
	tests += test_operations_s();
	printf("- test_tds_s\n");
	tests += test_tds_s();
	printf("- test_dec_tab_s\n");
	tests += test_dec_tab_s();
	printf("- test mips v2 \n");
	tests += test_echo_read_v2();
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
 * @brief 	Suite de fonctions de type_*_m()
 * 			Chaque fonction ouvre le fichier exemple1.sh
 * 			et check le type de tokens que l'on veut reconnaitre
 * 			dans notre test ainsi que le bon nombre qui est censé s'y trouver  
 * 
 * @param[:]
 * @return 0 si tout les tests passe sinon >0 (check potentiel du test défaillant)
*/
int test_median() {

	printf("\n--- TEST MEDIAN\n");
	int tests = 0;
	/*printf("- test_chainescarac_m\n");
	tests += test_chainescarac_m_v2();
	printf("- test_ascii_m\n");
	tests += test_ascii_m_v2();
	printf("- test_commentaires_m\n");
	tests += test_commentaires_m_v2();
	printf("- test_nombres_m\n");
	tests += test_nombres_m_v2();
	printf("- test_motsreserves_m\n");
	tests += test_motsreserves_m_v2();
	printf("- test_id_m\n");
	tests += test_id_m_v2();
	printf("- test_mot_m\n");
	tests += test_mot_m_v2();
	printf("- test_oper_m\n");
	tests += test_oper_m_v2();
	printf("- test_opel_s\n");
	tests += test_opel_s_v2();*/
	printf("- test_operations_m\n");
	tests += test_operations_m();
	printf("- test_dec_tab_m\n");
	tests += test_dec_tab_m();
	/*
		Insertion du code du test median
		Exemple test_nombres_m();
	*/
	return tests;
}


/**
 * @brief Suite de fonctions de type_*_d()
 * 			Chaque fonction ouvre un fichier *_d.sh
 * 			et check le type de tokens que l'on veut reconnaitre
 * 			dans notre test ainsi que le bon nombre qui est censé s'y trouver 
 * 
 * @param[:]
 * @return 0 si tout les tests passe sinon >0 (check potentiel du test défaillant)
*/
int test_difficile() {

	printf("\n--- TEST DIFFICILE\n");
	int tests = 0;
	/*printf("- test_chainescarac_d\n");
	tests += test_chainescarac_d_v2();
	printf("- test_ascii_d\n");
	tests += test_ascii_d_v2();
	printf("- test_commentaires_d\n");
	tests += test_commentaires_d_v2();
	printf("- test_nombres_d\n");
	tests += test_nombres_d_v2();
	printf("- test_motsreserves_d\n");
	tests += test_motsreserves_d_v2();
	printf("- test_id_d\n");
	tests += test_id_d_v2();
	printf("- test_mot_d\n");
	tests += test_mot_d_v2();
	printf("- test_oper_d\n");
	tests += test_oper_d_v2();
	printf("- test_opel_s\n");
	tests += test_opel_s_v2();*/
	printf("- test_operations_d\n");
	tests += test_operations_d();
	printf("- test_dec_tab_d\n");
	tests += test_dec_tab_d();


	/*
		Insertion du code du test difficile
		Exemple test_nombres_d();
	*/
	return tests;
}


void hide_tokens_h() {
	FILE * f = fopen("code/tokens.h","r+");
	char b_com[2] = "/*";
	fwrite(b_com,2,1,f);
	fseek(f,0,SEEK_END);
	char e_com[2] = "*/";
	fwrite(e_com,2,1,f);
}

int test_mips_simple() {
	int tests = 0;
	printf("- test_echo_read\n");
	tests += test_echo_read_s();
	return tests;
}

int test_mips_median() {
	int tests = 0;
	printf("- test_echo_read_m\n");
	//tests += test_echo_read_m();
	return tests;
}

int test_mips_difficile() {
	int tests = 0;
	printf("- test_echo_read\n");
	tests += test_echo_read_d();
	return tests;
}

int main(int argc, char *argv[]) {
	if (argc != 2) {
		fprintf(stderr,"format : %s {1,2,3}\n",argv[0]);
		return 1;
	}
	

	int (*test_F[3])() = {test_simple, test_median, test_difficile};
	int (*test_FM[3])() = {test_mips_simple, test_mips_median, 
							test_mips_difficile};

	int niveau_test = atoi(argv[1]);
	printf("Test de niveau de rang : %d\n",niveau_test);
	int retour = 0;
	for (int i = 0 ; i < niveau_test ; i++)
		printf("test %d/%d >>> %s\n",i+1,niveau_test,
			(((retour = test_F[i]())) ? "\x1B[31m" "ECHOUE" "\x1B[37m"
				: "\x1B[32m" "VALIDE" "\x1B[37m" ));

	//hide_tokens_h();
	printf("Test mips de niveau de rang : %d\n",niveau_test);
	retour = 0; //que test 1 pour le moment 
	/*for (int i = 0 ; i < niveau_test ; i++)
		printf("test %d/%d >>> %s\n",i+1,niveau_test,
			(((retour = test_FM[i]())) ? "\x1B[31m" "ECHOUE" "\x1B[37m"
				: "\x1B[32m" "VALIDE" "\x1B[37m" ));*/
	return retour;
}
