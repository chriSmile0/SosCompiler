#ifndef FCT_TESTS_H
#define FCT_TESTS_H

#include "../inc/code_proj.tab.h"
#include <stdio.h>
#include <stdlib.h>
extern int yylex();
extern void yyerror();
extern FILE *yyin;

/**
 * @brief
 * @param[:]
 * @return
*/

int test_motsreserves_s();

/**
 * @brief
 * @param[:]
 * @return
*/

int test_motsreserves_m();

/**
 * @brief
 * @param[:]
 * @return
*/

int test_motsreserves_d();

#endif // FCT_TESTS_H //