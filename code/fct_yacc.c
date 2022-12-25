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
        return "Statut Fonction";
    }
    else if (ligne_arg[0] == '*') {//$*
        return "Ligne Arg";
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
