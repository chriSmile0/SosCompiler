#ifndef FCT_TESTS_H
#define FCT_TESTS_H

#include "../inc/code_proj.tab.h"
#include "../inc/fct_yacc.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
extern int yylex();
extern void yyerror();
extern FILE *yyin;
extern char data[1024];
extern char instructions[4096];
extern int id_count;

/** 
* @brief	Il s'agit d'une fonction généraliste pour pouvoir éxécuter
*			chacun de test de manière isolé mais aussi de manière
*			similaire mis à part pour le test d'un caractere 
*			ascii qui se teste différemment 			
*
* 
* @param[:chemin_fichier_test] le fichier à tester
* @param[:attendu] le nombre de token reconnaissable attendu
* @param[:token_d] le plus petit token dans notre plage de recherche
* @param[:token_l] le plus grand token dans notre plage de recherche
* @param[:def_tok] la définition du token en chaine de caractères
* @return 0 si test valide sinon 1
*/
int test_type(char *chemin_fichier_test, int attendu, int token_d,
    int token_l, char *def_tok);

/**
 * @brief	Test sur des caracteres ascii valide
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

int test_ascii_m_v2();

/**
 * @brief	Test sur des characteres ascii invalide
 * 
 * 
 * @param[:]
 * @return 0 si test valide sinon 1
*/
int test_ascii_d_v2();


/**
 * @brief	Test sur un cas très simple
 * 
 * 
 * @param[:]
 * @return 0 si test valide sinon 1
*/
int test_motsreserves_s_v2(void);

/**
 * @brief	Test sur le fichier exemple1
 * 
 * 
 * @param[:]
 * @return 0 si test valide sinon 1
*/
int test_motsreserves_m_v2(void);

/**
 * @brief	Test sur certains cas d'erreur possibles 
 * 			et de confusion qui pourrait tromper notre 
 * 			analyseur lexical
 * 
 * 
 * @param[:]
 * @return 0 si test valide sinon 1
*/
int test_motsreserves_d_v2(void);

/**
 * @brief	Test sur un cas simple de chaine de caractères
 * 
 * 
 * @param[:]
 * @return 0 si test valide sinon 1
*/
int test_chainescarac_s_v2(void);

/**
 * @brief	Test sur un cas plus compliqué de chaine de caractères
 * 
 * 
 * @param[:]
 * @return 0 si test valide sinon 1
*/
int test_chainescarac_m_v2(void);

/**
 * @brief	Test sur certains cas d'erreur possibles 
 * 			et de confusion qui pourrait tromper notre 
 * 			analyseur lexical
 * 
 * 
 * @param[:]
 * @return 0 si test valide sinon 1
*/
int test_chainescarac_d_v2(void);

/**
 * @brief	Test sur un cas simple (que des lettres)
 * 
 * @return 0 si test valide sinon 1
*/
int test_commentaires_s_v2(void);


/**
 * @brief	Test sur un cas avec des accents
 * 
 * @return 0 si test valide sinon 1
*/
int test_commentaires_m_v2(void);

/**
 * @brief	Test sur un cas avec des accents et des espaces directement après le
 * 			symbole de commentaire
 * 
 * @return 0 si test valide sinon 1
*/
int test_commentaires_d_v2(void);

/**
 * @brief	Test sur un cas très basique
 * 
 * @return 0 si test valide sinon 1
*/
int test_nombres_s_v2(void);

/**
 * @brief	Test sur notre fichier exemple1 
 * 			qui contient un certain nombres de nombres
 * 
 * @return 0 si test valide sinon 1
*/
int test_nombres_m_v2(void);

/**
 * @brief	Test sur un fichier qui contient des nombres
 * 			négatifs et positifs plus ou moins grand 
 * 
 * @return 0 si test valide sinon 1
*/
int test_nombres_d_v2(void);

/**
 * @brief	Test sur un cas très basique
 * 
 * @return 0 si test valide sinon 1
*/
int test_id_s_v2(void);

/**
 * @brief	Test sur notre fichier exemple1 
 * 			qui contient un certain nombres d'identifiants
 * 
 * @return 0 si test valide sinon 1
*/
int test_id_m_v2(void);

/**
 * @brief	Test sur un fichier qui contient des 
 * 			identifiants avec des caractères non ascii 
 *
 * 
 * @return 0 si test valide sinon 1
*/
int test_id_d_v2(void);

int test_mot_s_v2(void);

int test_mot_m_v2(void);

int test_mot_d_v2(void);

int test_oper_s_v2(void);
	

int test_oper_m_v2(void); 
	

int test_oper_d_v2(void);
	

int test_opel_s_v2(void);
	

int test_opel_m_v2(void);


int test_opel_d_v2(void);

int test_operations_s(void);
int test_operations_m(void);
int test_operations_d(void);

int test_tds_s(void);

int test_dec_tab_s(void);
int test_dec_tab_m(void);
int test_dec_tab_d(void);
#endif // FCT_TESTS_H //
