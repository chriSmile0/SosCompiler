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
	printf("--- TEST SIMPLE\n");
	int tests = 0;
	printf("- test_chainescarac_s\n");
	tests += test_chainescarac_s_v2();
	printf("- test_ascii_s\n");
	//tests += test_ascii_s();
	printf("- test_commentaires_s\n");
	tests += test_commentaires_s_v2();
	printf("- test_nombres_s\n");
	tests += test_nombres_s_v2();
	printf("- test_motsreserves_s\n");
	tests += test_motsreserves_s_v2();
	printf("- test_id_s\n");
	tests += test_id_s_v2();
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

	printf("--- TEST MEDIAN\n");
	int tests = 0;
	printf("- test_chainescarac_m\n");
	tests += test_chainescarac_m_v2();
	printf("- test_ascii_m\n");
	tests += test_ascii_m();
	printf("- test_commentaires_m\n");
	tests += test_commentaires_m_v2();
	printf("- test_nombres_m\n");
	tests += test_nombres_m_v2();
	printf("- test_motsreserves_m\n");
	tests += test_motsreserves_m_v2();
	printf("- test_id_m\n");
	tests += test_id_m_v2();
	/*printf("- test_id_m_v2\n");
	tests += test_id_m_v2();*/
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

	printf("--- TEST DIFFICILE\n");
	int tests = 0;
	printf("- test_chainescarac_d\n");
	tests += test_chainescarac_d_v2();
	printf("- test_ascii_d\n");
	tests += test_ascii_d();
	printf("- test_commentaires_d\n");
	tests += test_commentaires_d_v2();
	printf("- test_nombres_d\n");
	tests += test_nombres_d_v2();
	printf("- test_motsreserves_d\n");
	tests += test_motsreserves_d_v2();
	printf("- test_id_d\n");
	tests += test_id_d_v2();
	printf("- test_id_d_v2\n");
	tests += test_id_d_v2();
	
	/*
		Insertion du code du test difficile
		Exemple test_nombres_d();
	*/
	return tests;
}

int main(int argc, char *argv[]) {
	printf("test\n");

	if (argc != 2) {
		fprintf(stderr,"format : %s {1,2,3}\n",argv[0]);
		return 1;
	}
	int (*test_F[3])() = {test_simple, test_median, test_difficile};

	int niveau_test = atoi(argv[1]);
	printf("Test de niveau de rang : %d\n",niveau_test);
	int retour = 0;
	for (int i = 0 ; i < niveau_test ; i++)
		printf("test %d/%d >>> %s\n",i+1,niveau_test,
			(((retour = test_F[i]())) ? "\x1B[31m" "ECHOUE" "\x1B[37m"
				: "\x1B[32m" "VALIDE" "\x1B[37m" ));

	return retour;
}
