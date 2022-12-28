#include "../inc/fct_yacc.h"


int traiter_nombre(char *nb) {
    if (nb[0] == '-') {
        nb++;
        return -(atoi(nb));
    }
    else {
        return atoi(nb);
    }
}

char * rtn_arg(int index_arg, char * list_arguments) {
    //si on estime que les arguments sont stockés en chaine de caracteres
    int len = strlen(list_arguments);
    int cpt_arg = 0;
    //check des espaces dans la ligne
    int len_arg = 0;
    int arg_idx = 0;
    int found = 0;
    int fin_chaine = 0;
    for (int i = 0 ; i < len; i++) {
        if ((list_arguments[i] == ' ') || (i == len-1)) {
            cpt_arg++;
            if (cpt_arg == index_arg) {
                if (i == len-1)
                    fin_chaine = 1;
                i = len;
                arg_idx -= (len_arg+1);
                found = 1;
            }
            else {
                len_arg = 0;
            }
        }
        else {
            len_arg++;
        }
        arg_idx++;
    }
    if (found) {
        int total_len = len_arg+fin_chaine;
        char *arg = malloc((total_len));
        snprintf(arg,total_len+1,"%s",list_arguments+arg_idx);
        arg[total_len] = '\0';
        return arg;
    }
    fprintf(stderr,"Erreur sur l'index de l'argument \n");
    exit(EXIT_FAILURE);
}

char * traiter_arg(char *ligne_arg, char *list_argumens) {
    if (ligne_arg[0] == '?') {//$?
        return "??";
    }
    else if (ligne_arg[0] == '*') {//$*
        return "**";
    }
    else {//$entier
        return rtn_arg((atoi(ligne_arg)),list_argumens);
    }
}


void int_in_str(int e, char tab[],int index_dep) {
    for(int i = 0 ; i < index_dep; i++) // on pad avec une lettre 
        tab[i] = 'a';
    sprintf(tab+index_dep,"%d",e);
} 


int cherche_id(char *id)
{
	int i = 0;
	int size_table = table.taille;
	while((strcmp(table.champs[i].id,id)!=0) 
		&& (i < size_table))
		i++;
    printf("i : %d\n",i);
	if(i==size_table)
		return -1;
	return i;
}

int ajout_chaine(char *id, char *chaine)
{
	int result_cherche = 0;
	if((result_cherche = cherche_id(id))!=-1)
		return result_cherche;
	snprintf(table.champs[table.taille].id,50,"%s",id);
	table.champs[table.taille].id[strlen(id)] = '\0';
	snprintf(table.champs[table.taille].valeur,50,"%s",chaine);
	table.champs[table.taille].valeur[strlen(chaine)] = '\0';
	table.taille++;
	return (table.taille-1);
}

char * str_value_of_id(char *id) {
    int result_recherche = 0;
    if ((result_recherche = cherche_id(id))==-1) {
        fprintf(stderr,"Erreur id introuvable dans la table\n");
        exit(EXIT_FAILURE);
    }
    return table.champs[result_recherche].valeur;
}

void print_table_symboles() {
	int taille_table = table.taille;
	for(int i = 0 ; i < taille_table; i++)
		printf("id: %s, valeur : %s\n",table.champs[i].id,table.champs[i].valeur); 
}

void concat_data(char *dst, char *str2) {
    int initial_len = strlen(dst);
    int new_len = initial_len + strlen(str2);
    char *buf_dst;
    buf_dst = malloc(initial_len+1);
    snprintf(buf_dst,initial_len+1,"%s",dst);
    dst = realloc(dst,new_len);
    snprintf(dst,new_len+1,"%s%s",buf_dst,str2);
    dst[new_len] = '\0';
}


