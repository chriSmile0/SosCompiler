%{
	#include <stdio.h>
	#include <string.h>
	extern int yylex();
	extern void yyerror(const char *msg);
	extern FILE *yyin;
	void findStr(char *str, char strs[512][64]);
	char data[1024];
	char instructions[4096];
	char ids[512][64];
	int id_count = 0;
%}

%token <id> ID
%token <entier> NB 

%union {
	char *id;
	int entier;
}

%start program


%%

program : %empty
	| program instruction '\n'
;

instruction : ID '=' NB  {findStr($1,ids); strcat(instructions,"li $t0, "); char buff[50]; snprintf( buff, 50, "%d", $3 ); strcat(instructions,buff); strcat(instructions,"\nsw $t0, "); strcat(instructions,$1); strcat(instructions,"\n");}
;

%%
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
