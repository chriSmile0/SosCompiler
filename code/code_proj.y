%{
	#include <stdio.h>
	extern int yylex();
	extern void yyerror(const char *msg);
	#include "../inc/fct_yacc.h"
	#include <stdbool.h>
	extern FILE *yyin;
	extern FILE *yyout;

%}

%token MR
%token EXPR
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
	char sign;
	int boolean;
}


%token '\n' N_ID PVG SPA OACO CACO OCRO CCRO OPAR CPAR '$' '!' '=' '~' OU ET
%token <nb> NB
%token <id> ID
%token <chaine> MOT 
%token <chaine> ARGS 
%token <sign> SIGN
%token <chaine> CC

%type <entier> instruction
%type <chaine> concatenation
%type <boolean> test_expr test_expr2 test_expr3 test_instruction
%type <chaine> operande
%start program 

%%

program: %empty
	| program instruction '\n'
;

instruction : test_expr {
		$$ = $1;
		printf("%s\n",$$?"true":"false");
	}

test_expr : test_expr OU test_expr2 {$$ = ($1+$3);}
	| test_expr2 
;

test_expr2 : test_expr2 ET test_expr3 {$$ = ($1*$3);}
	| test_expr3 
;

test_expr3 : OPAR test_expr CPAR {$$ = $2;}
	| '!' OPAR test_expr CPAR  {$$ = !$3;}
	| test_instruction {$$ = $1;}
	| '!' test_instruction {$$ = !$2;}
;

test_instruction : concatenation '=' concatenation { $$ = (strcmp($1,$3)==0);}
	| concatenation '~' concatenation {$$ = (strcmp($1,$3)!=0);}
;
	
concatenation : concatenation operande  {
					concat_data($1,$2);
					$$ = $1;
				}
	| operande 
;

operande : CC
;



%%

#include "../code/fct_yacc.c"

