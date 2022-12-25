%{
	#include <stdio.h>
	extern int yylex();
	extern void yyerror(const char *msg);
	#include "../inc/fct_yacc.h"
	extern FILE *yyin;
	extern FILE *yyout;
%}

%token MR
%token CHAR

%union {
	char *id;
	int entier;
	char *chaine;
	char *mot;
	char **multi_cc;
	char space;

}


%token '\n' READ N_ID ECH EXT PVG SPA OACO CACO '$'
%token <entier> NB
%token <chaine> MOT 
%token <chaine> CC

%type <chaine> operande 
%type <chaine> concatenation
%type <entier> instruction
%start program 

%%

program: %empty
	| program instruction '\n'
;

instruction : concatenation {
					$$ = 0;
				}
;


concatenation : concatenation operande  {
					concat_data($1,$2);
					$$ = $1;
					printf("$$ : %s\n",$$);
				}
	| operande 
;

operande : CC
;



%%

#include "../code/fct_yacc.c"