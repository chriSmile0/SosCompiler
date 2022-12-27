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


%token '\n' N_ID PVG SPA OACO CACO OCRO CCRO OPAR CPAR '$'
%token <nb> NB
%token <id> ID
%token <chaine> MOT 
%token <chaine> ARGS 
%token <sign> SIGN
%token <chaine> CC

%type <chaine> operande 
%type <entier> operande_entier
%type <sign> plus_ou_moins
%type <entier> somme_entiere
%type <entier> instruction
%start program 

%%

program: %empty
	| program instruction '\n'
;

instruction : operande {
					$$ = 0;
				}
	| operande_entier {
		$$ = 1;
	}
	| plus_ou_moins {
		$$ = 2;
	}
	
;

operande : CC {$$ = $1; printf("|%s|\n",rtn_arg(1,"abc def"));}
	| MOT {$$ = $1; printf("mot \n");}
	| ARGS {$$ = traiter_arg($1,"exemple");printf("$$ : %s\n",$$);}
	| '$' OACO ID CACO {$$ = str_value_of_id($3); printf("$$ : %s\n",$$);}
	| '$' OPAR EXPR somme_entiere CPAR {
			char tab[10];
			int_in_str($4,tab,0);
			if(strcmp(traiter_arg(tab,"exemple"),"??")==0)//?
				$$ = "0"; // on ignore
			else if(strcmp(traiter_arg(tab,"exemple"),"**")==0) //*
				$$ = "0"; // on ignore
			else //entier
				$$ = traiter_arg(tab,"exemple");
		} //pareil que $entier
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
	| NB {$$ = traiter_nombre($1);}
	| plus_ou_moins NB {$$ = ($1 == '-') ? (-traiter_nombre($2)) : traiter_nombre($2); }
	| OPAR somme_entiere CPAR {$$ = $2; printf("(somme entière) bouchon : %d\n",$$);}
;

plus_ou_moins : SIGN
;

somme_entiere : operande_entier {$$ = 1;} //BOUCHON
;



%%

#include "../code/fct_yacc.c"
