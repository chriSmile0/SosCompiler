%{
	#include <stdio.h>
	#include <string.h>
	extern int yylex();
	int yyerror(char *s);
	extern FILE *yyin;
	void operation(char *str);
	void findStr(char *str, char strs[512][64]);
	char* itoa(int x);
	char data[1024];
	char instructions[4096];
	char ids[512][64];
	int id_count = 0;
	int reg_count = 1;
	int li_count = 0;
%}

%token <id> ID
%token <entier> NB 
%token EG 
%token PL
%token MN
%token FX
%token DV

%left PL MN
%left FX DV

%union {
	char *id;
	int entier;
}

%%

instruction : ID EG expr {findStr($1,ids); strcat(instructions, "sw $t0, "); strcat(instructions, $1); strcat(instructions, "\n");}

expr : unique
     | expr PL expr {operation("add");}
     | expr MN expr {operation("sub");}
     | expr FX expr {operation("mul");}
     | expr DV expr {operation("div");}
;

unique : ID {li_count++;findStr($1,ids);strcat(instructions,"lw $t");strcat(instructions,itoa(reg_count));strcat(instructions,", ");strcat(instructions,$1);strcat(instructions,"\n");reg_count++;}
       | NB {li_count++;strcat(instructions,"li $t");strcat(instructions,itoa(reg_count));strcat(instructions,", ");strcat(instructions,itoa($1));strcat(instructions,"\n");reg_count++;}
;

%%
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
