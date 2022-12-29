%{
	#include <stdio.h>
	extern int yylex();
	extern void yyerror(const char *msg);
	#include "../inc/fct_yacc.h"
	extern FILE *yyin;
	extern FILE *yyout_text;
	extern FILE *yyout_data;
	extern FILE *yyout_main;
	extern FILE *yyout_proc;
	extern FILE *yyout_final;

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


%token '\n' N_ID PVG SPA OACO CACO OCRO CCRO OPAR CPAR '$'
%token <nb> NB
%token <id> ID
%token <chaine> MOT 
%token <chaine> ARGS 
%token <sign> SIGN_S SIGN_P
%token <chaine> CC

%type <entier> operande_entier
%type <sign> plus_ou_moins fois_div_moins
%type <entier> somme_entiere produit_entier
%type <entier> instruction
%start program 

%%

program: %empty
	| program instruction '\n'
;

instruction : operande_entier {
		$$ = 1;
	}
;


operande_entier : '$' OACO ID CACO {$$ = traiter_nombre(str_value_of_id($3));printf(" id = nb $$ : %d\n",$$);}
	| ARGS {
			if(strcmp(traiter_arg($1,"exemple"),"??")==0)//?
				$$ = -1; // on ignore
			else if(strcmp(traiter_arg($1,"exemple"),"**")==0) //*
				$$ = -1; // on ignore
			else //entier
				$$ = traiter_nombre(traiter_arg($1,"exemple"));
		}
	| plus_ou_moins ARGS {
		if(strcmp(traiter_arg($2,"exemple"),"??")==0)//?
			$$ = -1; // on ignore
		else if(strcmp(traiter_arg($2,"exemple"),"**")==0) //*
			$$ = -1; // on ignore
		else  //entier
			$$ = ($1 == '-') ? -traiter_nombre(traiter_arg($2,"exemple")) : traiter_nombre(traiter_arg($2,"exemple"));	
		}
		
	| plus_ou_moins '$' OACO ID CACO {
			$$ = ($1 == '-') ? -(traiter_nombre(str_value_of_id($4))) : traiter_nombre(str_value_of_id($4));
		}
	| NB {$$ = traiter_nombre($1);int_in_register("$t0",$$,yyout_main);}
	| plus_ou_moins NB {$$ = ($1 == '-') ? (-traiter_nombre($2)) : traiter_nombre($2); }
	| OPAR somme_entiere CPAR {$$ = $2; printf("(somme entière) : %d\n",$$);}
;

plus_ou_moins : SIGN_S
;

somme_entiere : somme_entiere plus_ou_moins produit_entier {
				$$ = ($2 == '-') ? $1-$3 : $1 + $3;
				printf("result somme : %d\n",$$); 
				print_table_registre();
				ope_arith_mips($1,$1,$3,$2);
			}
	| produit_entier
;
produit_entier : produit_entier fois_div_moins operande_entier {
				if($2 == '/')
					$$ = $1/$3;
				else 
					$$ = ($2 == '*') ? $1*$3 : $1%$3;
				printf("result produit : %d\n",$$);
				ope_arith_mips($1,$1,$3,$2);
			}
	| operande_entier
;

fois_div_moins : SIGN_P
;


%%

#include "../code/fct_yacc.c"