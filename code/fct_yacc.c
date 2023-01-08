#include "../inc/fct_yacc.h"

void concat_data(char *dst, char *str2) {
	int initial_len = strlen(dst);
	int new_len = initial_len + strlen(str2);
	char *buf_dst;
	buf_dst = malloc(initial_len + 1);
	snprintf(buf_dst, initial_len+1, "%s", dst);
	dst = realloc(dst, new_len);
	snprintf(dst, new_len+1, "%s%s", buf_dst, str2);
	dst[new_len] = '\0';
}

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


void kill_all_global_use() {
	create_read_proc = false;
	create_echo_proc = false;
	fin_prog = false;
	compare_proc = false;
	check_v_nv_proc = false;
}
