#ifndef FCT_YACC_H
#define FCT_YACC_H
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdbool.h>

extern bool create_echo_proc;
extern bool create_read_proc;
extern bool fin_prog;
extern bool compare_proc;
extern bool check_v_nv_proc;
extern bool check_and_proc;
extern bool check_or_proc;

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
	int type;	/**< type de l'id, def dans l'enum types */
	int init;	/**< 0 si l'id est pas init, 1 sinon */
	int dim;	/**< dims pour un tableau */
	int nb_arg;	/**< nombres d'arguments pour une fonction, 4 max */
	int global; 	/**< 1 si variable globale, 0 sinon */
	char* func;	/**< nom de la fonction où est la variable locale */
	/*@}*/
} champ;

/**
 * @brief
 * 
 * @param[:dst] la chaine destination de la concatenation
 * @param[:str2] la chaine a concatener à la dst
 * 
 * @return la chaîne résultante dans dst
*/
void concat_data(char *dst, char *str2);

/** 
 * Table des symboles
 */
struct table_symbole {
	/*@{*/
	int taille;	/**< taille de la table des symboles */
	champ *champs;	/**< entrées de la table des symboles */
} table;

/**
 * @brief init de la table des symboles
 * 
 */
void init_tds();

/**
 * @brief ajout d'une entrée dans la table des symboles
 * 
 * @param name nom de l'id
 * @param type type de l'id
 * @param init 1 si l'id est init, 0 sinon
 * @param dim dimension si tableau, NULL sinon
 * @param nb_arg nombre d'arguments si fonction, -1 sinon
 * @param global 1 si variable globale, 0 sinon
 * @param func nom de la fonction mère si variable locale, NULL sinon
 * @return int 
 */
int add_tds(char* name, int type, int init, int dim,
	int nb_arg, int global, char* func);

/**
 * @brief affiche l'entrée de rang index dans la table des symboles
 * 
 * @param index index de l'entrée à afficher
 */
void print_entry(int index);

/**
 * @brief affiche toute la table des symboles
 * 
 */
void print_tds();

/**
 * @brief cherche une entrée dans la tds
 * @return index si trouvée, -1 sinon
 */
int find_entry(char* name);

/**
 * @brief update de la valeur de l'entrée de rang index
 * 
 * @param index rang de l'entrée dans la tds
 * @param val valeur de la variable
 */
void update_entry(int index, int type);

/**
 * @brief retourne le type de la variable name
 * 
 * @param name nom de la variable
 * @return int type de la variable de l'enum types, -1 sinon
 */
int get_type(char* name);

/**
 * @brief renvoie le nom de la fonction mère si la variable est locale,
 * sinon renvoie une chaine vide
 * @param name nom de la variable à chercher
 * @return char* nom de la fonction mère ou chaine vide
 */
char * get_func(char* name);

/**
 * @brief retourne les dimensions de la variable name
 * 
 * @param name nom de la variable
 * @return int dimensions du tableau, -1 si ce n'est pas un tableau
 */
int get_dim(char* name);

/**
 * @brief retourne le nombre d'arguments de la variable name
 * 
 * @param name nom de la variable
 * @return int le nombre d'arguments, -1 si ce n'est pas une fonction
 */
int get_nb_args(char* name);

/**
 * @brief free la tds
 */
void free_tds();

/**
 * @brief	Remise à zéro des booleens globales
 * 
 * @param //
 * 
 * @return //
*/
void kill_all_global_use(void);

#endif