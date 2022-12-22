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
	void mips_struct_file();
	bool checkNombres(char *nombres);
	int checkOperateur(char *operateurStr, int taille);
	bool checkAscii(char * str, bool com);
	bool word_test(char * str);
	bool testAscii;
	FILE *yyout_data;
	FILE *yyout_text;
	FILE *yyout_main;
	FILE *yyout_proc;
	FILE *yyout_final;
	

	int yaccc = 0;
	int elsee = 0;

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
operateur [+-/*]

%%
^{espace}*if{espace}					{if (yaccc) return IF; return MR;}
{espace}+then({espace}+|{endline}) 			{if (yaccc) return THEN; return MR;}
^{espace}*for{espace}+					return MR;
{espace}do({espace}+|{endline})			return MR;
^{espace}*done{espace};{endline}		return MR;
{espace}+in{espace}+					return MR;
^{espace}*while{espace}+				return MR;
^{espace}*until{espace}+				return MR;
test{espace}							return (word_test(--yytext) ? MR : yyerror(" Pas de bloc test"));	
^{espace}*case{espace}+					return MR;
^{espace}*esac{espace}+					return MR;
^{espace}*echo{espace}+					return ECH;
^{espace}*read{espace}+					return READ;
^{espace}*exit{espace}+	    			{printf("ext \n");return EXT;}
^{espace}*return{espace}+				return MR;
({espace}+|{endline})local{espace}+		return MR;
^{espace}*elif{espace}+test{espace}+	return MR;
^{espace}*else{endline}					{if (yaccc) {elsee++; return ELSE;} return MR;}
^{espace}*fi{espace}					{if (yaccc) return FI; return MR;}
^declare{espace}+						{if (yaccc) return DEC; return MR;}
{espace}+expr{espace}+					return MR;
\"(\\.|[^\\\"])*\"					{if(checkAscii(&yytext[1], true)==true) { 
											yylval.chaine = strdup(++yytext);
											return CC;
										}
										else 
											yyerror("Caractère non ASCII");
									}
\'(\\.|[^\\\'])*\'					{if(checkAscii(&yytext[1], true)==true) { 
											yylval.chaine = strdup(++yytext); 
											return CC;
										}
										else 
											yyerror("Caractère non ASCII");
									}

{digit}+						{yylval.entier = atoi(yytext);return (checkNombres(yytext) ? NB : MOT);}

{com}+.*{endline}						return COM;

{espace}-{ch_op_1}{espace}				{return checkOperateur(yytext=(yytext+2),1);}
{espace}-({ch_op_r}{2}){espace}			{return checkOperateur(yytext=(yytext+2),2);}
{char}+(\\+([0-9]|[a-z]))+{char}+		{return N_ID;}//a ignorer printf("n_id|%s|\n",yytext);
{char}({char}|{digit})*					{ yylval.id = strdup(yytext);return ID;}//printf("id=|%s|\n",yytext);
({char}|{digit})+						{return MOT;}//printf("mot : |%s|\n",yytext);
{operateur}{espace}*{operateur}+			// eviter les cas : 1+-1 et forcer : 1+(-1)
=								{return EG;}
[+]								{return PL;}
[-]								{return MN;}
[*]								{return FX;}
[/]								{return DV;}
[(]								{return OP;}
[)]								{return CP;}
[;]								{return END;}
[\[]							{return OB;}
[\]]							{return CB;}
{endline}							
. 									{if (strcmp(yytext, " ")) return (checkAscii(yytext, false) ? CHAR : yyerror(" Caractère non ASCII"));}

%%

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
