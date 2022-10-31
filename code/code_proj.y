%{
	#include <stdio.h>
	extern int yylex();
	extern void yyerror(const char *msg);
	extern FILE *yyin;
%}

%token MR
%token CC
%token CHAR
%token COM

%start liste


%%

liste : %empty;

%%
