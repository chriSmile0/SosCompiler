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

int test_motsreserves_s();

/**
 * @brief	Test sur le fichier exemple1.sh 
 * 
 * 
 * @param[:]
 * @return 0 si test valide sinon 1
*/

int test_motsreserves_m();

/**
 * @brief	Test sur certains cas d'erreur possibles 
 * 			et de confusion qui pourrait tromper notre 
 * 			analyseur lexical
 * 
 * 
 * @param[:]
 * @return 0 si test valide sinon 1
*/
int test_motsreserves_d();

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

#endif // FCT_TESTS_H //