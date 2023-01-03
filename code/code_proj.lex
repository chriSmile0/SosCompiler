%option nounput
%option noyywrap 
%{
	#include "../inc/code_proj.tab.h"
	#include "tokens.h"
	#include <stdlib.h>
	#include <stdbool.h>
	#include <errno.h>
	#include <limits.h>
	int yyerror(char * msg);
	bool checkNombres(char *nombres);
	int checkOperateur(char *operateurStr, int taille);
	bool checkAscii(char * str, bool com);
	bool word_test(char * str);
	bool testAscii;

	#define MAX_NUM 2147483647
	#define MIN_NUM -2147483648
%}

espace [ \t]
endline [\n]
com [#]
digit [0-9]
char [a-zA-Z_]
signe [+-]
n_in_word [;(){}=!$*+%|-]
ch_op_r [aeglnqt] 
ch_op_1 [anoz]

%%
^{espace}*if{espace}					return MR;
{espace}+then({espace}+|{endline}) 		return MR;
^{espace}*for{espace}+					return MR;
{espace}do({espace}+|{endline})			return MR;
^{espace}*done{espace};{endline}		return MR;
{espace}+in{espace}+					return MR;
^{espace}*while{espace}+				return MR;
^{espace}*until{espace}+				return MR;
test{espace}							return (word_test(--yytext) ? MR : yyerror(" Pas de bloc test"));
^{espace}*case{espace}+					return MR;
^{espace}*esac{espace}+					return MR;
^{espace}*echo{espace}+					return MR;
^{espace}*read{espace}+					return MR;
^{espace}*return{espace}+				return MR;
^{espace}*exit{espace}*					return MR;
({espace}+|{endline})local{espace}+		return MR;
^{espace}*elif{espace}+test{espace}+	return MR;
^{espace}*else{endline}					return MR;
^{espace}*fi{espace};{endline}			return MR;
^declare{espace}+						return MR;
{espace}+expr{espace}+					return MR;

\"(\\.|[^\\\"])*\"						return (checkAscii(&yytext[1], true) ? CC : yyerror(" Caractère non ASCII"));
\'(\\.|[^\\\'])*\'						return (checkAscii(&yytext[1], true) ? CC : yyerror(" Caractère non ASCII"));

{signe}?{digit}+						{ printf("NBBBB"); yylval.entier = atoi(yytext);return (checkNombres(yytext) ? NB : MOT);}

{com}+.*{endline}						return COM;

{espace}-{ch_op_1}{espace}				{return checkOperateur(yytext=(yytext+2),1);}
{espace}-({ch_op_r}{2}){espace}			{return checkOperateur(yytext=(yytext+2),2);}
{char}+(\\+([0-9]|[a-z]))+{char}+		{return N_ID;}//a ignorer printf("n_id|%s|\n",yytext);
{char}({char}|{digit})*					{ printf("IDDDDDD\n");yylval.id = strdup(yytext);return ID;}//printf("id=|%s|\n",yytext);
({char}|{digit})+						{return MOT;}//printf("mot : |%s|\n",yytext);

{endline}								;
. 										return (checkAscii(yytext, false) ? CHAR : yyerror(" Caractère non ASCII"));


%%

int yyerror(char * msg) 
{
	fprintf(stderr," %s\n",msg);
	return 1;
}

bool word_test(char * str) {
	while (*str != 't') {
		if (*str != ' ')
			return false;
		str++;
	}
	str++;
	if (*str == 'e')
		str++;
		if (*str == 's')
			str++;
			if (*str == 't')
				str++;
				if (*str == ' ') 
					return true;
	return false;
}


bool checkNombres(char *nombreStr) 
{
	char *ptrFin;
	errno = 0;
	long nombre = strtol(nombreStr, &ptrFin, 10); // On converti en base 10

	if ((errno == ERANGE && (nombre == LONG_MAX || nombre == LONG_MIN)) ||
			(errno != 0 && nombre == 0)) 
		exit(EXIT_FAILURE);

	return (nombre > MAX_NUM || nombre < MIN_NUM) ? false : true;
}

int checkOperateur(char *operateurStr, int taille)
{
	if (taille == 1) {
		// /a/n/o/z
		switch (operateurStr[0]) {
			case 'a':
				return ET;
				break;
			case 'n':
				return CCNV;
				break;
			case 'o': 
				return OU;
				break;
			case 'z': 
				return CCV;
				break;
			default:
				break;
		}
	}
	else if (taille == 2) {
		// eq/ne/gt/ge/lt/le
		switch (operateurStr[0]) {
			case 'g': 
				return (operateurStr[1] == 'e') ? GE : GT; 
				break;
			case 'l':
				return (operateurStr[1] == 'e') ? LE : LT;
				break;
			case 'e':
				return (operateurStr[1] == 'q') ? EQ : N_OP;
				break;
			case 'n':
				return (operateurStr[1] == 'e') ? NE : N_OP;
				break;
			default:
				break;
		}
	}
	return N_OP;
}

bool checkAscii(char * str, bool com) {
	if (strcmp(str, "\t") == 0)
		return true;
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
