#include "../inc/fct_yacc.h"

void init_tds(){
	table.taille = 0;
	table.champs = (champ*) malloc(sizeof(champ)*10000);
}

int add_tds(char* name, int type, int init, int dim,
    int nb_arg, int global, char* func) {
    table.champs[table.taille].name = name;
    table.champs[table.taille].type = type;
    table.champs[table.taille].init = init;
    table.champs[table.taille].dim = dim;
    table.champs[table.taille].nb_arg = nb_arg;
    table.champs[table.taille].global = global;
    table.champs[table.taille].func = func;
    return table.taille++;
}

void print_entry(int index) {
    printf("name: %s | type: %i | init: %i | dim: %i | nb_arg: %i | "
    "global: %i | func: %s\n", table.champs[index].name, 
    table.champs[index].type, table.champs[index].init, 
    table.champs[index].dim, table.champs[index].nb_arg,
    table.champs[index].global, 
    table.champs[index].func[0] == '\0' ? "None" : table.champs[index].func);
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

char* get_func(char* name) {
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

int get_nb_args(char* name) {
    int ind;
    //si on trouve l'entrée
    if ((ind = find_entry(name)) != -1){
        return table.champs[ind].nb_arg;
    }
    //sinon erreur
    fprintf(stderr, "Erreur : var %s pas dans la tds.\n", name);
    return -1;
}

void free_tds() {
    free(table.champs);
}
void mips_read_all() {
	//Create Lecture_*
	char buf[1024] = "\nLecture_Int:\n\tli $v0 5\n\tsyscall\n\tjr $ra\n";
	char buf2[1024] = "\nLecture_Str:\n\tli $v0 8\n\tsyscall\n\tjr $ra\n";
	fwrite(buf,strlen(buf),1,yyout_proc);
	fwrite(buf2,strlen(buf2),1,yyout_proc);
}
void mips_print_all() {
	//Create Affichage_*
	char buf[1024] = "\nAffichage_Int:\n\tli $v0 1\n\tsyscall\n\tjr $ra\n";
	char buf2[1024] = "\nAffichage_Str:\n\tli $v0 4\n\tsyscall\n\tjr $ra\n";
	fwrite(buf,strlen(buf),1,yyout_proc);
	fwrite(buf2,strlen(buf2),1,yyout_proc);
}

void check_echo_proc() {
	if (!create_echo_proc) {
		mips_print_all();
		create_echo_proc = true;
	}
}

void check_exit_proc() {
	char buf[1024] = "\nExit:\n\tli $v0, 10\n\tsyscall\n";
	buf[strlen(buf)] = '\0';
	fwrite(buf,strlen(buf),1,yyout_proc);
}

void check_read_proc() {
	if (!create_read_proc) { 
		//mips_read_all();
		create_read_proc = true;
	}
}

void kill_all_global_use() {
	create_read_proc = false;
	create_echo_proc = false;
	fin_prog = false;
}