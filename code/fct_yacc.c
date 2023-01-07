#include "../inc/fct_yacc.h"

void init_tds(){
	table.taille = 0;
	table.champs = (champ*) malloc(sizeof(champ)*10000);
}

int add_tds(char* name, int type, int init, int dim,
    int global, char* func) {
    table.champs[table.taille].name = name;
    table.champs[table.taille].type = type;
    table.champs[table.taille].init = init;
    table.champs[table.taille].dim = dim;
    table.champs[table.taille].global = global;
    table.champs[table.taille].func = func;
    return table.taille++;
}

void print_entry(int index) {
    printf("name : %s, type : %i, init : %i, dim : %i, "
    "global : %i, func : %s\n", table.champs[index].name, 
    table.champs[index].type, table.champs[index].init, 
    table.champs[index].dim, table.champs[index].global,
    table.champs[index].func);
}

void print_tds() {
    for (int i = 0; i < table.taille; i++)
        print_entry(i);
}

int find_entry(char* name) {
    for (int i = 0; i < table.taille; i++){
        if (strcmp(table.champs[i].name, name) == 0)
            return i;
    }
    return -1;
}

void update_entry(int index, int type) {
    table.champs[index].init = 1;
    table.champs[index].type = type;
}

int get_type(char* name) {
    int ind;
    //si on trouve l'entrée
    if ((ind = find_entry(name)) != -1){
        return table.champs[ind].type;
    }
    //sinon erreur
    fprintf(stderr, "Erreur : var %s pas dans la tds.\n", name);
    return -1;
}

char* get_fonc(char* name) {
    int ind;
    //si on trouve l'entrée
    if ((ind = find_entry(name)) != -1){
        return table.champs[ind].func;
    }
    //sinon erreur
    fprintf(stderr, "Erreur : var %s pas dans la tds.\n", name);
    return "";
}  

int get_dim(char* name) {
    int ind;
    //si on trouve l'entrée
    if ((ind = find_entry(name)) != -1){
        return table.champs[ind].dim;
    }
    //sinon erreur
    fprintf(stderr, "Erreur : var %s pas dans la tds.\n", name);
    return -1;
}

int set_fonc(int ind, char* func){
    if (!table.champs[ind].global){
        table.champs[ind].func = func;
        return ind;
    }
    //sinon erreur
    return -1;
}

void free_tds() {
    free(table.champs);
}