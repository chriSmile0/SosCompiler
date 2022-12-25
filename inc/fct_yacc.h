#ifndef FCT_YACC_H
#define FCT_YACC_H
#include <stdlib.h>
#include <string.h>

/**
 * @brief	Traiter un nombre en chaines de caracteres en nombres réel
 * 
 * @param[:nb] Le nombre en chaines de caractères
 * 
 * @return La valeur du nombre 
*/
int traiter_nombre(char *nb);


/**
 * @brief	Vérifier la validité d'un argument de '$entier'
 * 			ou '$?' ou '$*'
 * 
 * @param[:ligne arg] la ligne en question
 * 
 * @return valeur de l'arg
*/
char * traiter_arg(char *ligne_arg, char *list_arguments);

/**
 * @brief
 * 
 * @param[:index_arg] 
 * @param[:list_arguments]
 * 
 * @return 
*/
char * rtn_arg(int index_arg, char * list_arguments);

/**
 * @brief
 * 
 * @param[:e]
 * @param[:tab]
 * @param[:index_dep]
 * 
 * @return 
*/

void int_in_str(int e, char tab[],int index_dep);

#endif // FCT_YACC //