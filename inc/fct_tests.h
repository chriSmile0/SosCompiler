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
 * @brief	Test sur un cas simple de chaine de caractères
 * 
 * 
 * @param[:]
 * @return 0 si test valide sinon 1
*/
int test_chainescarac_s();

/**
 * @brief	Test sur un cas plus compliqué de chaine de caractères
 * 
 * 
 * @param[:]
 * @return 0 si test valide sinon 1

*/
int test_chainescarac_m();

/**
 * @brief	Test sur certains cas d'erreur possibles 
 * 			et de confusion qui pourrait tromper notre 
 * 			analyseur lexical
 * 
 * 
 * @param[:]
 * @return 0 si test valide sinon 1
*/
int test_chainescarac_d();
#endif // FCT_TESTS_H //
