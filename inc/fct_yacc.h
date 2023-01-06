#ifndef FCT_YACC_H
#define FCT_YACC_H
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

/**
 * Enum des types des identificateurs
 */
enum types{
	CH,	/**< Chaine de caractères */
	TAB,	/**< Tableau */ 
	FCT, 	/**< Fonction */
	ENT, 	/**< Entier */
	MOT, 	/**< Mot */
	IDS, 	/**< Id */
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
 * @param valeur à quoi l'id fait réference ; par exemple une str, NULL sinon 
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

char* get_valeur(char* name);

/**
 * @brief free la tds
 */
void free_tds();

/**** INSTRUCTION *****/
/*	Création des fct : 
/*		- 	instruction_data()
		-	instruction_proc()
		- 	instruction_main()
/*	Qui associe pour chaque instruction des lignes de mips à écrire
/*	Dans le fichier en sortie 
/**** FIN INSTRUCTION ******/


/**
 * @brief 	Lecture_Int et Lecture_Str combiné
 * 
 * @param //
 * 
 * @return //
*/
void mips_read_all();

/**
 * @brief 	Affichage_Int et Affichage_Str combiné
 * 
 * @param //
 * 
 * @return //
*/
void mips_print_all() ;

/**
 * @brief	Check qu'une procédure echo n'existe pas déjà
 * 
 * @param //
 * 
 * @return //
*/
void check_echo_proc();

/**
 * @brief 	Check qu'une procédure exit n'existe pas déjà
 * 
 * @param //
 * 
 * @return //
*/
void check_exit_proc();

/**
 * @brief 	Check qu'une procédure read n'existe pas déjà 
 * 
 * @param //
 * 
 * @return //
*/
void check_read_proc();

/**
 * @brief 	Création des buffers pour read 
 * 
 * @param //
 * 
 * @return //
*/
void read_data(char *id);

/**
 * @brief 	Création des lignes de code en mips dans le main pour read
 * 
 * @param //
 * 
 * @return //
*/
void read_main(char *id);

/**
 * @brief 	Création des buffers pour echo
 * 
 * @param //
 * 
 * @return //
*/
void echo_data(int *id,char *chaine);

/**
 * @brief 	Creéation des lignes de code en mips dans le main pour echo
 * 
 * @param //
 * 
 * @return //
*/
void echo_main(int *id, char *chaine);

void kill_all_global_use();


void int_in_str(int e, char tab[],int index_dep);

int cherche_id(char *id);

int ajout_chaine(char *id, char *chaine);

void print_table_symboles();


#endif // FCT_YACC //
