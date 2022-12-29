#ifndef FCT_YACC_H
#define FCT_YACC_H
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


typedef struct {
	int index_in_t;
	char *id;
	char *valeur;
} champ;

struct table_symbole {
	int cur_index;
	int taille;
	champ *champs;
} table;

typedef struct {
	char *type;
	char *id;
	int utiliser; 
	char *valeur;
} registre;

struct table_registre {
	int cur_index;
	int taille;
	registre *registres;
} t_reg;



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


int cherche_id(char *id);

int ajout_chaine(char *id, char *chaine);

char * str_value_of_id(char *id);

void print_table_symboles();

//REGISTRES 
int cherche_registre(char *reg);

int reg_libre_of_type(char type);

char * ajout_value_in_reg(char *reg, char *valeur);

char * str_value_of_reg(char *reg);

void print_table_registre();

void int_in_register(char *res, int value, FILE * dest);

void ope_arith_mips(int res_dest, int res_left, int res_right, char sign);



#endif // FCT_YACC //
