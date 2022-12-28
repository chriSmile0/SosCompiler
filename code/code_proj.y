%{
	#include <stdio.h>
	extern int yylex();
	extern void yyerror(const char *msg);
	#include "../inc/fct_yacc.h"
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
}


%token '\n' N_ID PVG SPA OACO CACO OCRO CCRO OPAR CPAR '$' '!' '=' '~'
%token <nb> NB
%token <id> ID
%token <chaine> MOT 
%token <chaine> ARGS 
%token <sign> SIGN
%token <chaine> CC

%type <entier> instruction
%type <chaine> concatenation
%type <chaine> test_expr test_expr2 test_expr3 test_instruction
%type <chaine> operande
%start program 

%%

program: %empty
	| program instruction '\n'
;

instruction : test_expr {
		printf("%s\n",$1);
		$$ = 1;
	}

test_expr : test_expr "-o" test_expr2
	| test_expr2 {$$ = $1;printf("très loin \n");}
;

test_expr2 : test_expr2 "-a" test_expr3
	| test_expr3 {$$ = $1;printf("on remonte \n");}
;

test_expr3 : OPAR test_expr CPAR {$$ = $2;}
	| '!' OPAR test_expr CPAR  {$$ = $3;}
	| test_instruction {$$ = $1;printf("iciii \n");}
	| '!' test_instruction {$$ = $2;}
;

test_instruction : concatenation '=' concatenation {$$ = $1; printf("==  \n");}
	| concatenation '~' concatenation
	| concatenation {$$ = $1; printf("classique \n");}
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

