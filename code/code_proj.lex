%option nounput
%option noyywrap 
%{
	#include "../inc/code_proj.tab.h"
	#include "tokens.h"
	#include <stdlib.h>
	void yyerror(char * msg);
%}

espace [ \t]
endline [\n]

%%

^{espace}*if{espace}+				return MR;
{espace}+then({espace}+|{endline}) 	return MR;
^{espace}*for{espace}+				return MR;
{espace}do({espace}+|{endline}) 	return MR;
^{espace}*done{espace};{endline}	return MR;
{espace}+in{espace}+				return MR;
^{espace}*while{espace}+			return MR;
^{espace}*until{espace}+			return MR;
^{espace}*case{espace}+				return MR;
^{espace}*esac{espace}+				return MR;
^{espace}*echo{espace}+				return MR;
^{espace}*read{espace}+				return MR;
^{espace}*return{espace}+			return MR;
^{espace}*exit{espace}+				return MR;
^{espace}*local{espace}+ 			return MR;
^{espace}*elif{espace}+ 			return MR;
^{espace}*else({espace}+|{endline}) return MR;
^{espace}*fi{espace};{endline}		return MR;
^{espace}*declare{espace}+			return MR;
{espace}+test{espace}+				return MR;
{espace}+expr{espace}+				return MR;

. {;}//fprintf(stderr, "Caractère (%c) ignoré (pour le moment)\n", yytext[0]);
%%

void yyerror(char * msg)
{
	fprintf(stderr," %s\n",msg);
	exit(1);
}