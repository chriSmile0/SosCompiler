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
	char *args;
	char *nb;
	char *chaine;
	char *mot;
	char **multi_cc;
	char space;
}


%token '\n' READ N_ID ECH EXT PVG SPA OACO CACO '$'
%token <nb> NB
%token <chaine> MOT 
%token <chaine> ARGS 
%token <chaine> CC

%type <chaine> operande 
%type <entier> instruction
%start program 

%%

program: %empty
	| program instruction '\n'
;

instruction : operande {
					$$ = 0;
				}
;

operande : CC {$$ = $1; printf("|%s|\n",rtn_arg(1,"abc def"));}
	| MOT {$$ = $1; printf("mot \n");}
	| ARGS {$$ = traiter_arg($1,"exemple");printf("$$ : %s\n",$$);}
;



%%

#include "../code/fct_yacc.c"
