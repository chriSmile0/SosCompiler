%{
	#include <stdio.h>
	#include <string.h>
	#include "fct_yacc.h"
	#include <stdlib.h>
	#include <unistd.h>
	#include <fcntl.h>
	#include <stdbool.h>
	#define SIZE_LINE_MIPS 90
	extern int yylex();
	extern void yyerror(const char *msg);
	void mips_struct_file();
	extern FILE *yyin;
	extern FILE *yyout;
	bool create_echo_proc = false;
	bool fin_prog = false;
	void check_create_echo_proc();
	void remonter_in_main();
	void operation(char *str);
	void findStr(char *str, char strs[512][64]);
	char* itoa(int x);

	char data[1024];			// Partie declaration des variables
	char instructions[4096];	// Partie instructions
	char ids[512][64];		// Tableau des identificateurs
	int id_count = 0;		// Nombre d'identificateurs
	int reg_count = 1;		// Sur quel registre temporaire doit-on ecrire
	int li_count = 0;		// Nombre d'affectations executées
	int if_count = 0;		// Nombre de conditions executées
	static int else_count = 0;	// Nombre de else
	extern int elsee;
%}


%token EG 
%token PL
%token MN
%token FX
%token DV
%token OP
%token CP
%token END

%token IF
%token THEN
%token FI
%token ELSE
%token DEC
%token OB
%token CB

// Regles de grammaire
%left PL MN
%left FX DV

%token MR
%token CHAR
%token COM

%union {
	char *id;
	int entier;
	char *chaine;
	char **multi_cc;
}

%token '\n' READ N_ID ECH EXT
%token <chaine> CC
%token <id> ID
%token <entier> NB 
%type <chaine> operande 
%type <entier> instruction



%%
programme : instruction END programme 
	  | instruction END 
	  {
	  	if (elsee) {
			elsee--;
			strcat(instructions, "j Fi");
			strcat(instructions, itoa(else_count-1));
			strcat(instructions, "\n");
			strcat(instructions, "Else");
			strcat(instructions, itoa(else_count-1));
			strcat(instructions, ":\n");
		}
	  }
;

instruction : ID EG oper	// Affectation
	    {
		if (find_entry($1) == -1)
			add_tds($1, ENT, 1, 0, 0, 1, "");
	    	findStr($1,ids);
		strcat(instructions, "sw $t");
		strcat(instructions, itoa(reg_count-1));
		strcat(instructions, ", ");
		strcat(instructions, $1);
		strcat(instructions, "\n");
		reg_count = 1;
		li_count = 0;
	    }
		| DEC ID OB NB CB { // Déclaration de tableau
			if (find_entry($2) == -1)
				add_tds($2, TAB, 1, $4, -1, 1, "");

			// Buffer contenant la ligne à intégrer dans ".data" du MIPS
			char buff[64];
			size_t max_length = sizeof(buff);
			int ret = snprintf(buff, max_length, "%s:\t.space\t%d\n", $2, $4);

			if (ret >= max_length)
				fprintf(stderr, "|ERREUR| Dépassement du buffer - Dec tab");

			strcat(data, buff);
		}
	    | IF bool THEN programme FI
	    {
	    	strcat(instructions, "Else");
		strcat(instructions, itoa(--if_count));
		strcat(instructions, ":\n");
	    }
	    | IF bool THEN programme ELSE programme FI
	    {
	    	strcat(instructions, "Fi");
		strcat(instructions, itoa(--if_count));
		strcat(instructions, ":\n");
	    }
;

bool : NB 
     {
     	strcat(instructions, "li $t0, ");
	strcat(instructions, itoa($1));
	strcat(instructions, "\n");
	strcat(instructions, "beq $t0, $zero, Else");
	strcat(instructions, itoa(else_count));
	strcat(instructions, "\n");
	if_count++;
	else_count++;
     }
;

oper : unique
     | oper PL oper {operation("add");}
     | oper MN oper {operation("sub");}
     | oper FX oper {operation("mul");}
     | oper DV oper {operation("div");}
     | OP oper CP 
     | MN oper %prec MN
     {
	strcat(instructions, "li $t");
	strcat(instructions, itoa(reg_count));
	strcat(instructions, ", -1\n");
     	strcat(instructions, "mul $t");
	strcat(instructions, itoa(reg_count-1));
	strcat(instructions, ", $t");
	strcat(instructions, itoa(reg_count-1));
	strcat(instructions, ", $t");
	strcat(instructions, itoa(reg_count));
	strcat(instructions, "\n");
     }
;

unique : ID
	{
		li_count++;
		if (find_entry($1) == -1)
			yyerror("ID pas dans la table des symoles");
		strcat(instructions,"lw $t");
		strcat(instructions,itoa(reg_count));
		strcat(instructions,", ");
		strcat(instructions,$1);
		strcat(instructions,"\n");
		reg_count++;
	}
	| NB
	{
		li_count++;
		strcat(instructions,"li $t");
		strcat(instructions,itoa(reg_count));
		strcat(instructions,", ");
		strcat(instructions,itoa($1));
		strcat(instructions,"\n");
		reg_count++;
	}
;


