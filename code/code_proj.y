%{
	#include <stdio.h>
	#include <string.h>
	#include "fct_yacc.h"
	extern int yylex();
	int yyerror(char *s);
	extern FILE *yyin;
	void operation(char *str);
	void findStr(char *str, char strs[512][64]);
	char* itoa(int x);
	char data[1024];		// Partie declaration des variables
	char instructions[4096];	// Partie instructions
	char ids[512][64];		// Tableau des identificateurs
	int id_count = 0;		// Nombre d'identificateurs
	int reg_count = 1;		// Sur quel registre temporaire doit-on ecrire
	int li_count = 0;		// Nombre d'affectations executées
%}

%token <id> ID
%token <entier> NB 
%token EG 
%token PL
%token MN
%token FX
%token DV
%token OP
%token CP
%token END

// Regles de grammaire
%left PL MN
%left FX DV

%union {
	char *id;
	int entier;
}

%%
programme : instruction END programme 
	  | instruction END
;

instruction : ID EG expr 	// Affectation
	    {
	    	findStr($1,ids);
		strcat(instructions, "sw $t");
		strcat(instructions, itoa(reg_count-1));
		strcat(instructions, ", ");
		strcat(instructions, $1);
		strcat(instructions, "\n");
		reg_count = 1;
		li_count = 0;
	    }
;

expr : unique
     | expr PL expr {operation("add");}
     | expr MN expr {operation("sub");}
     | expr FX expr {operation("mul");}
     | expr DV expr {operation("div");}
     | OP expr CP 
     | MN expr %prec MN
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

unique : ID {li_count++;if (find_entry($1) == -1) yyerror("ID pas dans la table des symoles");strcat(instructions,"lw $t");strcat(instructions,itoa(reg_count));strcat(instructions,", ");strcat(instructions,$1);strcat(instructions,"\n");reg_count++;}
       | NB {li_count++;strcat(instructions,"li $t");strcat(instructions,itoa(reg_count));strcat(instructions,", ");strcat(instructions,itoa($1));strcat(instructions,"\n");reg_count++;}
;

%%
// Fonction qui execute une operation entre les deux derniers registres temporaires utilisés
void operation(char *str) {
	strcat(instructions, str);
	strcat(instructions, " $t");
	if (li_count <= 2) strcat(instructions,"0");
	else strcat(instructions, itoa(reg_count-2));
	strcat(instructions, ", $t"); strcat(instructions, itoa(reg_count-2));
	strcat(instructions, ", $t"); strcat(instructions, itoa(reg_count-1));
	strcat(instructions, "\n");
	reg_count--;
	if (li_count <= 2) reg_count--;
	li_count--;
	if (reg_count <= 0) reg_count = 1;
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
  exit(1);
  return 1;
}
