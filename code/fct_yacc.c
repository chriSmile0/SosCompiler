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
		mips_read_all();
		create_read_proc = true;
	}
}

void read_data(char *id) {
	char buf[1024];
	char space[] = ".space";
	char buffer[1024];
	snprintf(buffer,1024,"%s",id);
	buffer[strlen(id)] = '\0';
	char taille[] = "5000";
	snprintf(buf,1020,"\n\t%s: %s %s\n",buffer,space,taille);
	buf[strlen(buffer)+5+strlen(space)+strlen(taille)] = '\0';
	fwrite(buf,strlen(buf),1,yyout_data);
}

void read_main(char *id) {
	int true_size = strlen(id);
	char buf[1024];
	for (int i = 0 ; i < true_size; i++) 
		buf[i] = id[i];
	buf[true_size] = '\0';
	char buf_in_mips[1024];
	char la[] = "\tla $a0, ";
	snprintf(buf_in_mips,1024,"%s%s\n",la,buf);
	buf_in_mips[strlen(la)+strlen(buf)+1] = '\0';
	char li[] = "\tli $a1, 50\n";//taille du buffer que l'on connais (a opti pour plus tard)
	snprintf(buf_in_mips+strlen(buf_in_mips),1024,"%s",li);
	char jal_Lstr[] = "\tjal Lecture_Str \n";
	snprintf(buf_in_mips+strlen(buf_in_mips),1024,"%s",jal_Lstr);
	buf_in_mips[strlen(buf_in_mips)+strlen(jal_Lstr)] = '\0';
	fwrite(buf_in_mips,strlen(buf_in_mips),1,yyout_main);
}


void int_in_str(int e, char tab[],int size,int index_dep) {
    for(int i = 0 ; i < index_dep; i++) // on pad avec une lettre 
        tab[i] = 'a';
    sprintf(tab+index_dep,"%d",e);
} 
   

void echo_data(int *id,char *chaine) {
	char buf[1024];
	
    int_in_str(*id,buf,1024,1);
	char true_chaine_s = strlen(chaine);
	char buf_c[1024];
	for (int i = 0 ; i < true_chaine_s; i++) 
		buf_c[i] = chaine[i];
	buf_c[true_chaine_s] = '\0';
	char buf_in_mips[1024];
	buf_in_mips[0] = '\0';
	char asciiz[11];
	char g1[12] = "\"";
	g1[strlen(g1)] = '\0';
	snprintf(asciiz,11,"%s",": .asciiz ");
	asciiz[10] = '\0';
	snprintf(buf_in_mips,1024,"%s%s%s%s%s%s",buf,asciiz,g1,buf_c,g1,"\n");
	buf_in_mips[strlen(buf)+strlen(asciiz)+strlen(buf_c)+2*(strlen(g1))+1] = '\0';
	fwrite(buf_in_mips,strlen(buf_in_mips),1,yyout_data);
}

void echo_main(int *id) {
	char buf[1024];
    int_in_str(*id,buf,1024,1);
	char buf_in_mips[1024];
	char *jal_str = "\tjal Affichage_Str \n";
	snprintf(buf_in_mips,1024,"\tla $a0, %s\n%s",buf,jal_str);
	fwrite(buf_in_mips,10+strlen(buf)+strlen(jal_str),1,yyout_main);
    (*id)++;
}