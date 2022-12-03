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
	extern FILE *yyout_text;
	extern FILE *yyout_data;
	extern FILE *yyout_main;
	extern FILE *yyout_proc;
	extern FILE *yyout_final;
	bool create_echo_proc = false;
	void create_echo_data(char *id,char *chaine);
	bool create_read_proc = false;
	void echo_main(char *id);
	bool fin_prog = false;
	void check_create_echo_proc();
	void check_create_read_proc();
	void check_exit_proc();
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
id_ : ID;




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
	/*char buf[SIZE_LINE_MIPS];
	char *line = ".data\n\tbuffer: .space 4000\n.text\n.globl _start\n__start:\n";
	snprintf(buf,SIZE_LINE_MIPS,"%s",line);
	buf[strlen(line)] = '\0';
	fwrite(buf,strlen(line),1,yyout);
	line = "\nExit:\n\tli $v0 10\n\tsyscall\n";
	snprintf(buf,SIZE_LINE_MIPS,"%s",line);
	buf[strlen(line)] = '\0';
	fwrite(buf,strlen(line),1,yyout);*/
	//fprintf(yyout,".data\n\tbuffer: .space 4000\n.text\n.globl _start\n__start:\n");
	//fprintf(yyout,"\nExit:\n\tli $v0 10\n\tsyscall\n");//fin 
}

void mips_read_all() {
	//Create Lecture_*
	char buf[1024] = "\nLecture_Int:\n\tli $v0 5\n\tsyscall\n\tjr $ra\n";
	char buf2[1024] = "\nLecture_Str:\n\tli $v0 8\n\tsyscall\n\tjr $ra\n";
	printf("buf : |%s|\n",buf);
	printf("buf2 : |%s|\n",buf2);
	fwrite(buf,strlen(buf),1,yyout_proc);
	fwrite(buf2,strlen(buf2),1,yyout_proc);
}
void mips_print_all() {
	//Create Affichage_*
	char buf[1024] = "\nAffichage_Int:\n\tli $v0 1\n\tsyscall\n\tjr $ra\n";
	char buf2[1024] = "\nAffichage_Str:\n\tli $v0 4\n\tsyscall\n\tjr $ra\n";
	printf("buf : |%s|\n",buf);
	printf("buf2 : |%s|\n",buf2);
	fwrite(buf,strlen(buf),1,yyout_proc);
	fwrite(buf2,strlen(buf2),1,yyout_proc);
}


//a placer avant la création des procédures 
/*void mips_exit() {
	fprintf(yyout,"\nExit:\n\tli $v0 10\n\tsyscall");
}*/

void check_create_echo_proc() {
	if (!create_echo_proc) {
		mips_print_all();
		create_echo_proc = true;
	}
}

void check_exit_proc() {
	char buf[1024] = "\nExit:\n\tli $v0, 10\n\tsyscall\n";
	printf("buf : |%s|\n",buf);
	fwrite(buf,strlen(buf),1,yyout_proc);
}

void check_create_read_proc() {
	if (!create_read_proc) { 
		mips_read_all();
		create_read_proc = true;
	}
}

void create_read_data() {
	char buf[1024];
	char space[] = ".space";
	char buffer[] = "buffer";
	char *taille = "50";
	snprintf(buf,1024,"\n\t%s: %s %s",buffer,space,taille);
	buf[strlen(buffer)+5+strlen(space)+strlen(taille)] = '\0';
	printf("buf : %s\n",buf);
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

void create_echo_data(char *id,char *chaine) {
	char buf[1024];
	char asciiz[] = ".asciiz";
	snprintf(buf,1024,"\n\t%s: %s \"%s\"",id,asciiz,chaine);
	buf[strlen(id)+7+strlen(asciiz)+strlen(chaine)] = '\0';
	printf("buf : %s\n",buf);
	fwrite(buf,strlen(buf),1,yyout_data);
}

void echo_main(char *id) {
	char buf[1024];
	int true_size = strlen(id);
	for (int i = 0 ; i < true_size; i++) 
		buf[i] = id[i];
	buf[true_size] = '\0';
	char buf_in_mips[1024];
	char *jal_str = "\tjal Affichage_Str \n";
	snprintf(buf_in_mips,1024,"\tla $a0, %s\n%s",buf,jal_str);
	fwrite(buf_in_mips,10+strlen(buf)+strlen(jal_str),1,yyout_main);
}

void build_final_mips() {
	FILE *file_tab[4] = {yyout_data,yyout_text,yyout_main,yyout_proc};
	char *en_tetes[4] = {".data\n","\n.text","\nmain:\n",""};
	char *file_name[4] = {"data","text","main","proc"};

	char buf[1024];
	int read_size = 0;
	for	(int i = 0 ; i < 4 ; i++) {
		int stop = 1;
		char in_param[27];
		snprintf(in_param,27,"exit_mips/exit_mips_%s.s",file_name[i]);
		in_param[27] = '\0';
		if (i == 2)
			fprintf(file_tab[i],"\n\tjal Exit\n");
		fclose(file_tab[i]);
		file_tab[i] = fopen(in_param,"r+");
		fprintf(yyout_final,"%s",en_tetes[i]);
		while (stop) {
			read_size = fread(buf,1024,1,file_tab[i]);
			if (read_size == 0)
				stop = 0;
			buf[strlen(buf)] = '\0';
			printf("buf : |%s|\n",buf);
			fwrite(buf,strlen(buf),1,yyout_final);
			buf[0] = '\0';//on vide le buffer
		}
		fclose(file_tab[i]);

	}
}

void create_echo_data(char *id,char *chaine) {
	char buf[1024];
	char asciiz[] = ".asciiz";
	snprintf(buf,1024,"\t%s: %s \"%s\"",id,asciiz,chaine);
	buf[strlen(id)+7+strlen(asciiz)+strlen(chaine)] = '\0';
	fwrite(buf,strlen(buf),1,yyout_data);
}

void echo_main(char *id) {
	char buf[1024];
	int true_size = strlen(id);
	for (int i = 0 ; i < true_size; i++) 
		buf[i] = id[i];
	buf[true_size] = '\0';
	char buf_in_mips[1024];
	char *jal_str = "\tjal Affichage_Str \n";
	snprintf(buf_in_mips,1024,"\tla $a0, %s\n%s",buf,jal_str);
	fwrite(buf_in_mips,10+strlen(buf)+strlen(jal_str),1,yyout_main);
}

void build_final_mips() {
	FILE *file_tab[4] = {yyout_data,yyout_text,yyout_main,yyout_proc};
	char *en_tetes[4] = {".data\n","\n.text","\nmain:\n",""};
	char *file_name[4] = {"data","text","main","proc"};

	char buf[1024];
	int read_size = 0;
	for	(int i = 0 ; i < 4 ; i++) {
		int stop = 1;
		char in_param[27];
		snprintf(in_param,27,"exit_mips/exit_mips_%s.s",file_name[i]);
		in_param[27] = '\0';
		if (i == 2)
			fprintf(file_tab[i],"\n\tjal Exit\n");
		fclose(file_tab[i]);
		file_tab[i] = fopen(in_param,"r+");
		fprintf(yyout_final,"%s",en_tetes[i]);
		while (stop) {
			read_size = fread(buf,1024,1,file_tab[i]);
			if (read_size == 0)
				stop = 0;
			fwrite(buf,strlen(buf),1,yyout_final);
			buf[0] = '\0';//on vide le buffer
		}
		fclose(file_tab[i]);
	}
}