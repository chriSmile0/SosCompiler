#ifndef FCT_YACC_H
#define FCT_YACC_H
#include <stdlib.h>
#include <string.h>

/**
 * Enum des types des identificateurs
 */
enum types{
	CH,	/**< Chaine de caractères */
	TAB,	/**< Tableau */ 
	FCT, 	/**< Fonction */
	ENT, 	/**< Entier */
	MOT, 	/**< Mot */
};

/**
 * Entrée de la table des symboles
 */

typedef struct {
	/*@{*/
	char* name; 	/**< nom de l'id */
	char* val;	/**< valeur de l'id, null si pas init */
	int type;	/**< type de l'id, def dans l'enum types */
	int init;	/**< 0 si l'id est pas init, 1 sinon */
	char[3] dim;	/**< dims pour un tableau, de la forme N,M ou N */
	int nb_arg;	/**< nombres d'arguments pour une fonction, 4 max */
	int global; 	/**< 1 si variable globale, 0 sinon */
	char* func;	/**< nom de la fonction où est la variable locale */
	/*@}*/
} champ;




/** 
 * Table des symboles
 */
struct table_symbole {
	/*@{*/
	int taille;	/**< taille de la table des symboles */
	champ *champs;	/**< entrées de la table des symboles */
} table;
