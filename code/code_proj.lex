%option nounput
%option noyywrap 
%{
	#include "../inc/code_proj.tab.h"
	void yyerror(char * msg);
%}

%%


%%

void yyerror(char * msg)
{
	fprintf(stderr," %s\n",msg);
	exit(1);
}