#ifndef FCT_TESTS_H
#define FCT_TESTS_H

#include "../inc/code_proj.tab.h"
#include <stdio.h>
#include <stdlib.h>
extern int yylex();
extern void yyerror();
extern FILE *yyin;

/**
 * @brief	Test sur un cas très simple 
 * 			
 * @param[:]
 * 
 * @return 0 si test valide sinon 1
*/

int test_motsreserves_s(void);

/**
 * @brief	Test sur le fichier exemple1.sh 
 * 
 * 
 * @param[:]
 * @return 0 si test valide sinon 1
*/

int test_motsreserves_m(void);

/**
 * @brief	Test sur certains cas d'erreur possibles 
 * 			et de confusion qui pourrait tromper notre 
 * 			analyseur lexical
 * 
 * 
 * @param[:]
 * @return 0 si test valide sinon 1
*/
int test_motsreserves_d(void);

/**
 * @brief	Test sur un cas simple de chaine de caractères
 * 
 * 
 * @param[:]
 * @return 0 si test valide sinon 1
*/
int test_chainescarac_s(void);

/**
 * @brief	Test sur un cas plus compliqué de chaine de caractères
 * 
 * 
 * @param[:]
 * @return 0 si test valide sinon 1

*/
int test_chainescarac_m(void);

/**
 * @brief	Test sur certains cas d'erreur possibles 
 * 			et de confusion qui pourrait tromper notre 
 * 			analyseur lexical
 * 
 * 
 * @param[:]
 * @return 0 si test valide sinon 1
*/
int test_chainescarac_d(void);

/**
 * @brief	Test sur des characteres ascii valide
 * 
 * 
 * @param[:]
 * @return 0 si test valide sinon 1
*/
int test_ascii_s(void);

/**
 * @brief	Test sur un fichier SOS
 * 
 * 
 * @param[:]
 * @return 0 si test valide sinon 1
*/
int test_ascii_m(void);


/**
 * @brief	Test sur des characteres ascii invalide
 * 
 * 
 * @param[:]
 * @return 0 si test valide sinon 1
*/
int test_ascii_d(void);

/**
 * @brief	Fonction de test générale
 * 
 * @param chemin_fichier_test chemin vers le fichier "sh" de test
 * @param attendu nombre d'occurences de commentaire à trouver
 * 
 * @return 0 si test valide sinon 1
*/
int test_commentaires(char* chemin_fichier_test, int attendu);

/**
 * @brief	Test sur un cas simple (que des lettres)
 * 
 * @return 0 si test valide sinon 1
*/
int test_commentaires_s(void);

/**
 * @brief	Test sur un cas avec des accents
 * 
 * @return 0 si test valide sinon 1
*/
int test_commentaires_m(void);

/**
 * @brief	Test sur un cas avec des accents et des espaces directement après le
 * 			symbole de commentaire
 * 
 * @return 0 si test valide sinon 1
*/
int test_commentaires_d(void);

/**
 * @brief 	Fonction de test générale
 * 
 * @param chemin_fichier_test chemin vers le fichier de test
 * @param attendu nombre d'occurences de nombres à trouver
 * 
 * @return 0 si test valide sinon 1
*/

int test_nombres(char* chemin_fichier_test, int attendu);

/**
 * @brief	Test sur un cas très basique
 * 
 * @return 0 si test valide sinon 1
*/

int test_nombres_s(void);

/**
 * @brief	Test sur notre fichier exemple1 
 * 			qui contient un certain nombres de nombres
 * 
 * @return 0 si test valide sinon 1
*/

int test_nombres_m(void);

/**
 * @brief	Test sur un fichier qui contient des nombres
 * 			négatifs et positifs plus ou moins grand 
 * 
 * @return 0 si test valide sinon 1
*/

int test_nombres_d(void);

int test_id(char *chemin_fichier_test, int attendu);

int test_id_s(void);

int test_id_m(void);

int test_id_d(void);



#endif // FCT_TESTS_H //