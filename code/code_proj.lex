%option nounput
%option noyywrap 
%{
	#include "../inc/code_proj.tab.h"
	#include "tokens.h"
	#include <stdlib.h>
	#include <stdbool.h>
	int yyerror(char * msg);
	bool checkNombres(char *nombres);
	bool checkAscii(char * str, bool com);
	bool testAscii;
%}

espace [ \t]
endline [\n]
com [#]
digit [0-9]

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
^{espace}*else{endline} 			return MR;
^{espace}*fi{espace};{endline}		return MR;
^{espace}*declare{espace}+			return MR;
{espace}+test{espace}+				return MR;
{espace}+expr{espace}+				return MR;
\"(\\.|[^\\\"])*\"					return (checkAscii(&yytext[1], true) ? CC : yyerror("Caractère non ASCII"));
\'(\\.|[^\\\'])*\'					return (checkAscii(&yytext[1], true) ? CC : yyerror("Caractère non ASCII"));

{digit}+							return (checkNombres(yytext) ? NB : yyerror("Nombres trop grand/trop petit"));

{com}+.*{endline}					return COM;
({espace}|{endline})*				;
. 									return (checkAscii(yytext, false) ? CHAR : yyerror("Caractère non ASCII"));

%%

int yyerror(char * msg)
{
	fprintf(stderr," %s\n",msg);
	return 1;
}

bool checkNombres(char *nombres) {
	int true_value = atoi(nombres);
	return (true_value > 2147483646 || true_value < -2147483645) ? false : true;
}

bool checkAscii(char * str, bool com) {
	bool b = testAscii;
	testAscii = false;
	if (b && !com)
		if(!(*str == '\"' || *str == '\'' || *str == '\\' 
			|| *str == 't' || *str == 'n'))
			return false;
	if (b && com)
			return false;
	if (com)	// Si on est dans une chaine de caractère
		str[strlen(str)-1] = '\0';	// On enlève le dernier guillemet
	while (*str != '\0') {
		if (*str < 32 || *str > 126)
			return false;
		if (*str == '\"' || *str == '\'')
			return false;
		if (*str == '\\') {
			if (com) {
				str++;
				if (!(*str == '\"' || *str == '\'' || *str == '\\' 
					|| *str == 't' || *str == 'n'))
					return false;
			}
			else {
				testAscii = true;
			}
		}
		str++;
	}
	return true;
}