%%
// Fonction qui execute une operation entre les deux derniers registres
// temporaires utilisés
void operation(char *str) {
	strcat(instructions, str);
	strcat(instructions, " $t");
	if (li_count <= 2)
		strcat(instructions,"0");
	else
		strcat(instructions, itoa(reg_count-2));
	strcat(instructions, ", $t");
	strcat(instructions, itoa(reg_count-2));
	strcat(instructions, ", $t");
	strcat(instructions, itoa(reg_count-1));
	strcat(instructions, "\n");
	reg_count--;
	if (li_count <= 2)
		reg_count--;
	li_count--;
	if (reg_count <= 0)
		reg_count = 1;
}

// Fonction qui cherche si un ID est déjà déclaré, sinon il le fait
void findStr (char *str, char strs[512][64]) {
	for (int i = 0; i < id_count; i++) {
		if (strcmp(str, strs[i]) == 0) {
			return;
		}
	}
	strcpy(strs[id_count], str);
	strcat(data, str);
	strcat(data, ":\t.word\t0\n");
	id_count++;
}

char* itoa(int x) {
	static char str[100];
	sprintf(str, "%d", x);
	return str;
}

int yyerror(char *s) {
	fprintf(stderr, "Erreur de syntaxe : %s\n", s);
	return 1;
}


void mips_struct_file() {
	char buf[SIZE_LINE_MIPS];
	char *line = ".data\n\tbuffer: .space 4000\n.text\n.globl _start\n__start:\n";
	snprintf(buf,SIZE_LINE_MIPS,"%s",line);
	buf[strlen(line)] = '\0';
	fwrite(buf,strlen(line),1,yyout);
	line = "\nExit:\n\tli $v0 10\n\tsyscall\n";
	snprintf(buf,SIZE_LINE_MIPS,"%s",line);
	buf[strlen(line)] = '\0';
	fwrite(buf,strlen(line),1,yyout);
	//fprintf(yyout,".data\n\tbuffer: .space 4000\n.text\n.globl _start\n__start:\n");
	//fprintf(yyout,"\nExit:\n\tli $v0 10\n\tsyscall\n");//fin 
}


void mips_read_all() {
	//Create Lecture_*
	fprintf(yyout,"\nLecture_Int:\n\tli $v0 5\n\tsyscall\n\tjr $ra\n");
	fprintf(yyout,"\nLecture_Str:\n\tli $v0 8\n\tsyscall\n\tjr $ra\n");
}
void  mips_print_all() {
	//Create Affichage_*
	fprintf(yyout,"\nAffichage_Int:\n\tli $v0 1\n\tsyscall\n\tjr $ra\n");
	//index_true = index_true+42;
	fprintf(yyout,"\nAffichage_Str:\n\tli $v0 4\n\tsyscall\n\tjr $ra\n");
}

void check_create_echo_proc() {
	if(!create_echo_proc) {
		fseek(yyout,0,SEEK_END);
		mips_print_all();
		create_echo_proc = true;
	}
}


void remonter_in_main() {
	fseek(yyout,0,SEEK_SET);
	int stop = 0;
	char search[] = "Exit:";
	int len_search = strlen(search);
	char buf[5];
	char *last_possible_search = malloc(sizeof(char)*(len_search+1));
	int index = 0;
	int possible_sub_string = 0;
	int debut_potentiel = 0;
	while (!stop) {
		if (fread(buf,len_search,1,yyout) <= 0)
			stop = 1;
		if (strncmp(buf,search,len_search) == 0) {
			stop = 1;
		}
		else if (debut_potentiel != 0) {
			int h = 0;
			debut_potentiel--;
			int k = debut_potentiel;
			for(k = debut_potentiel ; k < len_search; k++) {
				if(buf[h] == search[k])
					debut_potentiel++;
				h++;
			}
			if(debut_potentiel == (len_search))
				stop = 1;
		}
		else {//
			possible_sub_string = 0;
			debut_potentiel = 0;
			for (int j = 0 ; j < len_search ; j++) {
				if((search[0] == buf[j]) || (debut_potentiel != 0)){
					debut_potentiel = j;
					for(int k = j ; k < len_search ; k++) {
						if (buf[k] == search[k-j])
							possible_sub_string++;
						else if ((possible_sub_string != 0) && (search[k] != buf[j]))
							possible_sub_string = 0;
					}
					if(possible_sub_string > 0) 
						debut_potentiel = possible_sub_string;
				}
			}
		}
		if (stop)
			index -= (len_search);
		else 
			index += len_search;
	}
	//on sauve la suite 
	char buf_save[1024];
	fseek(yyout,index,SEEK_SET);
	index_true = index;
}

int insert_bloc_at_end_of_main(char *bloc) {
	if ((bloc != NULL) && (index_true >= 0)) {
		int true_size = strnlen(bloc,1020);
		char buf_save[1024];
		int stop = 1;
		while (stop) {
			stop = fread(buf_save,1024,1,yyout);
			fseek(yyout,index_true+true_size-1,SEEK_SET);
			fwrite(buf_save,strlen(buf_save),1,yyout);
		}

		fseek(yyout,index_true,SEEK_SET);
		char bloc_buf[1024];
		snprintf(bloc_buf,strlen(bloc),"%s",bloc);
		fwrite(bloc_buf,strlen(bloc_buf),1,yyout);
		return 0;
	}
	return -1;
}